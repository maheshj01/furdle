import 'package:flutter/material.dart';

class SettingsSnackBar {
  /// Show a settings feedback snackbar
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
    bool clearPrevious = true,
  }) {
    if (!context.mounted) return;

    if (clearPrevious) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show success message
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// Show info message
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  /// Show warning message
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      icon: Icons.warning_outlined,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  /// Show error message
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  // Predefined messages for common settings actions
  static void showThemeChanged(BuildContext context, bool isDarkMode) {
    show(
      context,
      message: isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
      icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
      backgroundColor: isDarkMode ? Colors.indigo : Colors.orange,
    );
  }

  static void showSoundChanged(BuildContext context, bool isEnabled) {
    show(
      context,
      message: isEnabled ? 'Sound effects enabled' : 'Sound effects disabled',
      icon: isEnabled ? Icons.volume_up : Icons.volume_off,
      backgroundColor: isEnabled ? Colors.green : Colors.grey,
    );
  }

  static void showNotificationsChanged(BuildContext context, bool isEnabled) {
    show(
      context,
      message: isEnabled ? 'Notifications enabled for daily challenges' : 'Notifications disabled',
      icon: isEnabled ? Icons.notifications_active : Icons.notifications_off,
      backgroundColor: isEnabled ? Colors.blue : Colors.grey,
    );
  }
}
