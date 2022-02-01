import 'dart:math';

import 'package:flutter/material.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/models/furdle.dart';

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

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final divideFactor = _size.width < 400 ? 2.4 : 2.0;
    final kSize = _size.height / (gridSize!.height * divideFactor);
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

class FurdleCell extends StatefulWidget {
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
        return Colors.red;
      case KeyState.misplaced:
        return Colors.yellow;
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
              color: stateToColor(widget.cellState!.state, widget.isSubmitted),
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              child: Text(
                widget.cellState!.character.toUpperCase(),
                style: TextStyle(
                    fontSize: widget.cellSize * 0.4 * _animation.value,
                    color: Colors.white),
              ));
        });
  }
}
