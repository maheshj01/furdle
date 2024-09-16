import 'package:flutter/material.dart';

import 'models.dart';

class Settings extends ChangeNotifier {
  Difficulty difficulty;
  Stats stats;

  Settings({
    required this.difficulty,
    required this.stats,
  });

  Settings.initialize()
      : difficulty = Difficulty.medium,
        stats = Stats.initialStats();

  Settings copyWith({
    Difficulty? difficulty,
    ThemeMode? themeMode,
    Stats? stats,
  }) {
    return Settings(
      difficulty: difficulty ?? this.difficulty,
      stats: stats ?? this.stats,
    );
  }

  void init() {
    difficulty = Difficulty.medium;
    stats = Stats.initialStats();
  }

  void updateStats(Stats stats) {
    this.stats = stats;
    notifyListeners();
  }

  void updateDifficulty(Difficulty difficulty) {
    this.difficulty = difficulty;
    notifyListeners();
  }

  Settings.fromJson(Map json)
      : difficulty = Difficulty.values[json['difficulty']],
        stats = Stats.fromJson(json['stats']);

  Map<String, dynamic> toJson() => {
        'difficulty': difficulty.name,
        'stats': stats.toJson(),
      };
}
