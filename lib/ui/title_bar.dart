import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/colors.dart' show AppColors;
import 'package:furdle/constants/colors.dart';

class TitleBar extends StatefulWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final String title;
  const TitleBar(
      {Key? key,
      this.leading,
      this.actions,
      required this.title,
      this.backgroundColor = Colors.transparent})
      : super(key: key);

  @override
  TitleBarState createState() => TitleBarState();
}

class TitleBarState extends State<TitleBar> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.leading!,
          GameTitle(title: widget.title),
          Row(children: widget.actions!)
        ],
      ),
    );
  }
}

/// Widget that converts string title to widget
class GameTitle extends ConsumerWidget {
  final String title;
  final double boxSize;
  const GameTitle({super.key, required this.title, this.boxSize = 25});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (int i = 0; i < title.length; i++)
          Container(
              height: boxSize,
              width: boxSize,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(
                    horizontal: 2,
                  ) +
                  EdgeInsets.only(bottom: i.isOdd ? 8 : 0),
              child: Text(
                title[i].toUpperCase(),
                style: const TextStyle(
                    height: 1.1,
                    letterSpacing: 2,
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 10,
                        color: AppColors.grey,
                        offset: Offset(0, 1)),
                    BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 10,
                        color: AppColors.grey,
                        offset: Offset(2, -1)),
                  ],
                  color: i <= 1
                      ? AppColors.green
                      : i < 4
                          ? AppColors.yellow
                          : AppColors.primary))
      ]),
    );
  }
}
