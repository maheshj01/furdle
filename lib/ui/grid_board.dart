import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/old/shared/theme/colors.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/utils/extensions.dart';

class GridBoard extends ConsumerWidget {
  const GridBoard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSize = ref.read(gameStateProvider).size;

    final screenWidth = context.width;

    // Calculate cell size to fit the grid nicely on the screen
    // Account for margins (2px on each side) and padding
    final horizontalPadding = 32.0; // 16px on each side
    final cellMargin = 4.0; // 2px margin on each side of cell
    final availableWidth = screenWidth - horizontalPadding;
    final cellSize =
        (availableWidth - (gridSize.width - 1) * cellMargin) / gridSize.width;

    final minCellSize = 40.0;
    final maxCellSize = 65.0;
    final responsiveCellSize = cellSize.clamp(minCellSize, maxCellSize);
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
                  cellSize: responsiveCellSize,
                ),
            ],
          ),
      ],
    );
  }
}

class GridCell extends ConsumerStatefulWidget {
  final int i;
  final int j;
  final double cellSize;

  GridCell({Key? key, required this.i, required this.j, this.cellSize = 80})
      : super(key: key);

  @override
  ConsumerState<GridCell> createState() => _GridCellState();
}

class _GridCellState extends ConsumerState<GridCell>
    with SingleTickerProviderStateMixin {
  Color stateToColor(Cell state) {
    switch (state) {
      case Cell.match:
        return AppColors.green;
      case Cell.notExists:
        return AppColors.black;
      case Cell.misplaced:
        return AppColors.yellow;
      case Cell.empty:
      case Cell.unknown:
        return AppColors.grey;
      default:
        return Colors.grey;
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
    final gameState = ref.watch(gameStateProvider);
    final cellState = gameState.cells[widget.i][widget.j];
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Container(
              width: widget.cellSize,
              height: widget.cellSize,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: stateToColor(cellState.cellType),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(
                cellState.character,
                style: TextStyle(
                    fontSize: widget.cellSize * 1.5 * _animation.value,
                    color: Colors.white),
              ));
        });
  }
}
