import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/models/game_state.dart';
import 'package:furdle/models/puzzle.dart';

final gameStateProvider = ChangeNotifierProvider<GameState>((ref) {
  return GameState(cells: initCells(), puzzle: Puzzle.initialize());
});

initCells() {
  final List<List<FCellState>> cellList = [];
  for (int i = 0; i < 6; i++) {
    final List<FCellState> list = [];
    for (int j = 0; j < 5; j++) {
      list.add(FCellState.defaultState());
    }
    cellList.add(list);
  }
  return cellList;
}
