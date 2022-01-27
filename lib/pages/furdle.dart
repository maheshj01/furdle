import 'package:flutter/material.dart';
import 'package:flutter_template/utils/utility.dart';

enum KeyState { exists, notExists, misplaced, isDefault }

class Furdle extends StatefulWidget {
  final bool isDark;

  const Furdle({Key? key, required this.isDark}) : super(key: key);

  @override
  State<Furdle> createState() => _FurdleState();
}

class _FurdleState extends State<Furdle> {
  @override
  Widget build(BuildContext context) {
    print('isDark  ${widget.isDark}');
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        FurdleGrid(),
      ],
    );
  }
}

class FurdleGrid extends StatelessWidget {
  FurdleGrid({Key? key, this.size = 5}) : super(key: key);

  final double? size;
  double cellSize = 80;
  @override
  Widget build(BuildContext context) {
    final kSize = MediaQuery.of(context).size.width / (size! + 1);
    cellSize = kSize.clamp(40, 75);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            for (int i = 0; i < size!; i++)
              Row(
                children: [
                  for (int j = 0; j < size!; j++)
                    FurdleCell(
                      i: i,
                      j: j,
                      cellSize: cellSize,
                      color: Colors.grey,
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
  final Color color;

  const FurdleCell(
      {Key? key,
      required this.i,
      required this.j,
      required this.color,
      this.cellSize = 80})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cellSize,
      height: cellSize,
      color: color,
      margin: const EdgeInsets.all(2),
    );
  }
}
