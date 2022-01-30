import 'package:flutter/material.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/models.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
              '$key',
              style: const TextStyle(fontSize: 18),
            ),
            trailing: Text(
              '$value',
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
        title: const Text('Settings'),
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
                      settingsController.difficulty = index == 0
                          ? Difficulty.easy
                          : index == 1
                              ? Difficulty.medium
                              : Difficulty.hard;
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
          ],
        ),
      ),
    );
  }
}
