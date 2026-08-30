import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/provider/settings_notifier.dart';
import 'package:furdle/ui/components/index.dart';

class ThemeSettingsWidget extends ConsumerWidget {
  const ThemeSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final isDarkMode = settingsState.isDarkMode;

    // Sun for day, moon for night — the accent follows the mode.
    final accent = isDarkMode ? const Color(0xFF7C82F0) : const Color(0xFFE0A62C);

    return SettingsSection(
      eyebrow: 'Appearance',
      icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
      title: 'Dark mode',
      subtitle: isDarkMode ? 'The board plays in the dark.' : 'The board plays in the light.',
      value: isDarkMode,
      accent: accent,
      hintIcon: isDarkMode ? Icons.nights_stay : Icons.wb_sunny,
      hint: isDarkMode
          ? 'Dimmed tiles are easier on the eyes in low light.'
          : 'Bright tiles stay crisp in daylight.',
      onChanged: (value) {
        settingsNotifier.toggleDarkMode();
        SettingsSnackBar.showThemeChanged(context, value);
      },
    );
  }
}
