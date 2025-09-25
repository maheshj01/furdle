import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/provider/settings_notifier.dart';
import 'package:furdle/ui/components/index.dart';

class SoundSettingsWidget extends ConsumerWidget {
  const SoundSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final isSoundEnabled = settingsState.isSoundEnabled;
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
                  isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sound Effects',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enable sound effects for game interactions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSoundEnabled ? Icons.music_note : Icons.music_off,
                      size: 20,
                      color: isSoundEnabled ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sound Effects',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                Switch(
                  value: isSoundEnabled,
                  onChanged: (value) {
                    settingsNotifier.setSoundEnabled(value);

                    // Show feedback to user
                    SettingsSnackBar.showSoundChanged(context, value);
                  },
                  activeThumbColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isSoundEnabled ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isSoundEnabled ? Colors.green : Colors.grey).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isSoundEnabled ? Colors.green[700] : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isSoundEnabled
                          ? 'Sound effects will play for correct letters, word completion, and game events'
                          : 'Game will run silently without sound effects',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSoundEnabled ? Colors.green[700] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
