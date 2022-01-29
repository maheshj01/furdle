import 'package:flutter/material.dart';
import 'package:flutter_template/models/furdle.dart';

enum KeyState {
  /// letter is present in the right spot
  exists,

  /// letter is not present in any spot
  notExists,

  /// letter is present in the wrong spot
  misplaced,

  /// letter is empty
  isDefault
}

class Furdle extends StatefulWidget {
  int? size;
  Furdle({Key? key, required this.isDark, required this.fState, this.size = 5})
      : super(key: key);
  final bool isDark;
  FState fState;

  @override
  State<Furdle> createState() => _FurdleState();
}

class _FurdleState extends State<Furdle> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        FurdleGrid(
          state: widget.fState,
          gridSize: widget.size,
        ),
      ],
    );
  }
}

class FurdleGrid extends StatelessWidget {
  FurdleGrid({Key? key, this.gridSize, required this.state}) : super(key: key);

  final FState state;
  final int? gridSize;
  double cellSize = 80;

  @override
  Widget build(BuildContext context) {
    final kSize = MediaQuery.of(context).size.width / (gridSize! + 1);
    cellSize = kSize.clamp(40, 75);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            for (int i = 0; i < gridSize!; i++)
              Row(
                children: [
                  for (int j = 0; j < gridSize!; j++)
                    FurdleCell(
                      i: i,
                      j: j,
                      cellSize: cellSize,
                      cellState: state.cells[i][j],
                      isSubmitted: i < state.row,
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class FurdleCell extends StatelessWidget {
  final int i;
  final int j;
  final double cellSize;
  FCellState? cellState;
  bool isSubmitted = false;

  FurdleCell(
      {Key? key,
      required this.i,
      required this.j,
      this.cellState,
      this.isSubmitted = false,
      this.cellSize = 80})
      : super(key: key);

  Color stateToColor(KeyState state, bool isSubmitted) {
    if (!isSubmitted) {
      return Colors.grey;
    }
    switch (state) {
      case KeyState.exists:
        return Colors.green;
      case KeyState.notExists:
        return Colors.red;
      case KeyState.misplaced:
        return Colors.yellow;
      case KeyState.isDefault:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    cellState ??= FCellState.defaultState();
    return Container(
        width: cellSize,
        height: cellSize,
        color: stateToColor(cellState!.state, isSubmitted),
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        child: Text(
          cellState!.character.toUpperCase(),
          style: TextStyle(fontSize: cellSize * 0.4, color: Colors.white),
        ));
  }
}
