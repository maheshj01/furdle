import 'package:flutter/material.dart';
import 'package:furdle/main.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStats();
  }

  Future<void> getStats() async {
    print('fetchind stats');
    final history = settingsController.matchHistory;
    played = history.length;
    win = history.where((element) => element.name == "win").length;
    lose = played - win;
    print('$played = $win + $lose');
    setState(() {});
  }

  late int played;
  late int win;
  late int lose;

  @override
  Widget build(BuildContext context) {
    Widget _stats(String key, String value) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
