import 'package:flutter/cupertino.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/pages/game_view.dart';
import 'package:furdle/utils/word.dart';

import '../constants/strings.dart';

/// Class to represent the state of a cell in the grid
/// character is the letter in the cell
/// state is the state of the character entered in the cell
class FCellState {
  String character;
  KeyState state;

  FCellState({this.character = '', this.state = KeyState.isDefault});

  FCellState.defaultState()
      : character = '',
        state = KeyState.isDefault;

  Map<String, String> toJson() {
    return {'character': character, 'state': state.name};
  }

  factory FCellState.fromJson(Map<String, dynamic> json) {
    KeyState state = KeyState.isDefault;
    switch (json['state']) {
      case 'isDefault':
        state = KeyState.isDefault;
        break;
      case 'match':
        state = KeyState.match;
        break;
      case 'misplaced':
        state = KeyState.misplaced;
        break;
      case 'notExists':
        state = KeyState.notExists;
        break;
      default:
        state = KeyState.notExists;
        break;
    }
    return FCellState(
      character: json['character'],
      state: state,
    );
  }
}

enum Word {
  /// length is less than 5
  valid,

  /// word is incomplete, length is less than 5
  incomplete,

  /// word not in list
  invalid,

  /// word matches the target word
  match
}

class GameState extends ChangeNotifier {
  int row;
  int column;

  bool isGameOver;

  /// the puzzle to be solved
  Puzzle puzzle;

  /// Defines the state of furdle grid
  /// This is also used to define the color of the keys
  /// in the keyboard
  List<List<FCellState>> cells;

  static _KState _kState = _KState.initialize();

  _KState get kState => _kState;

  bool get isPuzzleCracked => (puzzle.result == PuzzleResult.win && isGameOver);

  GameState(
      {this.row = 0,
      this.column = 0,
      this.isGameOver = false,
      this.cells = const [],
      required this.puzzle});

  Map<String, Object> toJson() {
    return {
      'row': row,
      'column': column,
      'isGameOver': isGameOver,
      'puzzle': puzzle.toJson(),
      'cells': cellsToMap(),
    };
  }

  factory GameState.instance() {
    final _difficulty = Difficulty.medium;
    final _cells = _difficulty.toDefaultcells();
    return GameState(
        row: 0,
        column: 0,
        isGameOver: false,
        cells: _cells,
        puzzle: Puzzle.initialize());
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    final _difficulty = Difficulty.fromString(json['puzzle']['difficulty']);
    final puzzleSize = _difficulty.toGridSize();

    final map = (json['cells'] as Map<String, dynamic>);
    List<List<FCellState>> cellList = [];
    for (int i = 0; i < puzzleSize.height; i++) {
      List<FCellState> list = [];
      for (int j = 0; j < puzzleSize.width; j++) {
        final FCellState cell =
            FCellState.fromJson((map['$i']! as List<dynamic>)[j]);
        list.add(cell);
      }
      cellList.add(list);
    }

    return GameState(
        row: json['row'],
        cells: cellList,
        column: json['column'],
        isGameOver: json['isGameOver'],
        puzzle: Puzzle.fromJson(json['puzzle']));
  }

  late bool _isAlreadyPlayed = false;

  bool get isAlreadyPlayed => _isAlreadyPlayed;

  set isAlreadyPlayed(bool value) {
    _isAlreadyPlayed = value;
    notifyListeners();
  }

  String _currentWord = '';

  /// word in a current row
  String get currentWord => _currentWord;

  /// update current word when a letter is removed
  /// by pressing backspace or delete
  void removeFromWord() {
    if (_currentWord.isNotEmpty) {
      _currentWord = _currentWord.substring(0, _currentWord.length - 1);
    }
  }

  String _shareFurdle = '';

  /// furdle grid to be shared
  String get shareFurdle => _shareFurdle;

  GameState initNewState(Puzzle pz) {
    puzzle = pz;
    _isAlreadyPlayed = false;
    isGameOver = false;
    _kState = _KState.initialize();
    row = 0;
    column = 0;
    _initCells();
    notifyListeners();
    return this;
  }

