// class for managing game services
// like stats, modes, difficulty, etc.

import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/game_state.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/service/iservice.dart';
import 'package:furdle/utils/word.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameService extends IGameService {
  static const _furdleStateKey = 'furdleState';
  late GameState _gameState;
  late SharedPreferences _sharedPreferences;

  // Make SettingsService a private variable so it is not used directly.
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the last played puzzle
  /// returns the inprogress game if it was left inComplete
  static Puzzle getLastPlayedPuzzle() {
    final lastPlayedPuzzle = settingsController.stats.puzzle;
    // if (lastPlayedPuzzle.moves > 0 &&
    //     lastPlayedPuzzle.result == PuzzleResult.inprogress) {
    // }
    return lastPlayedPuzzle;
  }

  @override
  Future<void> initialize() async {
    _gameState = GameState(
      puzzle: Puzzle.initialize(),
    );
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  /// returns either a new puzzle or the last played puzzle
  /// if the puzzle is not saved, gets a new puzzle from the server
  @override
  Future<Puzzle> loadGame() async {
    // bool _isFurdleMode = _sharedPreferences.getBool(kFurdleKey) ?? false;

    Puzzle _puzzle = await getSavedPuzzle();

    /// if the puzzle is not saved/, get a new puzzle
    if (_puzzle.result == PuzzleResult.none &&
        _puzzle.moves == 0 &&
        _puzzle.puzzle.isEmpty) {
      _puzzle = await getPuzzle();
    }
    _gameState.puzzle = _puzzle;
    return _gameState.puzzle;
  }

  /// get the puzzle from server
  /// if not available, get a random puzzle from the list
  /// The random puzzle will not count towards the stats
  Future<Puzzle> getPuzzle() async {
    Puzzle puzzle = Puzzle.initialize();
    DocumentReference<Map<String, dynamic>> _docRef =
        _firestore.collection(collectionProd).doc(statsProd);
    final snapshot = await _docRef.get();
    String word = '';
    if (snapshot.exists) {
      puzzle = puzzle.fromSnapshot(snapshot);
      puzzle.difficulty = settingsController.difficulty;
      puzzle.size = puzzle.difficulty.toGridSize();
      puzzle.cells = puzzle.difficulty.toDefaultcells();
    } else {
      puzzle.isOffline = true;
      final furdleIndex = Random().nextInt(maxWords);
      word = furdleList[furdleIndex];
    }
    _gameState.puzzle = puzzle;
    return puzzle;
  }

  Future<void> saveCurrentFurdle(Puzzle puzzle) async {
    final map = json.encode(puzzle.toJson());
    _sharedPreferences.setString(kPuzzleState, map);
  }

  Future<Puzzle> getSavedPuzzle() async {
    final String savedPuzzle = _sharedPreferences.getString(kPuzzleState) ?? '';
    if (savedPuzzle.isEmpty) {
      final newPuzzle = Puzzle.initialize();
      return newPuzzle;
    }
    final decodedMap = jsonDecode(savedPuzzle) as Map<String, dynamic>;
    _gameState.puzzle = Puzzle.fromJson(decodedMap);
    return _gameState.puzzle;
  }

  // we shouldn't clear Last played Puzzle anytime
  Future<void> clearSavedPuzzle() async {
    _sharedPreferences.remove(kPuzzleState);
  }

  @override
  Future<void> onGameOver(Puzzle puzzle) async {
    await _analytics.logEvent(name: 'GameOver', parameters: {
      'result': _gameState.puzzle.result.name,
      'moves': _gameState.puzzle.moves
    });
    saveCurrentFurdle(puzzle);
  }
}
