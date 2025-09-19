import 'package:flutter/material.dart';
import 'package:furdle/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// State Color for either furdle or Keyboard
class Utility {
  static Future<void> launch(String url,
      {bool isNewTab = true,
      LaunchMode mode = LaunchMode.externalApplication}) async {
    await launchUrl(
      Uri.parse(url),
      mode: mode,
      webOnlyWindowName: isNewTab ? '_blank' : '_self',
    );
  }

  static void showMessage(context, message,
      {Duration? duration = const Duration(milliseconds: 1500),
      EdgeInsetsGeometry? margin}) {
    ScaffoldMessenger.of(context).showSnackBar(
        snackBar(message: '$message', duration: duration!, margin: margin));
  }
}
