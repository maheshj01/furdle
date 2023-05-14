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
      case 'exists':
        state = KeyState.exists;
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
  Difficulty difficulty;

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
      this.difficulty = Difficulty.medium,
      required this.puzzle});

  Map<String, Object> toJson() {
    return {
      'row': row,
      'column': column,
      'isGameOver': isGameOver,
      'puzzle': puzzle.toJson(),
      'difficulty': difficulty.toLevel(),
      'cells': cellsToMap(),
    };
  }

  factory GameState.instance() {
    final _difficulty = settingsController.difficulty;
    final _cells = _difficulty.toDefaultcells();
    return GameState(
        row: 0,
        column: 0,
        isGameOver: false,
        cells: _cells,
        difficulty: _difficulty,
        puzzle: Puzzle.initialize());
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    final _difficulty = Difficulty.fromLevel(json['difficulty']);
    final puzzleSize = _difficulty.toGridSize();

    final map = (json['cells'] as Map<String, dynamic>);
    List<List<FCellState>> cellList = [];
    for (int i = 0; i < puzzleSize.height; i++) {
      List<FCellState> list = [];
      for (int j = 0; j < puzzleSize.width; j++) {
        FCellState cell = FCellState.fromJson((map['$i']! as List<dynamic>)[j]);
        list.add(cell);
      }
      cellList.add(list);
    }

    return GameState(
        row: json['row'],
        cells: cellList,
        column: json['column'],
        difficulty: _difficulty,
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

  /// build current word for each letter entered
  void buildWord(String letter) {
    _currentWord += letter;
  }

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
    _initCells();
    notifyListeners();
    return this;
  }

  void _initCells() {
    cells = [];
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

  void setCells(List<List<FCellState>> kCells) {
    cells.clear();
    cells.addAll(kCells);
    updateKeyBoardState(isUpdate: true);
    notifyListeners();
  }

  Map<String, List<Map<String, String>>> cellsToMap() {
    final Map<String, List<Map<String, String>>> result = {};
    for (int i = 0; i < puzzle.size.height; i++) {
      List<Map<String, String>> list = [];
      for (int j = 0; j < puzzle.size.width; j++) {
        final json = cells[i][j].toJson();
        list.add(json);
      }
      result['$i'] = list;
    }
    return result;
  }

  KeyState characterToState(String letter, int count) {
    int index = indexOf(letter);
    final bool hasNoDuplicateLetters =
        count == 1 && currentWord.contains(letter);
    if (index < 0) {
      return KeyState.notExists;
    } else if (letterExists(index, letter)) {
      return KeyState.exists;
    } else {
      if (hasNoDuplicateLetters) {
        return KeyState.notExists;
      } else {
        return KeyState.misplaced;
      }
    }
  }

  bool letterExists(int index, String letter) {
    return puzzle.puzzle[column] == letter;
  }

  int indexOf(letter) {
    return puzzle.puzzle.toLowerCase().indexOf(letter);
  }

  void addCell(String character) {
    final occurence = puzzle.puzzle.split(character).toList().length - 1;
    FCellState cell = FCellState(
        character: character, state: characterToState(character, occurence));
    if (column < puzzle.size.width) {
      cells[row][column] = cell;
      column++;
      buildWord(character);
    }
    notifyListeners();
  }

  void removeCell() {
    if (column > 0) {
      column -= 1;

      /// set the cell to default state
      cells[row][column] = FCellState.defaultState();
      removeFromWord();
    }
    notifyListeners();
  }

  /// check if word is valid and present in list of words
  Word validate() {
    final isComplete = isWordComplete();
    if (!isComplete) {
      return Word.incomplete;
    } else {
      final word = currentWord;
      if (!furdleList.contains(word)) {
        return Word.invalid;
      }
      updateKeyBoardState();
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
      case KeyState.exists:
        return '🟩';
      case KeyState.notExists:
        return '⬛️';
    }
  }

  void generateFurdleGrid() {
    int attempts = isPuzzleCracked ? row : 0;
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

  void updateKeyBoardState({bool isUpdate = false}) {
    if (row >= puzzle.size.height) {
      row = puzzle.size.height.toInt() - 1;
    }
    String word = '';
    if (isUpdate) {
      for (int j = 0; j < puzzle.size.height; j++) {
        for (int i = 0; i < puzzle.size.width; i++) {
          final letter = cells[j][i].character;
          word += letter;
          final furdleState = cells[j][i].state;
          final keyState = kState.keyboardState[letter];

          /// if Key is misplaced or is not enetered
          if (keyState == KeyState.misplaced ||
              keyState == KeyState.isDefault) {
            //   final state = characterToKeyboardState(letter, currentState);
            kState.keyboardState[letter] = furdleState;
          }
        }
      }
    } else {
      for (int i = 0; i < puzzle.size.width; i++) {
        final letter = cells[row][i].character;
        word += letter;
        final furdleState = cells[row][i].state;
        final keyState = kState.keyboardState[letter];

        /// if Key is misplaced or is not enetered
        if (keyState == KeyState.misplaced || keyState == KeyState.isDefault) {
          //   final state = characterToKeyboardState(letter, currentState);
          kState.keyboardState[letter] = furdleState;
        }
      }
    }
    notifyListeners();
    // print('update keyboard state\n ${kState.keyboardState}');
  }

  KeyState characterToKeyboardState(String letter, KeyState? currentState) {
    int index = indexOf(letter);
    if (index < 0) {
      return KeyState.notExists;
    } else if (letterExists(index, letter)) {
      return KeyState.exists;
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
    notify();
  }

  void notify() {
    notifyListeners();
  }
}
