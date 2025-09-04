import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/old/controller/game_state_notifier.dart';
import 'package:furdle/old/models/game.dart';
import 'package:furdle/old/shared/theme/colors.dart';

class GridBoard extends ConsumerWidget {
  const GridBoard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final _size = MediaQuery.of(context).size;
    final gridSize = state.puzzle.size;
    final bool isPlayed = state.puzzle.moves > 0;
    final bool isGameOver = state.isGameOver;
    final double cellSize = _size.width < 600 ? _size.width / 6.5 : 70;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < gridSize.height; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < gridSize.width; j++)
                GridCell(
                  i: i,
                  j: j,
                  cellSize: cellSize,
                  isSubmitted: isGameOver ? i <= state.row : i < state.row,
                  isAlreadyPlayed: isPlayed,
                ),
            ],
          ),
      ],
    );
  }
}

class GridCell extends StatefulWidget {
  final int i;
  final int j;
  final double cellSize;

  /// whether or not a word is submitted
  /// if true it will show the colors
  /// of the submitted word in the grid
  bool isSubmitted = false;
  bool isAlreadyPlayed = false;

  GridCell(
      {Key? key,
      required this.i,
      required this.j,
      this.isSubmitted = false,
      this.isAlreadyPlayed = false,
      this.cellSize = 80})
      : super(key: key);

  @override
  State<GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<GridCell>
    with SingleTickerProviderStateMixin {
  Color stateToColor(Cell state, bool isSubmitted) {
    if (!isSubmitted) {
      return Colors.grey;
    }
    switch (state) {
      case Cell.match:
        return AppColors.green;
      case Cell.notExists:
        return AppColors.black;
      case Cell.misplaced:
        return AppColors.yellow;
      case Cell.empty:
        return AppColors.grey;
    }
  }

  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
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
  void didUpdateWidget(covariant GridCell oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Container(
              width: widget.cellSize,
              height: widget.cellSize,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(6)),
              child: Text(
                'A',
                style: TextStyle(
                    fontSize: widget.cellSize * 0.4 * _animation.value,
                    color: Colors.white),
              ));
        });
  }
}
