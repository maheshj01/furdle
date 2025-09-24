import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/colors.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/provider/settings_notifier.dart';
import 'package:furdle/utils/extensions.dart';

class GridBoard extends ConsumerWidget {
  const GridBoard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSize = ref.read(gameStateProvider).size;
    final gameState = ref.watch(gameStateProvider);
    final cells = gameState.cells;
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
                  cellState: cells[i][j],
                  cellSize: responsiveCellSize,
                ),
            ],
          ),
      ],
    );
  }
}

class GridCell extends ConsumerStatefulWidget {
  final CellState cellState;
  final double cellSize;

  GridCell({Key? key, this.cellSize = 80, required this.cellState})
      : super(key: key);

  @override
  ConsumerState<GridCell> createState() => _GridCellState();
}

class _GridCellState extends ConsumerState<GridCell>
    with SingleTickerProviderStateMixin {
  Color stateToColor(CellType state, bool isDarkMode) {
    switch (state) {
      case CellType.match:
        return AppColors.green;
      case CellType.notExists:
        return AppColors.black;
      case CellType.misplaced:
        return AppColors.yellow;
      case CellType.empty:
      case CellType.unknown:
        return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400;
      default:
        return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400;
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
    if (widget.cellState != oldWidget.cellState) {
      _controller.reset();
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cellState = widget.cellState;
    final isDarkMode = ref.watch(settingsNotifierProvider).isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Container(
              width: widget.cellSize,
              height: widget.cellSize,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.onSurface,
                    width: 2,
                  ),
                  color: stateToColor(cellState.cellType, isDarkMode),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(
                cellState.character,
                style: TextStyle(
                    fontSize: widget.cellSize * 0.5 * _animation.value,
                    color: Colors.white),
              ));
        });
  }
}
