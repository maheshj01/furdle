import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: isDesktop ? 600 : screenSize.width,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Daily Challenge Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Get notified when new daily challenges are available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable Notifications',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Switch(
                  value: isEnabled,
                  onChanged: (value) async {
                    // Update settings state
                    settingsNotifier.setNotificationsEnabled(value);

                    // Update notification service
                    final notificationService = NotificationService();
                    if (value) {
                      await notificationService.enableNotifications();
                    } else {
                      await notificationService.disableNotifications();
                    }

                    // Show feedback to user
                    SettingsSnackBar.showNotificationsChanged(context, value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
            if (isEnabled) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'ll receive notifications when new daily challenges are published (typically at midnight UTC)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
