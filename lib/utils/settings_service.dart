import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  ThemeMode _themeMode = ThemeMode.system;

  bool _isFurdleMode = false;

  bool get isFurdleMode => _isFurdleMode;

  set isFurdleMode(bool value) {
    _sharedPreferences.setBool(kFurdleKey, value);
    _isFurdleMode = value;
  }

  late SharedPreferences _sharedPreferences;

  late Stats _stats;

  Difficulty _difficulty = Difficulty.medium;

  Difficulty get difficulty => _difficulty;

  set difficulty(Difficulty value) {
    _difficulty = value;
    _sharedPreferences.setString(kDifficultyKey, value.name);
  }

  Stats get stats => _stats;

  set stats(Stats value) {
    _stats = value;
  }

  Future<ThemeMode> themeMode() async {
    return _themeMode;
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
    _sharedPreferences.setBool(kThemeKey, theme == ThemeMode.dark);
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> loadFurdle() async {
    _isFurdleMode = _sharedPreferences.getBool(kFurdleKey) ?? false;
    _stats = Stats.initialStats();
    _stats = await getStats();
    _difficulty = await getDifficulty();
  }

  Future<Difficulty> getDifficulty() async {
    String difficulty =
        _sharedPreferences.getString(kDifficultyKey) ?? 'medium';
    return _difficulty = difficulty.toLowerCase() == 'easy'
        ? Difficulty.easy
        : difficulty.toLowerCase() == 'medium'
            ? Difficulty.medium
            : Difficulty.hard;
  }

  Future<Stats> getStats() async {
    try {
      final list = _sharedPreferences.getStringList(kMatchHistoryKey) ?? [];
      _stats.puzzles = list.map((e) {
        final puzzle = Puzzle.fromJson(jsonDecode(e) as Map<String, dynamic>);
        return puzzle;
      }).toList();
      return _stats;
    } catch (_) {
      return Stats.initialStats();
    }
  }

  Future<void> configTheme() async {
    WidgetsFlutterBinding.ensureInitialized();
    _sharedPreferences = await SharedPreferences.getInstance();
    final isDark = _sharedPreferences.getBool(kThemeKey);
    _themeMode = isDark == null
        ? ThemeMode.system
        : isDark
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  Future<void> updatePuzzleStats(Puzzle puzzle) async {
    _stats.puzzles.add(puzzle);
    final puzzleMapList =
        _stats.puzzles.map((e) => json.encode(e.toJson())).toList();
    _sharedPreferences.setStringList(kMatchHistoryKey, puzzleMapList);
  }
}
