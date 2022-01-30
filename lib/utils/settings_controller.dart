import 'package:flutter/material.dart';

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

  List<Puzzle> get puzzles => _settingsService!.puzzles;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  ThemeMode? _themeMode;

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

enum PuzzleResult { win, lose }

class Puzzle {
  late String _puzzle;
  late PuzzleResult _result;
  late int _moves;
  late int _puzzleSize;
  late DateTime _date;

  Puzzle.initialStats({String puzzle = ''}) {
    _puzzle = puzzle;
    _result = PuzzleResult.lose;
    _moves = 0;
    _puzzleSize = 0;
    _date = DateTime.now();
  }

  Puzzle.fromStats(String puzzle, PuzzleResult result, int moves,
      int puzzleSize, DateTime date) {
    _puzzle = puzzle;
    _result = result;
    _moves = moves;
    _puzzleSize = puzzleSize;
    _date = date;
  }

  Puzzle(
      {required String puzzle,
      required PuzzleResult result,
      required int moves,
      required int puzzleSize,
      required DateTime date}) {
    _puzzle = puzzle;
    _result = result;
    _moves = moves;
    _puzzleSize = puzzleSize;
    _date = DateTime.now();
  }

  String get puzzle => _puzzle;
  PuzzleResult get result => _result;
  int get moves => _moves;
  int get puzzleSize => _puzzleSize;
  DateTime get date => _date;

  set moves(int value) {
    _moves = value;
  }

  set puzzleSize(int value) {
    _puzzleSize = value;
  }

  set puzzle(String value) {
    _puzzle = value;
  }

  set result(PuzzleResult value) {
    _result = value;
  }

  set date(DateTime value) {
    _date = value;
  }

  void onMatchPlayed(Puzzle puzzle) {
    _result = puzzle.result;
    _moves = puzzle.moves;
    _puzzleSize = puzzle.puzzleSize;
    _date = DateTime.now();
  }

  Map<String, Object> toJson() {
    return {
      'puzzle': _puzzle,
      'result': _result.name,
      'moves': _moves,
      'size': _puzzleSize,
      'date': _date.toString(),
    };
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      puzzle: json['puzzle'] as String,
      result: json['result'] == 'win' ? PuzzleResult.win : PuzzleResult.lose,
      moves: json['moves'] as int,
      puzzleSize: json['size'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
