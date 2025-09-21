import 'package:flutter/material.dart';

SnackBar snackBar(
    {required String message,
    required Duration duration,
    EdgeInsetsGeometry? margin}) {
  return SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    behavior: SnackBarBehavior.floating,
    duration: duration,
    margin: margin,
  );
}
