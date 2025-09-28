import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/colors.dart' show AppColors;
import 'package:furdle/constants/colors.dart';
import 'package:furdle/utils/extensions.dart';

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
          GameTitle(title: widget.title, boxSize: context.sp(24)),
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
          LetterBox(
              letter: title[i],
              color: i <= 1
                  ? AppColors.green
                  : i < 4
                      ? AppColors.yellow
                      : AppColors.primary,
              boxSize: boxSize,
              isOdd: i.isOdd),
      ]),
    );
  }
}

class LetterBox extends StatelessWidget {
  final String letter;
  final double boxSize;
  final Color? color;
  final bool isOdd;
  const LetterBox(
      {super.key, required this.letter, required this.boxSize, this.color, this.isOdd = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: boxSize,
      width: boxSize,
      padding: const EdgeInsets.all(2),
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(
            horizontal: 2,
          ) +
          EdgeInsets.only(bottom: isOdd ? 8 : 0),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
            height: 1.1,
            letterSpacing: 2,
            fontSize: context.sp(16),
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          // Stronger, more realistic shadow
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.35),
            offset: const Offset(2, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          // Subtle highlight for a "lifted" look
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.10),
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
        color: color ?? AppColors.primary,
      ),
    );
  }
}
