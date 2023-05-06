// class for managing game services
// like stats, modes, difficulty, etc.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/service/settings_service.dart';

class FurdleService {
  static const _furdleStateKey = 'furdleState';
  static const _statsKey = 'stats';

  // Make SettingsService a private variable so it is not used directly.
  SettingsService? _settingsService;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void gameOver(Puzzle puzzle) {
    // isAlreadyPlayed = true;
    _settingsService!.updatePuzzleStats(puzzle);

    _analytics.logEvent(
        name: 'GameOver',
        parameters: {'result': puzzle.result.name, 'moves': puzzle.moves});
  }
}
