import 'package:flutter/material.dart';

import 'models.dart';

class Settings {
  Difficulty difficulty;
  ThemeMode themeMode;
  Stats stats;

  Settings({
    required this.difficulty,
    required this.themeMode,
    required this.stats,
  });

  Settings.initialize()
      : difficulty = Difficulty.medium,
        themeMode = ThemeMode.system,
        stats = Stats.initialStats();

  Settings copyWith({
    Difficulty? difficulty,
    ThemeMode? themeMode,
    Stats? stats,
  }) {
    return Settings(
      difficulty: difficulty ?? this.difficulty,
      themeMode: themeMode ?? this.themeMode,
      stats: stats ?? this.stats,
    );
  }

  void init() {
    difficulty = Difficulty.medium;
    themeMode = ThemeMode.system;
    stats = Stats.initialStats();
  }
}
