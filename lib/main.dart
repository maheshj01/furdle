import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:furdle/firebase_options.dart';
import 'package:furdle/old/shared/theme/theme.dart';
import 'package:furdle/router.dart';
import 'package:furdle/service/hive_storage_service.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'constants/constants.dart';

/// Settings are exposed globally to access from anywhere

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await _initializeHive();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(ProviderScope(child: MyApp()));
}

Future<void> _initializeHive() async {
  // Get the application documents directory
  final directory = await getApplicationDocumentsDirectory();

  // Set Hive's default directory
  Hive.init(directory.path);

  // Initialize the Hive storage service
  final hiveService = HiveStorageService();
  await hiveService.initializeHive();
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeProvider);
    return MaterialApp.router(
      title: appTitle,
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(iconSize: 32),
        ),
        colorScheme:
            const ColorScheme.light().copyWith(primary: AppColors.primary),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
