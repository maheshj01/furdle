import 'package:flutter/material.dart';
import 'package:furdle/pages/furdle.dart';

/// State Color for either furdle or Keyboard
Color keyStateToColor(KeyState state, {bool isFurdle = false}) {
  switch (state) {
    case KeyState.exists:
      return Colors.green;
    case KeyState.notExists:
      return Colors.black;
    case KeyState.misplaced:
      return Colors.yellow;
    default:
      return isFurdle ? Colors.grey : Colors.white;
  }
}
