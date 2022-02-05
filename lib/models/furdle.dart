import 'package:flutter/cupertino.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/main.dart';
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

  /// word in a current row
  String _currentWord = '';

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

  KeyState characterToState(String letter) {
    int index = indexOf(letter);
    if (index < 0) {
      return KeyState.notExists;
    } else if (letterExists(index, letter)) {
      return KeyState.exists;
    } else {
      return KeyState.misplaced;
    }
  }

  bool letterExists(int index, String letter) {
    return furdlePuzzle[column] == letter;
  }

  int indexOf(letter) {
    return furdlePuzzle.toLowerCase().indexOf(letter);
  }

  void addCell(String character) {
    FCellState cell =
        FCellState(character: character, state: characterToState(character));
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
      notifyListeners();
      return isPuzzleSolved ? Word.match : Word.valid;
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
    _shareFurdle = generatedFurdle;
    notifyListeners();
  }

  /// unsubmitted word in thr current row
  void updateKeyBoardState() {
    if (row >= _furdleSize.height) {
      row = furdleSize.height.toInt() - 1;
    }
    String word = '';
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

  set cells(List<List<FCellState>> cells) {
    _cells.clear();
    _cells.addAll(cells);
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
