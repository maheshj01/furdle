import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/pages/furdle.dart';
import 'package:flutter_template/pages/home.dart';
import 'package:flutter_template/utils/settings_controller.dart';
import 'package:go_router/go_router.dart';
import 'constants/constants.dart' show APP_TITLE;

/// Settings are exposed globally to access from anywhere

late SettingsController settingsController;
void main() {
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
          title: 'Furdle',
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
            // home: const MyHomePage(title: 'Flutter Template'),
            routeInformationParser: _router.routeInformationParser,
            routerDelegate: _router.routerDelegate,
          );
        });
  }
}
