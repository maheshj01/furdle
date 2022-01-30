import 'package:flutter/material.dart';
import 'package:furdle/models/models.dart';
import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController() {
    _settingsService ??= SettingsService();
    loadSettings();
  }

  // Make SettingsService a private variable so it is not used directly.
  SettingsService? _settingsService;

  void gameOver(Puzzle puzzle) {
    _settingsService!.updatePuzzleStats(puzzle);
    notifyListeners();
  }

  Stats get stats => _settingsService!.stats;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  ThemeMode? _themeMode;

  Difficulty get difficulty => _settingsService!.difficulty;

  set difficulty(Difficulty value) {
    _settingsService!.difficulty = value;
    notifyListeners();
  }

  bool get isFurdleMode => _settingsService!.isFurdleMode;

  set isFurdleMode(bool value) {
    _settingsService!.isFurdleMode = value;
    notifyListeners();
  }

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode? get themeMode => _themeMode;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    await _settingsService!.configTheme();
    await _settingsService!.loadFurdle();
    _themeMode = await _settingsService!.themeMode();
    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    // Dot not perform any work if null or new and old ThemeMode are identical
    if (newThemeMode == null || (newThemeMode == _themeMode)) return;

    // Otherwise, store the new theme mode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService!.updateThemeMode(newThemeMode);
  }
}
