import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:furdle/firebase_options.dart';
import 'package:furdle/router.dart';
import 'package:furdle/service/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants/constants.dart';
import 'provider/app_theme_provider.dart';

/// Settings are exposed globally to access from anywhere

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await _initializeHive();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  await NotificationService().initialize();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(ProviderScope(child: MyApp()));
}

Future<void> _initializeHive() async {
  // Initialize Hive using hive_flutter which handles all platforms including web
  await Hive.initFlutter();
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);
    return MaterialApp.router(
      title: appTitle,
      debugShowCheckedModeBanner: kDebugMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