  void updateDifficulty(Difficulty difficulty) {
    puzzle.difficulty = difficulty;
    notifyListeners();
  }

  void _initCells() {
    cells = <List<FCellState>>[];
    final gridSize = puzzle.difficulty.toGridSize();
    for (int i = 0; i < gridSize.height; i++) {
      List<FCellState> row = [];
      for (int j = 0; j < gridSize.width; j++) {
        row.add(FCellState.defaultState());
      }
      cells.add(row);
    }
  }

  void updateKeyState(FCellState cellState) {
    _kState.updateKey(cellState);
    notifyListeners();
  }

  /// if the  word in current row equal to the width of the puzzle
  /// then the word is complete and can be validated
  bool isWordComplete() {
    final word = cells[row].map((e) => e.character).join('');
    return word.length == puzzle.size.width;
  }

  void updateKeyboard() {
    _updateKeyBoardState(updateRow: true);
  }

  void setCells(List<List<FCellState>> kCells) {
    cells.clear();
    cells.addAll(kCells);
    _updateKeyBoardState(updateRow: true);
    notifyListeners();
  }

  Map<String, List<Map<String, String>>> cellsToMap() {
    final Map<String, List<Map<String, String>>> result = {};
    for (int i = 0; i < cells.length; i++) {
      List<Map<String, String>> list = [];
      for (int j = 0; j < cells[0].length; j++) {
        final json = cells[i][j].toJson();
        list.add(json);
      }
      result['$i'] = list;
    }
    return result;
  }

  KeyState characterToState(String letter, int count, int i) {
    final int index = indexOf(letter);
    final bool hasNoDuplicateLetters =
        count == 1 && currentWord.contains(letter);
    if (index < 0) {
      return KeyState.notExists;
    } else if (isRightPosition(i, letter)) {
      return KeyState.match;
    } else {
      if (hasNoDuplicateLetters) {
        return KeyState.misplaced;
      } else {
        return KeyState.notExists;
      }
    }
  }

  /// whether the puzzle contains the letter at the given index
  bool isRightPosition(int index, String letter) {
    return puzzle.puzzle[index] == letter;
  }

  /// Returns the position of the first match of [pattern] in this string,
  /// starting at [start], inclusive:
  int indexOf(letter) {
    return puzzle.puzzle.toLowerCase().indexOf(letter);
  }

  void addCell(String character) {
    if (column == puzzle.size.width) return;

    final FCellState cell =
        FCellState(character: character, state: KeyState.isDefault);
    if (column < puzzle.size.width) {
      cells[row][column] = cell;
      _currentWord += character;
      column += 1;
    }
    notifyListeners();
  }

  void removeCell() {
    if (column != 0) {
      /// set the cell to default state
      column -= 1;
      cells[row][column] = FCellState.defaultState();
      removeFromWord();
    } else {
      column = 0;
      _currentWord = '';
    }
    notifyListeners();
  }

  /// check if word is valid and present in list of words
  Word submitWord() {
    final isComplete = isWordComplete();
    if (!isComplete) {
      return Word.incomplete;
    } else {
      final word = currentWord;
      if (!furdleList.contains(word)) {
        return Word.invalid;
      }
      for (int i = 0; i < word.length; i++) {
        final char = word[i];
        final occurence = puzzle.puzzle.split(char).toList().length - 1;
        final state = characterToState(char, occurence, i);
        final FCellState _cell = FCellState(character: char, state: state);
        cells[row][i] = _cell;
      }

      /// when the first word is submitted mark game as inprogress
      if (row == 0) {
        puzzle.result = PuzzleResult.inprogress;
      }
      _updateKeyBoardState(updateRow: true);
      _currentWord = '';
      column = 0;
      row++;
      if (word == puzzle.puzzle) {
        puzzle.result = PuzzleResult.win;
        isGameOver = true;
      }
      notifyListeners();
      return isPuzzleCracked ? Word.match : Word.valid;
    }
  }

