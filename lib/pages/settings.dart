import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/controller/settings_notifier.dart';
import 'package:furdle/models/models.dart';
import 'package:furdle/shared/extensions.dart';
import 'package:furdle/shared/theme/theme.dart';
import 'package:furdle/utils/utility.dart';
import 'package:http/http.dart' as http;

import '../constants/strings.dart';

class SettingsPage extends ConsumerStatefulWidget {
  static String title = settingsTitle;
  static String path = '/settings';
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
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

    final themeMode = ref.watch(appThemeProvider);
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(SettingsPage.title),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              false // !remoteSettings['theme']
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
                              // settingsController.updateThemeMode(theme);
                              ref
                                  .read(appThemeProvider.notifier)
                                  .setTheme(theme);
                            },
                            isSelected: [
                              themeMode == ThemeMode.light,
                              themeMode == ThemeMode.dark,
                              themeMode == ThemeMode.system,
                            ]),
                      ],
                    ),
              false ? const SizedBox() : const Divider(),
              false
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _subtitle('Difficulty'),
                        ToggleButtons(
                            constraints: const BoxConstraints(
                                minWidth: 80, minHeight: 40),
                            children: const [
                              Text('Easy'),
                              Text('Medium'),
                              Text('Hard'),
                            ],
                            onPressed: (int index) {
                              print(index);
                              final _selectedDifficulty =
                                  Difficulty.fromToggleIndex(index);
                              if (_selectedDifficulty != settings.difficulty) {
                                /// If game has not started change the settings
                                // if (_puzzle.result == PuzzleResult.none) {
                                //   settingsController
                                //       .setDifficulty(_selectedDifficulty);
                                //   gameController.gameState.puzzle =
                                //       _puzzle.copyWith(
                                //           difficulty: _selectedDifficulty);
                                //   gameController.gameState =
                                //       gameController.gameState;
                                ref
                                    .read(appSettingsProvider.notifier)
                                    .updateDifficulty(_selectedDifficulty);
                              }
                              Utility.showMessage(context,
                                  "The settings will be applied to the next puzzle");
                            },
                            isSelected: [
                              settings.difficulty == Difficulty.easy,
                              settings.difficulty == Difficulty.medium,
                              settings.difficulty == Difficulty.hard,
                            ]),
                      ],
                    ),
              // !remoteSettings['difficulty']
              //     ? const SizedBox()
              //     : const Divider(),
              false // !remoteSettings['stats']
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _subtitle('Score'),
                        _stats('Played', '${settings.stats.total}'),
                        _stats('Win', '${settings.stats.won}'),
                        _stats('Lose', '${settings.stats.lost}'),
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
                child:
                    Align(alignment: Alignment.center, child: Text('v1.0.0')),
              )
            ],
          ),
        ));
  }
}
