// class for managing game services
// like stats, modes, difficulty, etc.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/extensions.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/game_state.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/service/iservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameService extends IGameService {
  static const _furdleStateKey = 'furdleState';
  late GameState _gameState;
  late SharedPreferences _sharedPreferences;

  // Make SettingsService a private variable so it is not used directly.
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GameState get gameState => _gameState;

  set gameState(GameState state) {
    _gameState = state;
    onGameStateChange(state);
  }

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
    _sharedPreferences = await SharedPreferences.getInstance();
    _gameState = GameState.instance();
  }

  /// returns either a new puzzle or the last played puzzle
  /// if the puzzle is not saved, gets a new puzzle from the server if available
  @override
  Future<GameState> loadGame() async {
    GameState _localState = await getSavedGame();
    Puzzle _puzzle = _localState.puzzle;
    final _gameResult = _localState.puzzle.result;
    if (_gameResult == PuzzleResult.win || _gameResult == PuzzleResult.lose) {
      if (_puzzle.date!.hasSurpassedHoursUntilNextFurdle()) {
        _gameState = await getNewGameState();
      }
    } else if (_gameResult == PuzzleResult.none) {
      _gameState = await getNewGameState();
      return _gameState;
    } else {
      /// If the game is inprogress and the puzzle is not saved by any chance
      /// get a new puzzle
      if (_puzzle.moves == 0 || _puzzle.puzzle.isEmpty) {
        _gameState = await getNewGameState();
      }
    }
    return _gameState;
  }

  /// get the puzzle from server
  /// if not available, get a random puzzle from the list
  /// The random puzzle will not count towards the stats
  Future<GameState> getNewGameState({Puzzle? challenge}) async {
    await clearLocalState();
    late Puzzle puzzle;
    if (challenge == null) {
      puzzle = Puzzle.initialize();
      DocumentReference<Map<String, dynamic>> _docRef =
          _firestore.collection(collectionProd).doc(statsProd);
      final snapshot = await _docRef.get();
      if (snapshot.exists) {
        puzzle = puzzle.fromSnapshot(snapshot);
      } else {
        puzzle = puzzle.getRandomPuzzle();
      }
    } else {
      puzzle = Puzzle.forFriends(challenge);
    }
    _gameState = _gameState.initNewState(puzzle);
    return _gameState;
  }

  Future<void> _saveCurrentState(GameState state) async {
    var st =  state.toJson();
    final map = json.encode(st);
    _sharedPreferences.setString(kGameState, map);
  }

  /// returns the last played puzzle
  Future<GameState> getSavedGame() async {
    final String savedPuzzle = _sharedPreferences.getString(kGameState) ?? '';
    if (savedPuzzle.isEmpty) {
      final newState = GameState(puzzle: Puzzle.initialize());
      return newState;
    }
    final decodedMap = jsonDecode(savedPuzzle) as Map<String, dynamic>;
    _gameState = GameState.fromJson(decodedMap);
    return _gameState;
  }

  // clear this state when a new Puzzle is being loaded
  Future<void> clearLocalState() async {
    _sharedPreferences.remove(kGameState);
  }

  @override
  Future<void> onGameOver(GameState state) async {
    await _analytics.logEvent(name: 'GameOver', parameters: {
      'result': _gameState.puzzle.result.name,
      'moves': _gameState.puzzle.moves
    });
  }

  @override
  Future<void> onGameStateChange(GameState state) async {
    await _saveCurrentState(state);
  }
}
