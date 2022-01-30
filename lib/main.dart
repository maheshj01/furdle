import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furdle/pages/home.dart';
import 'package:furdle/utils/settings_controller.dart';
import 'package:go_router/go_router.dart';
import 'constants/constants.dart' show APP_TITLE;
import 'utils/word.dart';

/// Settings are exposed globally to access from anywhere

late SettingsController settingsController;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  settingsController = SettingsController();
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
        child: const MyHomePage(
          title: APP_TITLE,
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
            title: APP_TITLE,
            debugShowCheckedModeBanner: kDebugMode,
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,
            routeInformationParser: _router.routeInformationParser,
            routerDelegate: _router.routerDelegate,
          );
        });
  }
}
