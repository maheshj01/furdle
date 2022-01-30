import 'package:flutter/material.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/puzzle.dart';

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
    print('fetchind stats');
    // final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final puzzles = settingsController.puzzles;
    print(puzzles);
    played = puzzles.length;
    win = puzzles
        .where((element) => element.result == PuzzleResult.win)
        .toList()
        .length;
    lose = played - win;
    print('$played = $win + $lose');
    setState(() {});
  }

  int played = 0;
  int win = 0;
  int lose = 0;

  @override
  Widget build(BuildContext context) {
    Widget _stats(String key, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          Text(
            '$key',
            style: TextStyle(fontSize: 24),
          ),
          Text(
            '$value',
            style: TextStyle(fontSize: 24),
          )
        ]),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          _stats('Played', '$played'),
          _stats('Win', '$win'),
          _stats('Lose', '$lose'),
        ],
      ),
    );
  }
}
