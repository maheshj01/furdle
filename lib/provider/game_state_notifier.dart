import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/provider/keyboard_notifier.dart';
import 'package:furdle/utils/word.dart';

class GameStateNotifier extends StateNotifier<GameState> {
  final KeyboardNotifier keyboardNotifier;
  GameStateNotifier({
    required this.keyboardNotifier,
  }) : super(GameState.instance());

  void startGame() {
    final index = Random().nextInt(furdleList.length);
    final targetWord = furdleList[index];
    print("targetWord: $targetWord");
    state =
        state.copyWith(status: GameStatus.inprogress, targetWord: targetWord);
  }

  void addLetter(String letter) {
    final currentColumn = state.column;
    final currentRow = state.row;
    if (currentRow < state.size.height && currentColumn < state.size.width) {
      final character = state.cells[currentRow][currentColumn].character;
      if (character.isNotEmpty && currentColumn == state.size.width - 1) {
        return;
      }
      final newCell = CellState(cellType: Cell.unknown, character: letter);
      final cells = state.cells;
      cells[currentRow][currentColumn] = newCell;
      final isLastColumn = currentColumn == state.size.width - 1;
      state = state.copyWith(
        column: isLastColumn ? currentColumn : currentColumn + 1,
        cells: cells,
      );
    }
  }

  void deleteLetter() {
    final currentColumn = state.column;
    final currentRow = state.row;
    if (currentColumn >= 0) {
      final cells = state.cells;
      cells[currentRow][currentColumn] =
          CellState(cellType: Cell.empty, character: '');
      final isFirstColumn = currentColumn == 0;
      state = state.copyWith(
          cells: cells, column: isFirstColumn ? 0 : currentColumn - 1);
    }
  }

  SubmitWordResult submitWord() {
    final currentWord = getCurrentWord();
    if (currentWord.length != state.size.width) {
      return SubmitWordResult.incomplete;
    } else if (currentWord == state.targetWord) {
      updateCells(currentWord);
      return SubmitWordResult.match;
    }
    // TODO: To Use a binary search to check if the word is in the list
    else if (furdleList.contains(currentWord)) {
      updateCells(currentWord);
      final submittedWords = state.submittedWords;
      submittedWords.add(currentWord);
      if (currentWord == state.targetWord) {
        state = state.copyWith(
            status: GameStatus.win, submittedWords: submittedWords);
        return SubmitWordResult.match;
      } else {
        state = state.copyWith(
            row: state.row + 1, column: 0, submittedWords: submittedWords);
        return SubmitWordResult.notMatch;
      }
    } else {
      return SubmitWordResult.invalid;
    }
  }

  void updateCells(String word) {
    final cells = state.cells;
    final targetWord = state.targetWord.isEmpty ? 'hello' : state.targetWord;
    for (int i = 0; i < word.length; i++) {
      if (word[i] == targetWord[i]) {
        cells[state.row][i] =
            CellState(cellType: Cell.match, character: word[i].toUpperCase());
      } else if (targetWord.contains(word[i])) {
        cells[state.row][i] = CellState(
            cellType: Cell.misplaced, character: word[i].toUpperCase());
      } else {
        cells[state.row][i] = CellState(
            cellType: Cell.notExists, character: word[i].toUpperCase());
      }
    }
    state = state.copyWith(cells: cells);
  }

  /// returns the word by concatenating the characters in the current row
  String getCurrentWord() {
    final currentRow = state.row;
    final currentWord =
        state.cells[currentRow].map((cell) => cell.character).join('');
    return currentWord.toLowerCase();
  }

  @override
  void dispose() {
    keyboardNotifier.dispose();
    super.dispose();
  }
}

class GameState {
  /// the id of the game an incremental value starting from 1
  final int id;

  /// the size of the grid
  /// default size is 5x5
  final GridSize size;

  /// the row of the grid where the user is currently typing
  final int row;

