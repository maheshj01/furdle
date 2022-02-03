import 'package:flutter/cupertino.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/main.dart';
import 'package:furdle/pages/furdle.dart';

class FCellState {
  String character;
  KeyState state;

  FCellState({this.character = '', this.state = KeyState.isDefault});

  FCellState.defaultState()
      : character = '',
        state = KeyState.isDefault;
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

  String _shareFurdle = '';

  String get shareFurdle => _shareFurdle;

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
  bool canBeSubmitted() {
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

  void addCell(FCellState cell) {
    if (_column < furdleSize.width) {
      _cells[row][column] = cell;
      _column++;
    }
    notifyListeners();
  }

  void removeCell() {
    if (_column > 0) {
      _column -= 1;
      _cells[row][column] = FCellState.defaultState();
    }
    notifyListeners();
  }

  bool submit() {
    _column = 0;
    final word = currentWord();
    _row++;
    isPuzzleSolved = word == furdlePuzzle;
    notifyListeners();
    return _isPuzzleSolved;
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
  String currentWord() {
    ///TODO: prevent overflow of row
    /// which happens in [submiit()]
    if (row >= _furdleSize.height) {
      row = furdleSize.height.toInt() - 1;
    }
    String word = '';
    for (int i = 0; i < furdleSize.width; i++) {
      word += _cells[row][i].character;
    }
    return word;
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
