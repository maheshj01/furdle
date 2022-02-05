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

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension TimeLeft on Duration {
  String timeLeftAsString() {
    int hours = inHours;
    int minutes = inMinutes;
    if (minutes < 0 || hours < 0) {
      return "0 hrs 0 mins";
    }
    final seconds = inSeconds;
    if (minutes > 60) {
      hours = minutes ~/ 60;
      minutes = (minutes - hours * 60) % 60;
    }
    return '$hours hrs $minutes mins';
  }
}
