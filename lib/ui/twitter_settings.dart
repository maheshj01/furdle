import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/provider/settings_notifier.dart';
import 'package:furdle/ui/components/index.dart';

class TwitterSettingsWidget extends ConsumerStatefulWidget {
  const TwitterSettingsWidget({super.key});

  @override
  ConsumerState<TwitterSettingsWidget> createState() => _TwitterSettingsWidgetState();
}

class _TwitterSettingsWidgetState extends ConsumerState<TwitterSettingsWidget> {
  late TextEditingController _twitterController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _twitterController = TextEditingController();
  }

  @override
  void dispose() {
    _twitterController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    // Update controller if the settings change
    if (_twitterController.text != settingsState.twitterUsername) {
      _twitterController.text = settingsState.twitterUsername;
    }

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
                  Icons.alternate_email,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Twitter Integration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Get mentioned when you\'re the first to crack the daily puzzle (optional)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _twitterController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Twitter Username',
                hintText: 'Enter without @ symbol (e.g., johndoe)',
                prefixIcon: const Icon(Icons.alternate_email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              onChanged: (value) {
                // Clean the input - remove @ if user types it
                String cleanValue = value.replaceFirst('@', '');
                if (cleanValue != value) {
                  _twitterController.text = cleanValue;
                  _twitterController.selection = TextSelection.fromPosition(
                    TextPosition(offset: cleanValue.length),
                  );
                }
                settingsNotifier.setTwitterUsername(cleanValue);
              },
              onSubmitted: (value) {
                _focusNode.unfocus();
              },
            ),
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
                      'If you\'re the first to solve today\'s puzzle, we\'ll tweet about it and mention your username! Leave blank to remain anonymous.',
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
        ),
      ),
    );
  }
}