  String stateToGrid(KeyState state) {
    switch (state) {
      case KeyState.isDefault:
        return '⬜️';
      case KeyState.misplaced:
        return '🟨';
      case KeyState.match:
        return '🟩';
      case KeyState.notExists:
        return '⬛️';
    }
  }

  /// Share furdle grid
  void generateFurdleGrid() {
    final int attempts = isPuzzleCracked ? row : 0;
    String generatedFurdle =
        '#${settingsController.stats.number} $attempts/${puzzle.size.height.toInt()}\n\n';
    for (int i = 0; i < puzzle.size.height; i++) {
      String currentRow = '';
      for (int j = 0; j < puzzle.size.width; j++) {
        currentRow += stateToGrid(cells[i][j].state);
      }
      currentRow += '\n';
      generatedFurdle += currentRow;
    }
    generatedFurdle += '\n$gameUrl';
    _shareFurdle = generatedFurdle;
    notifyListeners();
  }

  /// updates keyboard state for submitted row and all rows
  /// if isUpdate is true updates keyboard state for all rows
  /// else updates keyboard state for submitted row only
  void _updateKeyBoardState({bool updateRow = false}) {
    if (row >= puzzle.size.height) {
      row = puzzle.size.height.toInt() - 1;
    }
    for (int j = 0; j < puzzle.size.height; j++) {
      for (int i = 0; i < puzzle.size.width; i++) {
        final letter = cells[j][i].character;
        final cellState = cells[j][i].state;
        final keyState = kState.keyboardState[letter];

        /// get unsubmitted word
        if (j == row) {
          if (cellState == KeyState.isDefault) {
            _currentWord += letter;
          }
        }

        /// keyboard state should be updated based on priority of states in cells
        /// if Key is present in the right spot
        /// if Key is misplaced
        /// if Key is not present in the puzzle
        /// if Key is not entered
        if (cellState.toPriority() > 2 && keyState!.toPriority() < 3) {
          kState.keyboardState[letter] = cellState;
        } else if (cellState.toPriority() > 1 && keyState!.toPriority() < 2) {
          kState.keyboardState[letter] = cellState;
        } else if (cellState.toPriority() > 0 && keyState!.toPriority() < 1) {
          kState.keyboardState[letter] = cellState;
        } else if (cellState.toPriority() > 0 && keyState!.toPriority() == 0) {
          kState.keyboardState[letter] = cellState;
        }
      }
    }
    // } else {
    //   /// update submitted row in furdle grid
    //   for (int i = 0; i < puzzle.size.width; i++) {
    //     final letter = cells[row][i].character;
    //     final furdleState = cells[row][i].state;
    //     final keyState = kState.keyboardState[letter];

    //     /// if Key is misplaced or is not enetered
    //     if (keyState == KeyState.misplaced || keyState == KeyState.isDefault) {
    //       //   final state = characterToKeyboardState(letter, currentState);
    //       kState.keyboardState[letter] = furdleState;
    //     }
    //   }
    // }
    notifyListeners();
    // print('update keyboard state\n ${kState.keyboardState}');
  }

  KeyState characterToKeyboardState(String letter, KeyState? currentState) {
    final int index = indexOf(letter);
    if (index < 0) {
      return KeyState.notExists;
    } else if (isRightPosition(index, letter)) {
      return KeyState.match;
    } else {
      return KeyState.misplaced;
    }
  }

  void clear() {
    cells.clear();
    notifyListeners();
  }
}

class _KState {
  final Map<String, KeyState> _keyboardState = {};

  Map<String, KeyState> get keyboardState => _keyboardState;

  _KState.initialize() {
    _keyboardState.clear();
    alphabets.split('').toList().forEach((element) {
      final state = FCellState(character: element, state: KeyState.isDefault);
      updateKey(state);
    });
  }

  void updateKey(FCellState key) {
    _keyboardState[key.character] = key.state;
  }
}

class LoadingNotifier extends ValueNotifier<bool> {
  bool _isLoading = true;

  LoadingNotifier(super.value);

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    _notify();
  }

  void _notify() {
    notifyListeners();
  }
}
