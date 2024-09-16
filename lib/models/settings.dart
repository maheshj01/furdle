import 'package:flutter/material.dart';

import 'models.dart';

class Settings extends ChangeNotifier {
  Difficulty difficulty;
  bool sound;
  Stats stats;

  Settings({
    required this.difficulty,
    required this.stats,
    this.sound = true,
  });

  Settings.initialize()
      : difficulty = Difficulty.medium,
        sound = true,
        stats = Stats.initialStats();

  Settings copyWith({
    Difficulty? difficulty,
    bool? sound,
    Stats? stats,
  }) {
    return Settings(
      difficulty: difficulty ?? this.difficulty,
      sound: sound ?? this.sound,
      stats: stats ?? this.stats,
    );
  }

  void init() {
    difficulty = Difficulty.medium;
    sound = true;
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

  void toggleSound() {
    sound = !sound;
    notifyListeners();
  }

  Settings.fromJson(Map json)
      : difficulty = Difficulty.fromString(json['difficulty']),
        sound = json['sound'],
        stats = Stats.fromJson(json['stats']);

  Map<String, dynamic> toJson() => {
        'difficulty': difficulty.name,
        'sound': sound,
        'stats': stats.toJson(),
      };
}
