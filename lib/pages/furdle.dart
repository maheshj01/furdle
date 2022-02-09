import 'package:flutter/material.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/exports.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/furdle.dart';
import 'package:furdle/models/puzzle.dart';

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
  Size? size;
  Furdle({Key? key, required this.fState, this.size = defaultSize})
      : super(key: key);
  FState fState;

  @override
  State<Furdle> createState() => _FurdleState();
}

class _FurdleState extends State<Furdle> {
  @override
  void initState() {
    super.initState();
    _initGrid();
  }

  @override
  void didUpdateWidget(covariant Furdle oldWidget) {
    if (oldWidget.size != widget.size || oldWidget.fState != widget.fState) {
      super.didUpdateWidget(oldWidget);
    }
  }

  void _initGrid() {
    Puzzle lastFurdle = settingsController.stats.puzzle;
    if (lastFurdle.moves > 0) {
      widget.fState.cells.clear();
      widget.fState.cells = lastFurdle.cells;
      widget.fState.puzzle = lastFurdle;
    } else {
      for (int i = 0; i < widget.size!.height; i++) {
        List<FCellState> row = [];
        for (int j = 0; j < widget.size!.width; j++) {
          row.add(FCellState.defaultState());
        }
        widget.fState.cells.add(row);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FurdleGrid(
      state: widget.fState,
      gridSize: widget.size,
    );
  }
}

class FurdleGrid extends StatelessWidget {
  FurdleGrid({Key? key, this.gridSize, required this.state}) : super(key: key);

  final FState state;
  final Size? gridSize;
  double cellSize = 80;

  double difficultyToDivideFactor() {
    switch (settingsController.difficulty) {
      case Difficulty.easy:
        return 2.4;
      case Difficulty.medium:
        return 2.4;
      case Difficulty.hard:
        return 2.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    double divideFactor = _size.width < 400 ? difficultyToDivideFactor() : 2.0;
    final kSize = _size.height / (gridSize!.height * divideFactor);
    bool isPlayed = state.puzzle.moves > 0;
    bool isGameOver = state.puzzle.result != PuzzleResult.inprogress;
    cellSize = kSize;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            for (int i = 0; i < gridSize!.height; i++)
              Row(
                children: [
                  for (int j = 0; j < gridSize!.width; j++)
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
  /// of the submitted word
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
        return Colors.green;
      case KeyState.notExists:
        return Colors.black87;
      case KeyState.misplaced:
        return Colors.yellow[800]!;
      case KeyState.isDefault:
        return Colors.grey;
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
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.cellState != oldWidget.cellState) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
