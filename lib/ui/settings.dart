import 'package:flutter/material.dart';
import 'package:furdle/ui/notification_settings.dart';
import 'package:furdle/ui/theme_settings.dart';

import '../constants/const.dart';

/// Settings page: cards that let players tune how the game looks and when it
/// calls, centered and capped for comfortable reading on wide screens.
class SettingsPage extends StatelessWidget {
  static String path = '/settings';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ThemeSettingsWidget(),
                // SoundSettingsWidget(),
                const NotificationSettingsWidget(),
                // Add more settings widgets here as needed
                Spacer(),
                Text("v${Constants.appVersion.split('+')[0]}"),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
