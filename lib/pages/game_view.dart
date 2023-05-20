import 'package:flutter/material.dart';
import 'package:furdle/exports.dart';
import 'package:furdle/models/game_state.dart';

enum KeyState {
  /// letter is present in the right spot
  /// green color
  exists(3),

  /// letter is present in the wrong spot
  /// orange color
  misplaced(2),

  /// letter is not present in any spot
  /// black color
  notExists(1),

  /// letter is empty
  /// grey color
  isDefault(0);

  final int priority;
  const KeyState(this.priority);

  int toPriority() => priority;
}

class FurdleGrid extends StatelessWidget {
  const FurdleGrid({Key? key, required this.state}) : super(key: key);
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    Size? gridSize = state.puzzle.size;
    bool isPlayed = state.puzzle.moves > 0;
    bool isGameOver = state.isGameOver;
    double cellSize = _size.width < 600 ? 65 : 70;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            for (int i = 0; i < gridSize.height; i++)
              Row(
                children: [
                  for (int j = 0; j < gridSize.width; j++)
                    FurdleCell(
                      i: i,
                      j: j,
                      cellSize: cellSize,
                      cellState: state.cells[i][j],
                      isSubmitted: isGameOver ? i <= state.row : i < state.row,
                      isAlreadyPlayed: isPlayed,
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class FurdleCell extends StatefulWidget {
  final int i;
  final int j;
  final double cellSize;
  FCellState? cellState;

  /// whether or not a word is submitted
  /// if true it will show the colors
  /// of the submitted word in the grid
  bool isSubmitted = false;
  bool isAlreadyPlayed = false;

  FurdleCell(
      {Key? key,
      required this.i,
      required this.j,
      this.cellState,
      this.isSubmitted = false,
      this.isAlreadyPlayed = false,
      this.cellSize = 80})
      : super(key: key);

  @override
  State<FurdleCell> createState() => _FurdleCellState();
}

class _FurdleCellState extends State<FurdleCell>
    with SingleTickerProviderStateMixin {
  Color stateToColor(KeyState state, bool isSubmitted) {
    if (!isSubmitted) {
      return Colors.grey;
    }
    switch (state) {
      case KeyState.exists:
        return green;
      case KeyState.notExists:
        return black;
      case KeyState.misplaced:
        return yellow;
      case KeyState.isDefault:
        return grey;
    }
  }

  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceIn,
    ));
    if (widget.isAlreadyPlayed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant FurdleCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cellState != oldWidget.cellState) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.cellState ??= FCellState.defaultState();
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Container(
              width: widget.cellSize,
              height: widget.cellSize,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color:
                      stateToColor(widget.cellState!.state, widget.isSubmitted),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(
                widget.cellState!.character.toUpperCase(),
                style: TextStyle(
                    fontSize: widget.cellSize * 0.4 * _animation.value,
                    color: Colors.white),
              ));
        });
  }
}
