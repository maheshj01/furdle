import 'package:flutter/material.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/utils/settings_controller.dart';
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

  late List<MatchResult> _matchResults;

  List<MatchResult> get matchResults => _matchResults;

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
  }

  Future<void> getStats() async {
    final list = _sharedPreferences.getStringList(kMatchHistoryKey) ?? [];
    _matchResults = list.map((e) {
      if (e == MatchResult.win.name) {
        return MatchResult.win;
      } else {
        return MatchResult.lose;
      }
    }).toList();
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

  Future<void> updateMatchStats(List<MatchResult> history) async {
    final stats = _sharedPreferences.setStringList(
        kMatchHistoryKey, history.map((e) => e.name).toList());
  }
}
