import 'package:flutter/material.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/ui/help.dart';
import 'package:furdle/ui/home.dart';
import 'package:furdle/ui/settings.dart';
import 'package:furdle/ui/webview.dart';
import 'package:go_router/go_router.dart';

import 'ui/error_page.dart';

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
              child: const Home(
                title: appTitle,
              ),
            ),
        routes: [
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
        ]),
  ],
);
