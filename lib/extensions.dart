import 'package:flutter/material.dart';
import 'package:furdle/constants/constants.dart';
import 'package:intl/intl.dart';

import 'models/models.dart';

extension FurdleTitle on String {
  bool isLetter() {
    return length == 1 && codeUnitAt(0) >= 65 && codeUnitAt(0) <= 90;
  }

  Difficulty toDifficulty() {
    switch (this) {
      case 'easy':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.medium;
    }
  }

  ThemeMode toTheme() {
    switch (this) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  PuzzleResult toPuzzleResult() {
    switch (this) {
      case 'win':
        return PuzzleResult.win;
      case 'lose':
        return PuzzleResult.lose;
      case 'inprogress':
        return PuzzleResult.inprogress;
      default:
        return PuzzleResult.none;
    }
  }

  Widget toTitle({double boxSize = 25}) {
    return Material(
      color: Colors.transparent,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (int i = 0; i < length; i++)
          Container(
              height: boxSize,
              width: boxSize,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(
                    horizontal: 2,
                  ) +
                  EdgeInsets.only(bottom: i.isOdd ? 8 : 0),
              child: Text(
                this[i].toUpperCase(),
                style: const TextStyle(
                    height: 1.1,
                    letterSpacing: 2,
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 5,
                        color: black,
                        offset: Offset(0, 1)),
                    BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 5,
                        color: black,
                        offset: Offset(2, -1)),
                  ],
                  color: i <= 1
                      ? green
                      : i < 4
                          ? yellow
                          : primaryBlue))
      ]),
    );
  }
}

const String dateFormatter = 'MMMM dd, y';
const String dateTimeFormatter = 'MMMM dd, y HH:mm';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// whether the current time has Surpassed `hoursUntilNextFurdle` hours
  /// since the specified time
  bool hasSurpassedHoursUntilNextFurdle() {
    final now = DateTime.now().toLocal();
    final DateTime nextPuzzleTime =
        toLocal().add(const Duration(hours: hoursUntilNextFurdle));
    return now.isAfter(nextPuzzleTime);
  }

  String formatDate() {
    final now = DateTime.now();
    final differenceInDays = getDifferenceInDaysWithNow();

    if (isSameDate(now)) {
      return 'Today';
    } else if (differenceInDays == 1) {
      return 'Yesterday';
    } else {
      return standardDate();
    }
  }

  String standardDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }

  //
  String formatDateTime() {
    final formatter = DateFormat(dateTimeFormatter);
    return formatter.format(this);
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}

extension TimeLeft on Duration {
  String timeLeftAsString() {
    int hours = inHours;
    int minutes = inMinutes;
    if (minutes < 0 || hours < 0) {
      return "0 hrs 0 mins";
    }
    if (minutes > 60) {
      hours = minutes ~/ 60;
      minutes = (minutes - hours * 60) % 60;
    }
    return '$hours hrs $minutes mins';
  }
}
