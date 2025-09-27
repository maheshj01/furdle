import 'package:flutter/material.dart';
import 'package:furdle/ui/notification_settings.dart';
import 'package:furdle/ui/sound_settings.dart';
import 'package:furdle/ui/theme_settings.dart';

/// Simple settings page that includes notification settings
class SettingsPage extends StatelessWidget {
  static String path = '/settings';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        foregroundColor: Colors.white,
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            SizedBox(height: 16),
            ThemeSettingsWidget(),
            SoundSettingsWidget(),
            NotificationSettingsWidget(),
            // Add more settings widgets here as needed
          ],
        ),
      ),
    );
  }
}
