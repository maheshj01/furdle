import 'package:firebase_analytics/firebase_analytics.dart';
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

  /// whether user has cracked the puzzle
  bool isPuzzleCracked;
  bool isGameOver;
  Puzzle puzzle;

  GameState(
      {this.row = 0,
      this.column = 0,
      this.isGameOver = false,
      this.isPuzzleCracked = false,
      required this.puzzle});

  late bool _isAlreadyPlayed = false;

  bool get isAlreadyPlayed => _isAlreadyPlayed;

  set isAlreadyPlayed(bool value) {
    _isAlreadyPlayed = value;
    notifyListeners();
  }

  /// word in a current row
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

  String get shareFurdle => _shareFurdle;

  static final _KState _kState = _KState.initialize();

  _KState get kState => _kState;

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

  final List<List<FCellState>> _cells = [];

  List<List<FCellState>> get cells => _cells;

  set cells(List<List<FCellState>> cells) {
    _cells.clear();
    _cells.addAll(cells);
    updateKeyBoardState(isUpdate: true);
    notifyListeners();
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
      _cells[row][column] = FCellState.defaultState();
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
      isPuzzleCracked = word == puzzle.puzzle;

      /// saves rows-1 times
      /// last row is saved on game over
      if (row < puzzle.size.height) {
        isGameOver = false;
        saveFurdleState();
        FirebaseAnalytics analytics = FirebaseAnalytics.instance;
        analytics.logEvent(
            name: 'word guessed', parameters: {'word': word, 'moves': row - 1});
      }
      notifyListeners();
      return isPuzzleCracked ? Word.match : Word.valid;
    }
  }

  void saveFurdleState() {
    puzzle.cells = _cells;
    puzzle.moves = row;
    gameController.saveGameState(this);
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
        currentRow += stateToGrid(_cells[i][j].state);
      }
      currentRow += '\n';
      generatedFurdle += currentRow;
    }
    generatedFurdle += '\n$gameUrl';
    _shareFurdle = generatedFurdle;
    notifyListeners();
  }

  /// unsubmitted word in thr current row
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
    _cells.clear();
    notifyListeners();
  }
}

class _KState {
  final Map<String, KeyState> _keyboardState = {};

  Map<String, KeyState> get keyboardState => _keyboardState;

  _KState.initialize() {
    alphabets.split('').toList().forEach((element) {
      final state = FCellState(character: element, state: KeyState.isDefault);
      updateKey(state);
    });
  }

  void updateKey(FCellState key) {
    _keyboardState[key.character] = key.state;
  }
}

class FurdleNotifier extends ValueNotifier<GameState> {
  FurdleNotifier(GameState state) : super(state);

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notify();
  }

  void notify() {
    notifyListeners();
  }
}
