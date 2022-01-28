import 'package:flutter/cupertino.dart';
import 'package:flutter_template/pages/furdle.dart';

class FCellState {
  final String character;
  final KeyState state;

  FCellState({this.character = '', this.state = KeyState.isDefault});

  FCellState.defaultState()
      : character = '',
        state = KeyState.isDefault;
}

class FState extends ChangeNotifier {
  int _row = 0;

  int get row => _row;

  int _cellSize = 0;

  int get cellSize => _cellSize;

  set cellSize(int value) {
    _cellSize = value;
    notifyListeners();
  }

  set row(int value) {
    _row = value;
    notifyListeners();
  }

  final List<FCellState> _cells = [];

  List<FCellState> get cells => _cells;

  void addCell(FCellState cell) {
    _cells.add(cell);
    print('added cell ${cell.character} ${cell.state}');
    notifyListeners();
    computeSize();
  }

  void computeSize() {
    int count = 0;
    _cells.forEach((cell) {
      if (cell.character.isNotEmpty) {
        count++;
      }
    });
    _cellSize = count;
    notifyListeners();
  }

  void removeCell() {
    _cells.removeLast();
    computeSize();
    notifyListeners();
  }

  void clear() {
    _cells.clear();
    notifyListeners();
  }

  set cells(List<FCellState> cells) {
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

  void notify(){
    notifyListeners();
  }
}
