import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/pages/furdle.dart';
import 'package:furdle/utils/word.dart';
import '../constants/strings.dart';

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

  /// word matches the puzzle
  match
}

class FState extends ChangeNotifier {
  int _row = 0;

  int _column = 0;

  int get row => _row;

  int get column => _column;

  bool _isPuzzleSolved = false;

  bool get isPuzzleSolved => _isPuzzleSolved;

  Size _furdleSize = defaultSize;

  Size get furdleSize => _furdleSize;

  String _furdlePuzzle = '';

  String get furdlePuzzle => _furdlePuzzle;

  Puzzle _puzzle = Puzzle.initialize();

  /// current Puzzle
  Puzzle get puzzle => _puzzle;

  /// current Puzzle
  /// to save and retrieve incomplete puzzle
  set puzzle(Puzzle value) {
    _puzzle = value;
    notifyListeners();
  }

  /// word in a current row
  String _currentWord = '';

  /// word in a current row
  String get currentWord => _currentWord;

  /// add a letter to current word
  void addToWord(String letter) {
    _currentWord += letter;
  }

  /// removes last letter from current word
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

  set furdlePuzzle(String value) {
    _furdlePuzzle = value;
    notifyListeners();
  }

  set isPuzzleSolved(bool value) {
    _isPuzzleSolved = value;
    notifyListeners();
  }

  /// if the current row is complete
  /// and can be submitted
  bool isWordComplete() {
    /// last letter of current row is Non empty
    return _cells[row][furdleSize.width.toInt() - 1].character.isNotEmpty;
  }

  set furdleSize(Size value) {
    _furdleSize = value;
    notifyListeners();
  }

  set row(int value) {
    _row = value;
    notifyListeners();
  }

  set column(int value) {
    _column = value;
    notifyListeners();
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
    return furdlePuzzle[column] == letter;
  }

  int indexOf(letter) {
    return furdlePuzzle.toLowerCase().indexOf(letter);
  }

  void addCell(String character) {
    final occurence = puzzle.puzzle.split(character).toList().length - 1;
    FCellState cell = FCellState(
        character: character, state: characterToState(character, occurence));
    if (_column < furdleSize.width) {
      _cells[row][column] = cell;
      _column++;
      addToWord(character);
    }
    notifyListeners();
  }

  void removeCell() {
    if (_column > 0) {
      _column -= 1;
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
      _column = 0;
      _row++;
      isPuzzleSolved = word == furdlePuzzle;

      /// saves rows-1 times
      /// last row is saved on game over
      if (row < furdleSize.height) {
        saveFurdleState();
        FirebaseAnalytics analytics = FirebaseAnalytics.instance;
        analytics.logEvent(
            name: 'word guessed', parameters: {'word': word, 'moves': row - 1});
      }
      notifyListeners();
      return isPuzzleSolved ? Word.match : Word.valid;
    }
  }

  void saveFurdleState() {
    puzzle.cells = _cells;
    puzzle.moves = row;
    settingsController.saveFurdleState(puzzle);
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
    int attempts = _isPuzzleSolved ? row : 0;
    String generatedFurdle =
        '#${settingsController.stats.number} $attempts/${furdleSize.height.toInt()}\n\n';
    for (int i = 0; i < _furdleSize.height; i++) {
      String currentRow = '';
      for (int j = 0; j < _furdleSize.width; j++) {
        currentRow += stateToGrid(_cells[i][j].state);
      }
      currentRow += '\n';
      generatedFurdle += currentRow;
    }
    generatedFurdle += '\nhttps://furdle.web.app';
    _shareFurdle = generatedFurdle;
    notifyListeners();
  }

  /// unsubmitted word in thr current row
  void updateKeyBoardState({bool isUpdate = false}) {
    if (row >= _furdleSize.height) {
      row = furdleSize.height.toInt() - 1;
    }
    String word = '';
    if (isUpdate) {
      for (int j = 0; j < furdleSize.height; j++) {
        for (int i = 0; i < furdleSize.width; i++) {
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
      for (int i = 0; i < furdleSize.width; i++) {
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

class FurdleNotifier extends ValueNotifier<FState> {
  FurdleNotifier(FState state) : super(state);

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
