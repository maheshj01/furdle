import 'package:flutter/cupertino.dart';
import 'package:flutter_template/pages/furdle.dart';

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

  int _furdleSize = 5;

  int get furdleSize => _furdleSize;

  String _furdlePuzzle = '';

  String get furdlePuzzle => _furdlePuzzle;

  set furdlePuzzle(String value) {
    _furdlePuzzle = value;
    notifyListeners();
  }

  ///. if the word is complete
  /// and can be submitted
  bool isFilled() {
    /// last letter of current row is Non empty
    return _cells[row][furdleSize - 1].character.isNotEmpty;
  }

  set furdleSize(int value) {
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
    _cells[row][column] = cell;
    if (_column < furdleSize - 1) {
      _column++;
    }
    notifyListeners();
  }

  bool submit() {
    _column = 0;
    notifyListeners();
    final word = currentWord();
    _row++;
    return word == furdlePuzzle;
  }

  /// unsubmitted word in thr current row
  String currentWord() {
    String word = '';
    for (int i = 0; i < furdleSize; i++) {
      final letter = _cells[row][i].character;
      word += _cells[row][i].character;
    }
    return word;
  }

  void removeCell() {
    _cells[row][column] = FCellState.defaultState();
    if (_column > 0) {
      _column -= 1;
    }
    notifyListeners();
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

  // void addCell(FCellState cell) {
  //   value.addCell(cell);
  // }

  void notify() {
    notifyListeners();
  }
}
