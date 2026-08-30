import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:furdle/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Global topic for all Furdle users
  static const String globalTopic = 'daily_challenge';

  // Key to store subscription status in SharedPreferences
  static const String _subscriptionStatusKey = 'fcm_topic_subscribed';

  // Fixed id for the "notifications enabled" confirmation ping, so toggling
  // the setting replaces the previous confirmation rather than stacking them.
  static const int _enabledConfirmationId = 1001;

  // Shared presentation for every local notification (same Android channel and
  // iOS options), reused by the challenge alerts and the enable confirmation.
  static const NotificationDetails _channelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      'furdle_notifications',
      'Furdle Notifications',
      channelDescription: 'Notifications for new Furdle challenges',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_notification',
      color: Color(0xFF6200EE),
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
  );

  // When a notification is sent with this action
  // {action: app_update}: This will redirect to the Play Store
  static const String kAppUpdateAction = 'app_update';
  // {action: new_challenge}: This will redirect to the game screen
  static const String kNewChallengeAction = 'new_challenge';

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      await _requestPermissions();
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Subscribe to global topic and app updates topic
      await _subscribeToGlobalTopic();
      // Set up message handlers
      _setupMessageHandlers();

      // Handle notification when app is launched from terminated state
      _handleInitialMessage();

      setUpBackgroundHandler();

      print('Notification service initialized successfully');

      // Get FCM token for debugging
      final token = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $token');
    } catch (e) {
      print(' Error initializing notification service: $e');
    }
  }

  Future<void> setUpBackgroundHandler() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    bool permissionGranted = false;

    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      print('iOS notification permission status: ${settings.authorizationStatus}');
    }

    // For Android 13+, request notification permission
    if (Platform.isAndroid) {
      final androidPermission = await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      permissionGranted = androidPermission ?? true; // Assume granted for older Android versions
      print('Android notification permission granted: $androidPermission');
    }

    return permissionGranted;
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'furdle_notifications', // id
        'Furdle Notifications', // title
        description: 'Notifications for new Furdle challenges',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Check if already subscribed to the global topic
  Future<bool> _isSubscribedToTopic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_subscriptionStatusKey) ?? false;
    } catch (e) {
      print('Error checking subscription status: $e');
      return false;
    }
  }

  /// Set subscription status in local storage
  Future<void> _setSubscriptionStatus(bool isSubscribed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_subscriptionStatusKey, isSubscribed);
    } catch (e) {
      print('Error setting subscription status: $e');
    }
  }

  /// Check if notifications are enabled in settings
  Future<bool> _areNotificationsEnabledInSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('settings');
      if (settingsJson != null) {
        final settings = json.decode(settingsJson) as Map<String, dynamic>;
        return settings['isNotificationsEnabled'] ?? true;
      }
      return true; // Default to enabled if no settings found
    } catch (e) {
      print('Error checking notification settings: $e');
      return true; // Default to enabled on error
    }
  }

  /// Subscribe to global topic for daily challenges (only if not already subscribed)
  Future<void> _subscribeToGlobalTopic() async {
    try {
      // Check if notifications are enabled in settings
      final notificationsEnabled = await _areNotificationsEnabledInSettings();
      if (!notificationsEnabled) {
        return;
      }

      // Check if already subscribed
      final alreadySubscribed = await _isSubscribedToTopic();
      if (alreadySubscribed) {
        return;
      }

      // Subscribe to the topic
      await _firebaseMessaging.subscribeToTopic(globalTopic);
      await _setSubscriptionStatus(true);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from global topic
  Future<void> _unsubscribeFromGlobalTopic() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(globalTopic);
      await _setSubscriptionStatus(false);
    } catch (e) {
      print(' Error unsubscribing from topic: $e');
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is in background but not terminated
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageOpenedApp,
    );
  }

  /// Handle messages when app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    // This is crucial because Firebase doesn't automatically show notifications in foreground
    try {
      await _showLocalNotification(message);
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  /// Handle messages when app is opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    _handleNotificationAction(message);
  }

  /// Handle notification when app is launched from terminated state
  void _handleInitialMessage() {
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationAction(message);
      }
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Furdle',
      message.notification?.body ?? 'New challenge available!',
      _channelSpecifics,
      payload: json.encode(message.data),
    );
  }

  /// Navigate to the game screen
  void _navigateToGame() {
    // This would typically use your app's navigation system
    // For now, we'll just print a message
    // Example: Get.toNamed('/game') or Navigator.pushNamed(context, '/game')
  }

  /// Handle app update action - redirect to Play Store
  Future<void> _handleAppUpdateAction() async {
    try {
      final Uri playStoreUri = Uri.parse(playStoreUrl);

      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        print('❌ Could not launch Play Store URL: $playStoreUrl');
      }
    } catch (e) {
      print('❌ Error launching Play Store: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Parse the payload to determine action
    final String? payload = notificationResponse.payload;

    if (payload != null) {
      try {
        final Map<String, dynamic> data = json.decode(payload);
        final String? action = data['action'];

        switch (action) {
          case kAppUpdateAction:
            _handleAppUpdateAction();
            break;
          case kNewChallengeAction:
            _navigateToGame();
            break;
          default:
            _navigateToGame();
            break;
        }
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
        _navigateToGame(); // Default action
      }
    } else {
      _navigateToGame(); // Default action if no payload
    }
  }

  /// Handle notification actions (navigation, etc.)
  void _handleNotificationAction(RemoteMessage message) {
    // Extract action from message data
    final String? action = message.data['action'];

    switch (action) {
      case kAppUpdateAction:
        _handleAppUpdateAction();
        break;
      case kNewChallengeAction:
        _navigateToGame();
        break;
      default:
        _navigateToGame();
        break;
    }
  }

  /// Send a test notification (for debugging)
  Future<void> sendTestNotification() async {
    if (kDebugMode) {
      try {
        await _showLocalNotification(
          RemoteMessage(
            messageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
            notification: const RemoteNotification(
              title: '🧩 New Furdle Challenge!',
              body: 'A new daily challenge is now available. Can you solve it?',
            ),
            data: {'action': 'new_challenge'},
          ),
        );
      } catch (e) {
        print('❌ Error sending test notification: $e');
      }
    }
  }

  /// Send an app update notification (for testing)
  Future<void> sendAppUpdateNotification({
    String title = '🔄 Furdle Update Available!',
    String body =
        'A new version of Furdle is available with exciting new features and improvements.',
  }) async {
    try {
      await _showLocalNotification(
        RemoteMessage(
          messageId: 'update_${DateTime.now().millisecondsSinceEpoch}',
          notification: RemoteNotification(title: title, body: body),
          data: {'action': 'app_update'},
        ),
      );
    } catch (e) {
      print('❌ Error sending app update notification: $e');
    }
  }

  /// Check if notifications are properly configured
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }

    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    return false;
  }

  /// Enable notifications by subscribing to the global topic, then fire a local
  /// notification so the player can see an alert land the moment they opt in.
  Future<void> enableNotifications() async {
    await _subscribeToGlobalTopic();
    await showEnabledConfirmation();
  }

  /// Show a local notification confirming daily-challenge alerts are on.
  Future<void> showEnabledConfirmation() async {
    try {
      await _localNotifications.show(
        _enabledConfirmationId,
        'Notifications on 🔔',
        "You're all set — we'll ping you when a new daily word drops.",
        _channelSpecifics,
        payload: json.encode({'action': kNewChallengeAction}),
      );
    } catch (e) {
      print('❌ Error showing enable confirmation: $e');
    }
  }

  /// Disable notifications by unsubscribing from the global topic
  Future<void> disableNotifications() async {
    await _unsubscribeFromGlobalTopic();
  }

  /// Get the global topic name
  String get topicName => globalTopic;

  /// Get current subscription status (for debugging)
  Future<bool> getSubscriptionStatus() async {
    return await _isSubscribedToTopic();
  }

  /// Send app update notification manually (for testing)
  Future<void> sendManualAppUpdateNotification({
    String title = '🔄 Furdle Update Available!',
    String body =
        'A new version of Furdle is available with exciting new features and improvements.',
    String version = '1.0.0',
  }) async {
    try {
      await _showLocalNotification(
        RemoteMessage(
          messageId: 'manual_update_${DateTime.now().millisecondsSinceEpoch}',
          notification: RemoteNotification(title: title, body: body),
          data: {
            'action': 'app_update',
            'version': version,
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );
    } catch (e) {
      print('❌ Error sending manual app update notification: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}
