import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

enum TransitionType { ltr, rtl, ttb, btt, bl, br, tl, tr, scale }

class Navigate<T> {
  /// Replace the top widget with another widget
  Future<T?> pushReplace(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,
      TransitionType slideTransitionType = TransitionType.scale}) async {
    final T value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushReplacement(NavigateRoute(widget, type: slideTransitionType));
    return value;
  }

  static Future<void> push(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,
      TransitionType transitionType = TransitionType.scale}) async {
    await Navigator.of(context, rootNavigator: isRootNavigator)
        .push(NavigateRoute(widget, type: transitionType));
    // return value;
  }

// pop all Routes except first
  static void popToFirst(BuildContext context, {bool isRootNavigator = true}) =>
      Navigator.of(context, rootNavigator: isRootNavigator)
          .popUntil((route) => route.isFirst);

  static Future<void> popView<T>(BuildContext context,
          {T? value, bool isRootNavigator = true}) async =>
      Navigator.of(context, rootNavigator: isRootNavigator).pop(value);

  static Future<void> pushAndPopAll(BuildContext context, Widget widget,
      {bool isRootNavigator = true,
      TransitionType transitionType = TransitionType.scale}) async {
    final value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushAndRemoveUntil(NavigateRoute(widget, type: transitionType),
            (Route<dynamic> route) => false);
    return value;
  }
}

Offset getTransitionOffset(TransitionType type) {
  switch (type) {
    case TransitionType.ltr:
      return const Offset(-1.0, 0.0);
    case TransitionType.rtl:
      return const Offset(1.0, 0.0);
    case TransitionType.ttb:
      return const Offset(0.0, -1.0);
    case TransitionType.btt:
      return const Offset(0.0, 1.0);
    case TransitionType.bl:
      return const Offset(-1.0, 1.0);
    case TransitionType.br:
      return const Offset(1.0, 1.0);
    case TransitionType.tl:
      return const Offset(-1.0, -1.0);
    case TransitionType.tr:
      return const Offset(1.0, 1.0);
    case TransitionType.scale:
      return const Offset(0.6, 1.0);
    default:
      return const Offset(1.0, 0.0);
  }
}

class NavigateRoute extends PageRouteBuilder {
  final Widget widget;
  final bool? rootNavigator;
  final TransitionType type;
  NavigateRoute(this.widget, {this.rootNavigator, required this.type})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => widget,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = getTransitionOffset(type);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            if (type == TransitionType.scale) {
              return child;
            }
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

class PageRoute extends PageRouteBuilder {
  final Widget widget;
  final bool? rootNavigator;
  final TransitionType type;
  PageRoute(this.widget, {this.rootNavigator, required this.type})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => widget,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = getTransitionOffset(type);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

class PageRoutes {
  static const double kDefaultDuration = 0.5;
  static Route<T> fadeThrough<T>(Widget page,
      [double duration = kDefaultDuration]) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: (duration * 1000).round()),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child);
      },
    );
  }

  static Route<T> fadeScale<T>(Widget page,
      [double duration = kDefaultDuration]) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: (duration * 1000).round()),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(animation: animation, child: child);
      },
    );
  }

  static Route<T> sharedAxis<T>(Widget page,
      [SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
      double duration = kDefaultDuration]) {
    return PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: (duration * 1000).round()),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
        );
      },
    );
  }
}
