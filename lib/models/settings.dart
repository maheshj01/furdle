import 'package:flutter/material.dart';

import 'models.dart';

class Settings extends ChangeNotifier {
  Difficulty difficulty;
  bool sound;
  Stats stats;
  String deviceId;

  Settings({
    required this.difficulty,
    required this.stats,
    this.deviceId = '',
    this.sound = true,
  });

  Settings.initialize()
      : difficulty = Difficulty.medium,
        sound = true,
        deviceId = '',
        stats = Stats.initialStats();

  Settings copyWith({
    Difficulty? difficulty,
    bool? sound,
    String? deviceId,
    Stats? stats,
  }) {
    return Settings(
      difficulty: difficulty ?? this.difficulty,
      deviceId: deviceId ?? this.deviceId,
      sound: sound ?? this.sound,
      stats: stats ?? this.stats,
    );
  }

  void init() {
    difficulty = Difficulty.medium;
    sound = true;
    deviceId = '';
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
        deviceId = json['deviceId'],
        stats = Stats.fromJson(json['stats']);

  Map<String, dynamic> toJson() => {
        'difficulty': difficulty.name,
        'sound': sound,
        'deviceId': deviceId,
        'stats': stats.toJson(),
      };
}
