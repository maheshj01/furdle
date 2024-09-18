import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furdle/models/game.dart';
import 'package:furdle/shared/extensions.dart';

import '../constants/constants.dart';
import '../utils/word.dart';

enum Difficulty {
  easy(7),
  medium(6),
  hard(5);

  final int difficulty;
  const Difficulty(this.difficulty);

  int toLevel() => difficulty;

  factory Difficulty.fromString(String df) {
    switch (df) {
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

  factory Difficulty.fromLevel(int level) {
    switch (level) {
      case 7:
        return Difficulty.easy;
      case 6:
        return Difficulty.medium;
      case 5:
        return Difficulty.hard;
      default:
        return Difficulty.medium;
    }
  }
  factory Difficulty.fromToggleIndex(int index) {
    switch (index) {
      case 0:
        return Difficulty.easy;
      case 1:
        return Difficulty.medium;
      case 2:
        return Difficulty.hard;
      default:
        return Difficulty.medium;
    }
  }

  List<List<FCellState>> toDefaultcells() {
    switch (this) {
      case Difficulty.easy:
        return List.generate(
            7, (i) => List.generate(5, (j) => FCellState.defaultState()));
      case Difficulty.medium:
        return List.generate(
            6, (i) => List.generate(5, (j) => FCellState.defaultState()));
      case Difficulty.hard:
        return List.generate(
            5, (i) => List.generate(5, (j) => FCellState.defaultState()));
      default:
        return List.generate(
            6, (i) => List.generate(5, (j) => FCellState.defaultState()));
    }
  }

  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'easy';
      case Difficulty.medium:
        return 'medium';
      case Difficulty.hard:
        return 'hard';
      default:
        return 'medium';
    }
  }

  Size toGridSize() {
    switch (this) {
      case Difficulty.easy:
        return const Size(5.0, 7.0);
      case Difficulty.medium:
        return const Size(5.0, 6.0);
      case Difficulty.hard:
        return const Size(5.0, 5.0);
      default:
        return const Size(5.0, 6.0);
    }
  }

  double factor() {
    switch (this) {
      case Difficulty.easy:
        return 2.4;
      case Difficulty.medium:
        return 2.4;
      case Difficulty.hard:
        return 2.5;
    }
  }
}

class Puzzle {
  int number;
  String puzzle;
  int moves;

  /// size of the puzzle
  /// grid Size width x height of the puzzle
  Size size;
  bool isOffline;
  DateTime? date;
  Difficulty difficulty;

  Puzzle(
      {this.number = 0,
      this.puzzle = '',
      this.date,
      this.moves = 0,
      this.size = const Size(5.0, 6.0),
      this.difficulty = Difficulty.medium,
      this.isOffline = false});

  factory Puzzle.initialize() {
    return Puzzle(
        number: 0,
        puzzle: '',
        moves: 0,
        size: const Size(5.0, 6.0),
        difficulty: Difficulty.medium,
        date: DateTime.now(),
        isOffline: false);
  }

  /// Create a new puzzle from the current puzzle
  factory Puzzle.forFriends(Puzzle puzzle) {
    return Puzzle(
        number: puzzle.number,
        puzzle: puzzle.puzzle,
        moves: 0,
        size: puzzle.size,
        difficulty: puzzle.difficulty,
        date: puzzle.date,
        isOffline: puzzle.isOffline);
  }

  Puzzle fromSnapshot(DocumentSnapshot snapshot) {
    return Puzzle(
      puzzle: snapshot.get('word'),
      number: snapshot.get('number'),
      date: (snapshot.get('date') as Timestamp).toDate().toLocal(),
      isOffline: false,
      size: Difficulty.medium.toGridSize(),
      difficulty: Difficulty.medium,
      moves: 0,
    );
  }

  // copywith constructor
  Puzzle copyWith(
      {int? number,
      String? puzzle,
      int? moves,
      Size? size,
      DateTime? date,
      DateTime? nextRun,
      Difficulty? difficulty,
      bool? isOffline}) {
    return Puzzle(
        number: number ?? this.number,
        puzzle: puzzle ?? this.puzzle,
        moves: moves ?? this.moves,
        size: size ?? this.size,
        date: date ?? this.date,
        difficulty: difficulty ?? this.difficulty,
        isOffline: isOffline ?? this.isOffline);
  }

  // Puzzle.fromStats(
  //     String puzzle,
  //     PuzzleResult result,
  //     int moves,
  //     Size size,
  //     DateTime date,
  //     Difficulty difficulty,
  //     int number,
  //     bool isOffline,
  //     List<List<FCellState>> cells) {
  //   cells = [];
  //   number = number;
  //   puzzle = puzzle;
  //   result = result;
  //   moves = moves;
  //   size = size;
  //   date = date;
  //   cells = cells;
  //   isOffline = isOffline;
  //   difficulty = difficulty;
  // }

  void onMatchPlayed(Puzzle puzzle) {
    moves = puzzle.moves;
    size = puzzle.size;
    date = DateTime.now();
    difficulty = puzzle.difficulty;
  }

  Map<String, Object> toJson() {
    return {
      'number': number,
      'puzzle': puzzle,
      'moves': moves,
      'size': '${size.width}x${size.height}',
      'date': date.toString(),
      'difficulty': difficulty.name
    };
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    final difficulty = json['difficulty'].toString().toDifficulty();
    return Puzzle(
        number: json['number'] as int,
        puzzle: json['puzzle'] as String,
        moves: json['moves'] as int,
        size: difficulty.toGridSize(),
        date: DateTime.parse(json['date'] as String),
        difficulty: difficulty);
  }

  Puzzle getRandomPuzzle() {
    Puzzle _newPuzzle = Puzzle.initialize();
    final randomNumber = Random().nextInt(AppConstants.maxWords);
    final word = furdleList[randomNumber];
    final _difficulty = Difficulty.medium;
    _newPuzzle = _newPuzzle.copyWith(
        puzzle: word,
        difficulty: _difficulty,
        isOffline: true,
        number: randomNumber,
        moves: 0,
        size: _newPuzzle.difficulty.toGridSize(),
        date: DateTime.now(),
        nextRun: DateTime.now().add(const Duration(days: 1)));

    return _newPuzzle;
  }
}
