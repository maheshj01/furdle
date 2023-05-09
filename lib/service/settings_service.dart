import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/extensions.dart';
import 'package:furdle/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  late SharedPreferences _sharedPreferences;
  final String _kDefaultDifficulty = 'medium';
  final String _kDefaultTheme = 'system';
  bool _isFurdleMode = false;

  bool get isFurdleMode => _isFurdleMode;

  set isFurdleMode(bool value) {
    _sharedPreferences.setBool(kFurdleKey, value);
    _isFurdleMode = value;
  }

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> setTheme(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
    _sharedPreferences.setString(kThemeKey, theme.name);
  }

  Future<ThemeMode> getTheme() async {
    final _theme = _sharedPreferences.getString(kThemeKey) ?? _kDefaultTheme;
    return _theme.toTheme();
  }

  Future<void> setDifficulty(Difficulty difficulty) async {
    _sharedPreferences.setString(kDifficultyKey, difficulty.toString());
  }

  Future<Difficulty> getDifficulty() async {
    final _difficulty =
        _sharedPreferences.getString(kDifficultyKey) ?? _kDefaultDifficulty;
    return _difficulty.toDifficulty();
  }

  Future<List<Puzzle>> getPuzzles() async {
    try {
      final list = _sharedPreferences.getStringList(kMatchHistoryKey) ?? [];
      final pastPuzzles = list.map((e) {
        final puzzle = Puzzle.fromJson(jsonDecode(e) as Map<String, dynamic>);
        return puzzle;
      }).toList();
      return pastPuzzles;
    } catch (_) {
      return [];
    }
  }

  Future<Stats> getStats() async {
    Stats _stats = Stats.initialStats();
    final data = _sharedPreferences.getString(kStatsKey);
    if (data != null) {
      final stats = jsonDecode(data) as Map<String, dynamic>;
      _stats = Stats.fromJson(stats);
    }
    return _stats;
  }

  Future<void> updateStats(Stats stats) async {
    _sharedPreferences.setString(kStatsKey, jsonEncode(stats.toJson()));
  }

  Future<void> clear() async {
    _sharedPreferences.clear();
  }
}
