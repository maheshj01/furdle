import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/colors.dart';
import 'package:furdle/provider/settings_notifier.dart';
import 'package:furdle/service/notification_service.dart';
import 'package:furdle/ui/components/index.dart';

class NotificationSettingsWidget extends ConsumerWidget {
  const NotificationSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final isEnabled = settingsState.isNotificationsEnabled;

    // Active toggles glow the game's "correct" green; idle ones stay grey.
    final accent = isEnabled ? AppColors.tileGreen : AppColors.tileAbsent;

    return SettingsSection(
      eyebrow: 'Daily challenge',
      icon: isEnabled ? Icons.notifications_active : Icons.notifications_off,
      title: 'New word alerts',
      subtitle: 'Get a nudge when a fresh word drops.',
      value: isEnabled,
      accent: accent,
      hintIcon: Icons.schedule,
      hint: isEnabled ? "We'll ping you at midnight UTC, when the new daily word goes live." : null,
      onChanged: (value) async {
        settingsNotifier.setNotificationsEnabled(value);

        final notificationService = NotificationService();
        if (value) {
          await notificationService.enableNotifications();
        } else {
          await notificationService.disableNotifications();
        }

        SettingsSnackBar.showNotificationsChanged(context, value);
      },
    );
  }
}
