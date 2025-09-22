import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Global topic for all Furdle users
  static const String globalTopic = 'daily_challenge';

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Subscribe to global topic
      await _subscribeToGlobalTopic();

      // Set up message handlers
      _setupMessageHandlers();

      // Handle notification when app is launched from terminated state
      _handleInitialMessage();

      setUpBackgroundHandler();

      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  Future<void> setUpBackgroundHandler() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    // For Android 13+, request notification permission
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
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
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Subscribe to global topic for daily challenges
  Future<void> _subscribeToGlobalTopic() async {
    try {
      await _firebaseMessaging.subscribeToTopic(globalTopic);
      print('Subscribed to topic: $globalTopic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from global topic
  Future<void> _unsubscribeFromGlobalTopic() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(globalTopic);
      print('Unsubscribed from topic: $globalTopic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is in background but not terminated
    _onMessageOpenedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Handle messages when app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Received foreground message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  /// Handle messages when app is opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📱 App opened from notification: ${message.messageId}');
    _handleNotificationAction(message);
  }

  /// Handle notification when app is launched from terminated state
  void _handleInitialMessage() {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('🚀 App launched from notification: ${message.messageId}');
        _handleNotificationAction(message);
      }
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'furdle_notifications',
      'Furdle Notifications',
      channelDescription: 'Notifications for new Furdle challenges',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: Color(0xFF6200EE),
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Furdle',
      message.notification?.body ?? 'New challenge available!',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('🔔 Notification tapped: ${notificationResponse.payload}');
    // Navigate to appropriate screen or handle action
    _navigateToGame();
  }

  /// Handle notification actions (navigation, etc.)
  void _handleNotificationAction(RemoteMessage message) {
    // Extract action from message data
    final String? action = message.data['action'];

    switch (action) {
      case 'new_challenge':
        _navigateToGame();
        break;
      case 'reminder':
        _navigateToGame();
        break;
      default:
        _navigateToGame();
    }
  }

  /// Navigate to the game screen
  void _navigateToGame() {
    // This would typically use your app's navigation system
    // For now, we'll just print a message
    print('🎮 Navigating to game...');
    // Example: Get.toNamed('/game') or Navigator.pushNamed(context, '/game')
  }

  /// Send a test notification (for debugging)
  Future<void> sendTestNotification() async {
    if (kDebugMode) {
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
    }
  }

  /// Enable notifications by subscribing to the global topic
  Future<void> enableNotifications() async {
    await _subscribeToGlobalTopic();
  }

  /// Disable notifications by unsubscribing from the global topic
  Future<void> disableNotifications() async {
    await _unsubscribeFromGlobalTopic();
  }

  /// Get the global topic name
  String get topicName => globalTopic;

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