  /// the column of the grid where the user is currently typing
  final int column;

  /// Current game status (none, inprogress, win, lose)
  final GameStatus status;

  /// The target word/puzzle to solve
  final String targetWord;

  /// Current word being typed (for validation)
  final String currentWord;

  /// List of all words submitted so far
  final List<String> submittedWords;

  /// Grid cells state (character + cell state for each position)
  final List<List<CellState>> cells;

  /// Game difficulty level
  final Difficulty? difficulty;

  /// Whether the current word is valid
  final bool isCurrentWordValid;

  /// Last submitted word result
  final SubmitWordResult? lastSubmitResult;

  /// Game start time
  final DateTime? startTime;

  /// Game end time (if completed)
  final DateTime? endTime;

  /// Number of hints used
  final int hintsUsed;

  GameState({
    required this.id,
    this.size = const GridSize(width: 5, height: 6),
    required this.row,
    required this.column,
    required this.status,
    required this.targetWord,
    this.currentWord = '',
    this.submittedWords = const [],
    required this.cells,
    this.difficulty = Difficulty.medium,
    this.isCurrentWordValid = false,
    this.lastSubmitResult,
    this.startTime,
    this.endTime,
    this.hintsUsed = 0,
  });

  GameState copyWith({
    GameStatus? status,
    String? targetWord,
    List<List<CellState>>? cells,
    Difficulty? difficulty,
    bool? isCurrentWordValid,
    SubmitWordResult? lastSubmitResult,
    DateTime? startTime,
    DateTime? endTime,
    int? hintsUsed,
    int? row,
    int? column,
    GridSize? size,
    String? currentWord,
    List<String>? submittedWords,
  }) {
    return GameState(
      id: id,
      row: row ?? this.row,
      column: column ?? this.column,
      status: status ?? this.status,
      targetWord: targetWord ?? this.targetWord,
      cells: cells ?? this.cells,
      difficulty: difficulty ?? this.difficulty,
      isCurrentWordValid: isCurrentWordValid ?? this.isCurrentWordValid,
      lastSubmitResult: lastSubmitResult,
      startTime: startTime,
      endTime: endTime,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      currentWord: currentWord ?? this.currentWord,
      submittedWords: submittedWords ?? this.submittedWords,
      size: size ?? this.size,
    );
  }

  static GameState instance() {
    return GameState(
      id: 0,
      row: 0,
      column: 0,
      size: const GridSize(width: 5, height: 6),
      status: GameStatus.none,
      targetWord: '',
      cells: defaultGrid(),
      difficulty: Difficulty.medium,
      isCurrentWordValid: false,
      lastSubmitResult: null,
      startTime: null,
      endTime: null,
      hintsUsed: 0,
    );
  }

  static List<List<CellState>> defaultGrid() => List.generate(
        6,
        (row) => List.generate(
          5,
          (column) => CellState(character: '', cellType: Cell.empty),
        ),
      );

  // Helper getters
  bool get isGameOver => status == GameStatus.win || status == GameStatus.lose;
  bool get isGameWon => status == GameStatus.win;
  bool get isGameLost => status == GameStatus.lose;
  bool get canSubmit => currentWord.length == size.width && isCurrentWordValid;
}

class GridSize {
  final int width;
  final int height;

  const GridSize({
    required this.width,
    required this.height,
  });
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
  final Cell cellType;

  CellState({this.character = '', this.cellType = Cell.empty});
}

enum Cell {
  empty, // No letter entered (grey)
  match, // Letter in correct position (green)
  misplaced, // Letter in word but wrong position (yellow)
  notExists, // Letter not in word (black)
  unknown, // Unknown cell type because it's not yet submitted
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
//   final storage = ref.watch(storageServiceProvider);
  final keyboardNotifier = ref.watch(keyboardProvider.notifier);
  return GameStateNotifier(keyboardNotifier: keyboardNotifier);
});
