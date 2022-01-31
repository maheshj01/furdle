import 'package:flutter/cupertino.dart';
import 'package:furdle/constants/const.dart';
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

  Size _furdleSize = defaultSize;

  Size get furdleSize => _furdleSize;

  String _furdlePuzzle = '';

  String get furdlePuzzle => _furdlePuzzle;

  set furdlePuzzle(String value) {
    _furdlePuzzle = value;
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
    notifyListeners();
    final word = currentWord();
    _row++;
    return word == furdlePuzzle;
  }

  /// unsubmitted word in thr current row
  String currentWord() {
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

  void notify() {
    notifyListeners();
  }
}
