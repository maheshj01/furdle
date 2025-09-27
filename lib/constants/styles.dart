import 'package:flutter/material.dart';
import 'package:furdle/constants/constants.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/state/key_state.dart';
import 'package:furdle/ui/keyboard.dart';

/// mention style constants to be used across different pages in you app here
/// e.g borderRadius,textstyle,gradients etc

BoxBorder buttonBorder(bool isPressed, bool isDarkMode) {
  return Border.all(
    color: isPressed
        ? (isDarkMode ? Colors.white.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.7))
        : Colors.grey.withValues(alpha: isDarkMode ? 0.8 : 0.15),
    width: isPressed ? 2 : 1,
  );
}

BoxDecoration buttonDecoration(bool isDarkMode, bool isPressed, Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    border: buttonBorder(isPressed, isDarkMode),
    boxShadow: [
      if (isPressed)
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
    ],
  );
}

Color colorFromKeyState(KeyState keyState, bool isDarkMode) {
  if (keyState.event == KeyEventType.keyDown) {
    return Colors.blue.withValues(alpha: 0.2);
  }

  switch (keyState.cellType) {
    case CellType.match:
      return AppColors.green;
    case CellType.notExists:
      return AppColors.black;
    case CellType.misplaced:
      return AppColors.yellow;
    case CellType.empty:
    default:
      if (!isDarkMode) {
        return Colors.grey.withValues(alpha: 0.15);
      }
      return const Color.fromARGB(255, 46, 46, 46);
  }
}

Color textColorFromKeyState(KeyState keyState, bool isDarkMode) {
  if (keyState.event == KeyEventType.keyDown) {
    return isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700;
  }

  switch (keyState.cellType) {
    case CellType.match:
    case CellType.notExists:
      return Colors.white;
    case CellType.misplaced:
      return Colors.black;
    case CellType.unknown:
    case CellType.empty:
    default:
      if (isDarkMode) {
        return Colors.white;
      }
      return Colors.black87;
  }
}
