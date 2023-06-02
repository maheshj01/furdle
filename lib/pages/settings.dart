import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/extensions.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/models.dart';
import 'package:http/http.dart' as http;

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
    getStats();
    super.initState();
  }

  Future<void> getStats() async {
    stats = settingsController.stats;
    setState(() {});
  }

  Future<DateTime> getLastUpdateDateTime() async {
    try {
      final response = await http.get(Uri.parse(lastCommitApi));
      final json = jsonDecode(response.body);
      final date = DateTime.parse(json['commit']['commit']['author']['date']);
      return date;
    } catch (e) {
      throw Exception('Failed to load last update date');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      body: StreamBuilder<DocumentSnapshot>(
          stream:
              _firestore.collection(collectionProd).doc('features').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            Map<String, dynamic> remoteSettings;
            if (snapshot.hasError) {
              remoteSettings = settingsController.getLocalSettings();
            } else {
              remoteSettings = snapshot.data!.data() as Map<String, dynamic>;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  !remoteSettings['theme']
                      ? const SizedBox()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _subtitle('Theme'),
                            ToggleButtons(
                                children: const [
                                  Text('Light'),
                                  Text('Dark'),
                                  Text('System'),
                                ],
                                constraints: const BoxConstraints(
                                    minWidth: 80, minHeight: 40),
                                onPressed: (int index) {
                                  print(index);
                                  ThemeMode theme = ThemeMode.light;
                                  switch (index) {
                                    case 0:
                                      theme = ThemeMode.light;
                                      break;
                                    case 1:
                                      theme = ThemeMode.dark;
                                      break;
                                    case 2:
                                      theme = ThemeMode.system;
                                      break;
                                  }
                                  settingsController.updateThemeMode(theme);
                                },
                                isSelected: [
                                  settingsController.themeMode ==
                                      ThemeMode.light,
                                  settingsController.themeMode ==
                                      ThemeMode.dark,
                                  settingsController.themeMode ==
                                      ThemeMode.system,
                                ]),
                          ],
                        ),
                  !remoteSettings['theme'] ? const SizedBox() : const Divider(),
                  // !remoteSettings['difficulty']
                  //     ? const SizedBox()
                  //     : Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           _subtitle('Difficulty'),
                  //           ToggleButtons(
                  //               constraints: const BoxConstraints(
                  //                   minWidth: 80, minHeight: 40),
                  //               children: const [
                  //                 Text('Easy'),
                  //                 Text('Medium'),
                  //                 Text('Hard'),
                  //               ],
                  //               onPressed: (int index) {
                  //                 print(index);
                  //                 final _selectedDifficulty =
                  //                     Difficulty.fromToggleIndex(index);
                  //                 final _puzzle =
                  //                     gameController.gameState.puzzle;
                  //                 if (_selectedDifficulty !=
                  //                     Difficulty.medium) {
                  //                   /// If game has not started change the settings
                  //                   if (_puzzle.result == PuzzleResult.none) {
                  //                     settingsController
                  //                         .setDifficulty(_selectedDifficulty);
                  //                     gameController.gameState.puzzle =
                  //                         _puzzle.copyWith(
                  //                             difficulty: _selectedDifficulty);
                  //                     gameController.gameState =
                  //                         gameController.gameState;
                  //                   } else {
                  //                     Utility.showMessage(context,
                  //                         "The settings will be applied to the next puzzle");
                  //                   }
                  //                 }
                  //               },
                  //               isSelected: [
                  //                 settingsController.difficulty ==
                  //                     Difficulty.easy,
                  //                 settingsController.difficulty ==
                  //                     Difficulty.medium,
                  //                 settingsController.difficulty ==
                  //                     Difficulty.hard,
                  //               ]),
                  //         ],
                  //       ),
                  // !remoteSettings['difficulty']
                  //     ? const SizedBox()
                  //     : const Divider(),
                  !remoteSettings['stats']
                      ? const SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _subtitle('Score'),
                            _stats('Played', '${stats.total}'),
                            _stats('Win', '${stats.won}'),
                            _stats('Lose', '${stats.lost}'),
                            const Divider(),
                          ],
                        ),
                  const Expanded(child: SizedBox()),
                  !kIsWeb
                      ? const SizedBox()
                      : Center(
                          child: FutureBuilder(
                            builder: (BuildContext context,
                                AsyncSnapshot<DateTime> snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  'Last Updated: ${snapshot.data?.toLocal().standardDate()}',
                                  // style: Theme.of(context).textTheme.titleSmall!,
                                );
                              }
                              return const SizedBox();
                            },
                            future: getLastUpdateDateTime(),
                          ),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Copyright © 2022 Widget Media Labs ',
                          style: Theme.of(context).textTheme.bodyMedium!),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text('v${settingsController.version}')),
                  )
                ],
              ),
            );
          }),
    );
  }
}
