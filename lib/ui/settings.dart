import 'package:flutter/material.dart';
import 'package:furdle/ui/notification_settings.dart';
import 'package:furdle/ui/theme_settings.dart';

/// Settings page: cards that let players tune how the game looks and when it
/// calls, centered and capped for comfortable reading on wide screens.
class SettingsPage extends StatelessWidget {
  static String path = '/settings';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ThemeSettingsWidget(),
                  // SoundSettingsWidget(),
                  const NotificationSettingsWidget(),
                  // Add more settings widgets here as needed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
