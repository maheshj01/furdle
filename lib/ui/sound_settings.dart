import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/colors.dart';
import 'package:furdle/provider/settings_notifier.dart';
import 'package:furdle/ui/components/index.dart';

class SoundSettingsWidget extends ConsumerWidget {
  const SoundSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final isSoundEnabled = settingsState.isSoundEnabled;

    // Active toggles glow the game's "correct" green; idle ones stay grey.
    final accent = isSoundEnabled ? AppColors.tileGreen : AppColors.tileAbsent;

    return SettingsSection(
      eyebrow: 'Sound effects',
      icon: isSoundEnabled ? Icons.volume_up : Icons.volume_off,
      title: 'Game sounds',
      subtitle: 'Clicks and chimes as you play.',
      value: isSoundEnabled,
      accent: accent,
      hintIcon: isSoundEnabled ? Icons.music_note : Icons.music_off,
      hint: isSoundEnabled
          ? 'Hear each letter land and every word you solve.'
          : 'The board stays silent.',
      onChanged: (value) {
        settingsNotifier.setSoundEnabled(value);
        SettingsSnackBar.showSoundChanged(context, value);
      },
    );
  }
}
