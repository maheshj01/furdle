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

    final double responsiveBoxSize = _calculateResponsiveBoxSize(screenSize.width);

    return Container(
      width: screenSize.width,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.leading!,
          GameTitle(title: widget.title, boxSize: responsiveBoxSize),
          Row(children: widget.actions!)
        ],
      ),
    );
  }

  /// Calculate responsive box size based on screen width
  double _calculateResponsiveBoxSize(double screenWidth) {
    if (screenWidth < 360) {
      // Very small phones
      return context.sp(28);
    } else if (screenWidth < 400) {
      // Small phones
      return context.sp(30);
    } else if (screenWidth < 600) {
      // Medium phones
      return context.sp(32);
    } else {
      return context.sp(35);
    }
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
    // Calculate responsive font size based on box size
    final double fontSize = _calculateFontSize(boxSize);
    final double borderRadius = boxSize * 0.15;
    final double margin = _calculateMargin(boxSize);

    return Container(
      height: boxSize,
      width: boxSize,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(
            horizontal: margin,
          ) +
          EdgeInsets.only(bottom: isOdd ? boxSize * 0.25 : 0),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          height: 1.0, // Tighter line height for better centering
          letterSpacing: boxSize * 0.05, // Responsive letter spacing
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.w700, // Slightly bolder for better visibility
        ),
        textAlign: TextAlign.center,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Enhanced shadow for better depth
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.4),
            offset: Offset(0, boxSize * 0.08),
            blurRadius: boxSize * 0.3,
            spreadRadius: 0,
          ),
          // Subtle highlight for a "lifted" look
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.15),
            offset: Offset(0, boxSize * 0.02),
            blurRadius: boxSize * 0.1,
            spreadRadius: 0,
          ),
        ],
        color: color ?? AppColors.primary,
      ),
    );
  }

  /// Calculate responsive font size based on box size
  double _calculateFontSize(double boxSize) {
    if (boxSize < 35) {
      return boxSize * 0.5; // 50% of box size for small boxes
    } else if (boxSize < 45) {
      return boxSize * 0.55; // 55% for medium boxes
    } else {
      return boxSize * 0.6; // 60% for large boxes
    }
  }

  /// Calculate responsive margin based on box size
  double _calculateMargin(double boxSize) {
    return boxSize * 0.05; // 5% of box size for consistent spacing
  }
}
