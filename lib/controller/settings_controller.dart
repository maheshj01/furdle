import 'package:flutter/material.dart';
import 'package:furdle/extensions.dart';
import 'package:furdle/models/models.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../service/settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController extends ChangeNotifier {
  // Make SettingsService a private variable so it is not used directly.
  SettingsService? _settingsService;
  late Settings _settings;

  String _version = '';

  String get version => _version;
  String? _deviceId;
  String get deviceId => _deviceId ?? '';

  set version(String value) {
    _version = value;
    notifyListeners();
  }

  bool isSameDate() {
    final now = DateTime.now();
    if (_settings.stats.total > 0) {
      final bool isSame = _settings.stats.puzzles.last.date!.isSameDate(now);
      return isSame;
    }
    return false;
  }

  ThemeMode get themeMode => _settings.themeMode;

  Stats get stats => _settings.stats;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  // Difficulty get difficulty => _settings.difficulty;

  bool get isFurdleMode => _settingsService!.isFurdleMode;

  set isFurdleMode(bool value) {
    _settingsService!.isFurdleMode = value;
    notifyListeners();
  }

  // Allow Widgets to read the user's preferred ThemeMode.

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  ///
  Future<void> loadSettings() async {
    _settingsService = SettingsService();
    await _settingsService!.init();
    _settings = Settings.initialize();
    _settings.themeMode = await getTheme();
    _settings.difficulty = await getDifficulty();
    _settings.stats = await _settingsService!.getStats();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    _deviceId = await _settingsService!.getDeviceId();
    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  Future<void> registerDevice() async {
    if (_deviceId != null) return;
    _deviceId = await _settingsService!.getUniqueDeviceId();
    await _settingsService!.setDeviceId(_deviceId!);
  }

  Future<Difficulty> getDifficulty() async {
    return _settingsService!.getDifficulty();
  }

  Future<void> setDifficulty(Difficulty diff) async {
    if (diff == _settings.difficulty) return;
    _settings.difficulty = diff;
    notifyListeners();
    _settingsService!.setDifficulty(diff);
  }

  Future<ThemeMode> getTheme() async {
    return await _settingsService!.getTheme();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    // Dot not perform any work if null or new and old ThemeMode are identical
    if (newThemeMode == null || (newThemeMode == _settings.themeMode)) return;

    // Otherwise, store the new theme mode in memory
    _settings.themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService!.setTheme(newThemeMode);
  }

  /// Update stats on Game over
  Future<void> addPuzzleToStats(Puzzle puzzle) async {
    stats.puzzles.add(puzzle);
    stats.setPuzzles(stats.puzzles);
    updateStats(stats);
  }

  Future<Stats> getStats() async {
    return _settingsService!.getStats();
  }

  Future<void> updateStats(Stats st) async {
    _settings.stats = st;
    notifyListeners();
    await _settingsService!.updateStats(st);
  }

  Map<String, dynamic> getLocalSettings() {
    return {
      'theme': true,
      'difficulty': false,
      'stats': true,
    };
  }

  Future<void> clear() async {
    _settingsService!.clear();
  }
}
