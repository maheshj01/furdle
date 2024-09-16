import 'package:flutter/material.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/pages/error_page.dart';
import 'package:furdle/pages/help.dart';
import 'package:furdle/pages/playground.dart';
import 'package:furdle/pages/settings.dart';
import 'package:furdle/pages/webview.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  errorPageBuilder: (context, state) => MaterialPage<void>(
    key: state.pageKey,
    child: ErrorPage(),
  ),
  routes: [
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
    GoRoute(
        path: '${HelpPage.path}',
        name: 'help',
        pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: HelpPage(),
            )),
    GoRoute(
        path: '${SettingsPage.path}',
        name: 'settings',
        pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: SettingsPage(),
            )),
    GoRoute(
        path: '${WebViewPage.routeName}',
        name: 'Privacy Policy',
        pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: WebViewPage(
                title: 'Privacy Policy',
                url: PRIVACY_POLICY,
              ),
            )),
  ],
);
