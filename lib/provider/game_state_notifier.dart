import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/models/daily_challenge.dart';
import 'package:furdle/provider/hive_storage_provider.dart';
import 'package:furdle/provider/keyboard_notifier.dart';
import 'package:furdle/provider/settings_notifier.dart';
import 'package:furdle/service/completion_service.dart';
import 'package:furdle/service/firebase_challenge_service.dart';
import 'package:furdle/service/hive_storage_service.dart';
import 'package:furdle/state/game_state.dart';
import 'package:furdle/utils/utility.dart';
import 'package:furdle/utils/word.dart';

class GameStateNotifier extends StateNotifier<GameState> {
  final KeyboardNotifier keyboardNotifier;
  final HiveStorageService storageService;
  final FirebaseChallengeService challengeService;
  final CompletionService completionService;
  final Ref ref; // Add ref to access other providers
  // Count occurrences of each letter in target word
  final targetLetterCounts = <String, int>{};

  GameStateNotifier({
    required this.keyboardNotifier,
    required this.storageService,
    required this.challengeService,
    required this.completionService,
    required this.ref,
  }) : super(GameState.instance());

  Future<void> _saveGameState() async {
    try {
      await storageService.saveGameState(state);
    } catch (e) {
      print('Error saving game state: $e');
    }
  }

  Future<void> saveKeyboardState() async {
    try {
      await storageService.saveKeyboardState(keyboardNotifier.state);
    } catch (e) {
      print('Error saving keyboard state: $e');
    }
  }

  Future<GameState?> _loadGameState() async {
    try {
      final savedState = await storageService.getGameState();
      if (savedState != null) {
        final keyboardState = await storageService.getKeyboardState();
        if (keyboardState != null) {
          state = savedState;
          keyboardNotifier.restoreState(keyboardState);
          return savedState;
        }
      }
      return savedState;
    } catch (e) {
      print('Error loading game state: $e');
      return null;
    }
  }

  void _buildTargetLetterCounts(String targetWord) {
    targetLetterCounts.clear();
    for (int i = 0; i < targetWord.length; i++) {
      final letter = targetWord[i].toLowerCase();
      int freq = 1;
      if (targetLetterCounts.containsKey(letter)) {
        freq = targetLetterCounts[letter]! + 1;
      }
      targetLetterCounts[letter] = freq;
    }
  }

  Future<GameState?> startGame({bool playAgain = false}) async {
    // Fallback: check for any ongoing local game
    final savedState = await _loadGameState();
    // First, try to get the daily challenge from Firebase
    final dailyChallenge = await challengeService.getCurrentChallenge();
    // Check if user has already completed this challenge
    final hasCompleted = await storageService.isChallengeCompleted(dailyChallenge!.number);
    if (!hasCompleted && challengeService.isChallengeValid(dailyChallenge)) {
      // Check if we have an ongoing game for this challenge
      final savedChallenge = await storageService.getCurrentChallenge();

      if (savedState != null &&
          savedChallenge != null &&
          savedChallenge == dailyChallenge &&
          savedState.status == GameStatus.inprogress) {
        // Resume the ongoing challenge game
        final keyboardState = await storageService.getKeyboardState();
        if (keyboardState != null) {
          state = savedState;
          keyboardNotifier.restoreState(keyboardState);
          return null; // Ongoing challenge game resumed, no dialog needed
        }
      }

      // Start new daily challenge
      await _initializeChallengeGame(dailyChallenge);
      return null;
    }

    // If we have a completed game and user didn't click play again, return it to show dialog
    if (savedState != null && savedState.isGameOver && !playAgain) {
      return savedState.copyWith(nextGameDate: dailyChallenge.nextRun);
    }

    if (playAgain || savedState == null) {
      // No valid challenge or ongoing game, start random game
      initializeGame(nextGameDate: dailyChallenge.nextRun);
    }

    return null;
  }

  Future<void> _initializeChallengeGame(DailyChallenge challenge) async {
    state = GameState.instance().copyWith(
      id: challenge.number,
      status: GameStatus.inprogress,
      targetWord: challenge.word,
      gameType: GameType.daily,
      startTime: DateTime.now(),
      nextGameDate: challenge.nextRun,
    );
    keyboardNotifier.resetLetterStatuses();

    // Save the challenge and game state
    await storageService.saveCurrentChallenge(challenge);
    _saveGameState();
    saveKeyboardState();
  }

  void initializeGame({DateTime? nextGameDate}) {
    final index = Random().nextInt(furdleList.length);
    final targetWord = furdleList[index];
    // Create a fresh game state with a new ID
    final newId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    state = GameState.instance().copyWith(
        id: newId,
        status: GameStatus.inprogress,
        gameType: GameType.random,
        targetWord: targetWord,
        startTime: DateTime.now(),
        nextGameDate: nextGameDate);
    keyboardNotifier.resetLetterStatuses();
    keyboardNotifier.clearEventHistory();
    _saveGameState();
    saveKeyboardState();
  }

