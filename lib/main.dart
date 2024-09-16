import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:furdle/firebase_options.dart';
import 'package:furdle/router.dart';
import 'package:furdle/shared/theme/colors.dart';
import 'package:furdle/shared/theme/theme.dart';

import 'constants/constants.dart';

/// Settings are exposed globally to access from anywhere

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeProvider);
    return MaterialApp.router(
      title: appTitle,
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData(
        primaryColor: AppColors.primary,
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
