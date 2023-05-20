import 'package:flutter/material.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/models.dart';
import 'package:furdle/utils/utility.dart';

import '../constants/strings.dart';

class SettingsPage extends StatefulWidget {
  final String title = settingsTitle;

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    getStats();
  }

  Future<void> getStats() async {
    stats = settingsController.stats;
    setState(() {});
  }

  late Stats stats;
  @override
  Widget build(BuildContext context) {
    Widget _stats(String key, String value) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              key,
              style: const TextStyle(fontSize: 18),
            ),
            trailing: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ));
    }

    Widget _subtitle(String subtitle) {
      return Text(
        subtitle,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _subtitle('Theme'),
                ToggleButtons(
                    children: const [
                      Text('Light'),
                      Text('Dark'),
                      Text('System'),
                    ],
                    constraints:
                        const BoxConstraints(minWidth: 80, minHeight: 40),
                    onPressed: (int index) {
                      settingsController.updateThemeMode(index == 0
                          ? ThemeMode.light
                          : index == 1
                              ? ThemeMode.dark
                              : ThemeMode.system);
                      setState(() {});
                    },
                    isSelected: [
                      settingsController.themeMode == ThemeMode.light,
                      settingsController.themeMode == ThemeMode.dark,
                      settingsController.themeMode == ThemeMode.system,
                    ]),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _subtitle('Difficulty'),
                ToggleButtons(
                    constraints:
                        const BoxConstraints(minWidth: 80, minHeight: 40),
                    children: const [
                      Text('Easy'),
                      Text('Medium'),
                      Text('Hard'),
                    ],
                    onPressed: (int index) {
                      final _selectedDifficulty =
                          Difficulty.fromToggleIndex(index);
                      final _puzzle = gameController.gameState.puzzle;
                      if (_selectedDifficulty !=
                          settingsController.difficulty) {
                        /// If game has not started change the settings
                        if (_puzzle.result == PuzzleResult.none) {
                          settingsController.difficulty = _selectedDifficulty;
                          gameController.gameState.puzzle =
                              _puzzle.copyWith(difficulty: _selectedDifficulty);
                        } else {
                          Utility.showMessage(context,
                              "The settings will be applied to the next puzzle");
                        }
                      }
                      setState(() {});
                    },
                    isSelected: [
                      settingsController.difficulty == Difficulty.easy,
                      settingsController.difficulty == Difficulty.medium,
                      settingsController.difficulty == Difficulty.hard,
                    ]),
              ],
            ),
            const Divider(),
            _subtitle('Stats'),
            _stats('Played', '${stats.total}'),
            _stats('Win', '${stats.won}'),
            _stats('Lose', '${stats.lost}'),
            const Divider(),
            const Expanded(child: SizedBox()),
            SizedBox(
              height: 50,
              child: Align(
                  alignment: Alignment.center,
                  child: Text('v${settingsController.version}')),
            )
          ],
        ),
      ),
    );
  }
}
