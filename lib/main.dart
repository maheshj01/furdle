import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furdle/controller/game_controller.dart';
import 'package:furdle/controller/settings_controller.dart';
import 'package:furdle/firebase_options.dart';
import 'package:furdle/pages/home.dart';
import 'package:go_router/go_router.dart';

import 'constants/constants.dart';

/// Settings are exposed globally to access from anywhere

late SettingsController settingsController;
late GameController gameController;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  settingsController = SettingsController();
  gameController = GameController();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _router = GoRouter(initialLocation: '/', routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const PlayGround(
          title: appTitle,
        ),
      ),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp.router(
            title: appTitle,
            debugShowCheckedModeBanner: kDebugMode,
            theme: ThemeData(
              primaryColor: primaryBlue,
              colorScheme:
                  const ColorScheme.light().copyWith(primary: primaryBlue),
            ),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,
            routeInformationParser: _router.routeInformationParser,
            routerDelegate: _router.routerDelegate,
          );
        });
  }
}