  void addLetter(String letter) {
    final currentColumn = state.column;
    final currentRow = state.row;

    if (currentRow >= state.size.height || currentColumn >= state.size.width) {
      return;
    }

    if (currentRow < 0 || currentColumn < 0) {
      return;
    }
    final character = state.cells[currentRow][currentColumn].character;
    if (currentColumn == state.size.width - 1 && character.isNotEmpty) {
      return;
    }

    final cells = state.cells;

    final newCell = CellState(cellType: CellType.unknown, character: letter.toUpperCase());
    cells[currentRow][currentColumn] = newCell;

    final nextColumn = (currentColumn + 1).clamp(0, state.size.width);

    state = state.copyWith(
      column: nextColumn,
      cells: cells,
    );
    _saveGameState();
  }

  void deleteLetter() {
    final currentColumn = state.column;
    final currentRow = state.row;

    if (currentRow >= state.size.height || currentColumn <= 0 || currentRow < 0) {
      return;
    }

    final cells = state.cells;

    final emptyCell = CellState(cellType: CellType.empty, character: '');
    cells[currentRow][currentColumn - 1] = emptyCell;

    state = state.copyWith(
      cells: cells,
      column: currentColumn - 1,
    );
    _saveGameState();
  }

  Future<SubmitWordResult> submitWord() async {
    final currentWord = getCurrentWord();
    if (currentWord.length != state.size.width) {
      return SubmitWordResult.incomplete;
    } else if (containsWord(currentWord, 0, furdleList.length - 1)) {
      updateCells(currentWord);
      final submittedWordsList = [...state.submittedWords, currentWord];
      print('target word: ${state.targetWord}, current word: $currentWord');
      if (currentWord == state.targetWord) {
        state = state.copyWith(
            status: GameStatus.win, submittedWords: submittedWordsList, endTime: DateTime.now());

        // Mark challenge as completed if this is a daily challenge
        // TODO: Only report completion if this is a daily challenge
        final savedChallenge = await storageService.getCurrentChallenge();
        if (savedChallenge != null) {
          await storageService.markChallengeCompleted(savedChallenge.number);

          // Report completion to the server for first completion tracking
          _reportCompletionToServer(savedChallenge, submittedWordsList.length);
        }

        _saveGameState();
        return SubmitWordResult.match;
      } else {
        GameStatus status = GameStatus.inprogress;
        if (state.row == state.size.height - 1) {
          status = GameStatus.lose;
        }
        state = state.copyWith(
            row: state.row + 1, column: 0, submittedWords: submittedWordsList, status: status);
        _saveGameState();
        return SubmitWordResult.notMatch;
      }
    } else {
      return SubmitWordResult.invalid;
    }
  }

  // binary search to check if the word is in the list
  bool containsWord(String word, int start, int end) {
    if (start > end) {
      return false;
    }
    final mid = (start + end) ~/ 2;
    final midWord = furdleList[mid];
    if (midWord == word) {
      return true;
    } else if (midWord.compareTo(word) < 0) {
      return containsWord(word, mid + 1, end);
    } else {
      return containsWord(word, start, mid - 1);
    }
  }

  /// Update the color of the cells based on the submitted word and the target word
  void updateCells(String word) {
    final cells = state.cells;
    final targetWord = state.targetWord;
    _buildTargetLetterCounts(state.targetWord);

    /// First pass: Mark exact matches (green) and track used letters
    final matchedPositions = <int>{};
    for (int i = 0; i < word.length; i++) {
      if (word[i].toLowerCase() == targetWord[i].toLowerCase()) {
        cells[state.row][i] = CellState(cellType: CellType.match, character: word[i].toUpperCase());
        matchedPositions.add(i);
        // Decrease count for this letter, since it's been matched
        final letter = word[i].toLowerCase();
        targetLetterCounts[letter] = targetLetterCounts[letter]! - 1;
      }
    }
    // second pass: mark yellows and blacks
    for (int i = 0; i < word.length; i++) {
      if (matchedPositions.contains(i)) {
        continue;
      }
      final letter = word[i].toLowerCase();
      if (targetLetterCounts.containsKey(letter) && targetLetterCounts[letter]! > 0) {
        cells[state.row][i] =
            CellState(cellType: CellType.misplaced, character: word[i].toUpperCase());
        targetLetterCounts[letter] = targetLetterCounts[letter]! - 1;
      } else {
        cells[state.row][i] =
            CellState(cellType: CellType.notExists, character: word[i].toUpperCase());
      }
    }

    // Update keyboard state based on the results
    _updateKeyboardState(word, cells[state.row]);

    state = state.copyWith(cells: cells);
    _saveGameState();
  }

