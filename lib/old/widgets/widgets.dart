import 'package:flutter/material.dart';

SnackBar snackBar({
  required String message,
  required Duration duration,
  Size screenSize = const Size(0, 0),
}) {
  final double margin = screenSize.width / 3;
  return SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    behavior: SnackBarBehavior.floating,
    duration: duration,
    margin: EdgeInsets.only(
        bottom: screenSize.height * 0.9 - kToolbarHeight,
        right: screenSize.width < 500 ? 20 : margin,
        left: screenSize.width < 500 ? 20 : margin),
  );
}
