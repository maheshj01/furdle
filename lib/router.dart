import 'package:flutter/material.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/ui/help.dart';
import 'package:furdle/ui/home.dart';
import 'package:furdle/ui/settings.dart';
import 'package:furdle/ui/streak.dart';
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
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                    key: state.pageKey,
                    child: HelpPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      );
                    },
                  )),
          GoRoute(
              path: '${SettingsPage.path}',
              name: 'settings',
              pageBuilder: (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: SettingsPage(),
                  )),
          GoRoute(
              path: '${StreakPage.path}',
              name: 'streak',
              pageBuilder: (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: StreakPage(),
                  )),
          GoRoute(
              path: '${WebViewPage.routeName}',
              name: 'Privacy Policy',
              pageBuilder: (context, state) => MaterialPage<void>(
                    key: state.pageKey,
                    child: WebViewPage(
                      title: 'Privacy Policy',
                      url: privacyPolicyUrl,
                    ),
                  )),
        ]),
  ],
);