  /// Update keyboard state to reflect letter statuses
  void _updateKeyboardState(String word, List<CellState> rowCells) {
    for (int i = 0; i < word.length; i++) {
      final letter = word[i].toUpperCase();
      final cellType = rowCells[i].cellType;

      // Get current keyboard state for this letter
      final currentKeyState = keyboardNotifier.state.getKeyState(letter);

      // Only update if the new status is "better" than the current one
      // Priority: match > misplaced > notExists > unknown
      if (_shouldUpdateKeyStatus(currentKeyState.cellType, cellType)) {
        keyboardNotifier.setLetterStatus(letter, cellType);
      }
    }
    saveKeyboardState();
  }

  /// Determine if we should update the key status based on priority
  bool _shouldUpdateKeyStatus(CellType currentStatus, CellType newStatus) {
    // Priority order: match > misplaced > notExists > unknown
    const priority = {
      CellType.match: 3,
      CellType.misplaced: 2,
      CellType.notExists: 1,
      CellType.unknown: 0,
      CellType.empty: 0,
    };

    return priority[newStatus]! > priority[currentStatus]!;
  }

  /// returns the word by concatenating the characters in the current row
  String getCurrentWord() {
    final currentRow = state.row;
    final currentWord = state.cells[currentRow].map((cell) => cell.character).join('');
    return currentWord.toLowerCase();
  }

  /// Reports completion to the server for Twitter functionality
  Future<void> _reportCompletionToServer(DailyChallenge challenge, int attempts) async {
    try {
      // Get Twitter username from settings
      final settings = ref.read(settingsNotifierProvider);
      String twitterUsername = '';

      if (settings.twitterUsername != null) {
        twitterUsername = settings.twitterUsername!.trim();
      }
      final gridState = Utility.generateFurdleGrid(state);
      print('gridState when reporting completion: $gridState, username: $twitterUsername');
      // This should be async and not block the game completion
      completionService
          .reportCompletion(
        challengeId: challenge.number,
        attempts: attempts,
        twitterUsername: twitterUsername,
        gridState: gridState,
      )
          .then((result) {
        if (result.isFirstCompletion) {
          print('🎉 Congratulations! You were the first to complete this challenge!');
        }
      }).catchError((error) {
        print('Failed to report completion to server: $error');
        // Don't block game completion for server errors
      });
    } catch (e) {
      print('Error reporting completion: $e');
      // Don't block game completion for errors
    }
  }

  @override
  void dispose() {
    keyboardNotifier.dispose();
    super.dispose();
  }
}

class GridSize {
  final int width;
  final int height;

  const GridSize({
    required this.width,
    required this.height,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }

  static GridSize fromJson(Map<String, dynamic> json) {
    return GridSize(
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }
}

enum GameStatus {
  none, // Game hasn't started
  inprogress, // Game is active
  win, // Player won
  lose, // Player lost
}

enum Difficulty {
  easy, // 7 attempts, 5 letters
  medium, // 6 attempts, 5 letters
  hard, // 5 attempts, 5 letters
}

enum GameType {
  /// Daily challenge
  daily,

  /// Random local game
  random,
}

enum SubmitWordResult {
  /// Word is valid and submitted
  valid,

  /// Word is too short
  incomplete,

  /// Word not in dictionary
  invalid,

  /// Word matches target (win condition)
  match,

  /// Word is valid but not the target word
  notMatch;

  String get friendlyString {
    switch (this) {
      case SubmitWordResult.valid:
        return "Valid word";
      case SubmitWordResult.incomplete:
        return "Word is too short";
      case SubmitWordResult.invalid:
        return "Word not in dictionary";
      case SubmitWordResult.match:
        return "Word matches target";
      case SubmitWordResult.notMatch:
        return "Word is valid but not the target word";
    }
  }
}

class CellState {
  final String character;
  final CellType cellType;

  CellState({this.character = '', this.cellType = CellType.empty});

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'cellType': cellType.index,
    };
  }

  static CellState fromJson(Map<String, dynamic> json) {
    return CellState(
      character: json['character'] as String? ?? '',
      cellType: CellType.values[json['cellType'] as int? ?? 0],
    );
  }
}

enum CellType {
  empty, // No letter entered (grey)
  match, // Letter in correct position (green)
  misplaced, // Letter in word but wrong position (yellow)
  notExists, // Letter not in word (black)
  unknown, // Unknown cell type because it's not yet submitted
}

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  final keyboardNotifier = ref.watch(keyboardProvider.notifier);
  final storageService = ref.watch(hiveStorageServiceProvider);
  return GameStateNotifier(
    keyboardNotifier: keyboardNotifier,
    storageService: storageService,
    challengeService: FirebaseChallengeService(),
    completionService: CompletionService(),
    ref: ref,
  );
});
