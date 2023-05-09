import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furdle/extensions.dart';
import 'package:furdle/models/game_state.dart';

enum PuzzleResult {
  /// User has won the game
  win,

  /// User has lost the game
  lose,

  /// The game is in progress
  inprogress,

  /// The game has not been played
  none
}

enum Difficulty {
  easy(4),
  medium(5),
  hard(6);

  final int difficulty;
  const Difficulty(this.difficulty);

  int toDifficulty() => difficulty;

  Difficulty fromLevel() {
    switch (difficulty) {
      case 4:
        return Difficulty.easy;
      case 5:
        return Difficulty.medium;
      case 6:
        return Difficulty.hard;
      default:
        return Difficulty.medium;
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
        return const Size(5.0, 7.0);
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
  PuzzleResult result;
  int moves;

  /// size of the puzzle
  /// grid Size width x height of the puzzle
  Size size;
  bool isOffline;
  DateTime? date;
  Difficulty difficulty;
  List<List<FCellState>> cells;

  Puzzle(
      {this.number = 0,
      this.puzzle = '',
      this.date,
      this.result = PuzzleResult.inprogress,
      this.moves = 0,
      this.size = const Size(5.0, 6.0),
      this.difficulty = Difficulty.medium,
      this.cells = const [],
      this.isOffline = false});

  factory Puzzle.initialize() {
    return Puzzle(
        number: 0,
        puzzle: '',
        result: PuzzleResult.none,
        moves: 0,
        size: const Size(5.0, 6.0),
        difficulty: Difficulty.medium,
        cells: const [],
        date: DateTime.now(),
        isOffline: false);
  }

  Puzzle fromSnapshot(DocumentSnapshot snapshot) {
    return Puzzle(
      puzzle: snapshot['word'],
      number: snapshot['number'],
      date: (snapshot['date'] as Timestamp).toDate(),
      isOffline: false,
      result: PuzzleResult.inprogress,
      moves: 0,
    );
  }

  // copywith constructor
  Puzzle copyWith(
      {int? number,
      String? puzzle,
      PuzzleResult? result,
      int? moves,
      Size? size,
      DateTime? date,
      Difficulty? difficulty,
      List<List<FCellState>>? cells,
      bool? isOffline}) {
    return Puzzle(
        number: number ?? this.number,
        puzzle: puzzle ?? this.puzzle,
        result: result ?? this.result,
        moves: moves ?? this.moves,
        size: size ?? this.size,
        date: date ?? this.date,
        difficulty: difficulty ?? this.difficulty,
        cells: cells ?? this.cells,
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
    result = puzzle.result;
    moves = puzzle.moves;
    size = puzzle.size;
    date = DateTime.now();
    difficulty = puzzle.difficulty;
  }

  Map<String, List<Map<String, String>>> cellsToMap(
      List<List<FCellState>> cellList) {
    final Map<String, List<Map<String, String>>> result = {};
    for (int i = 0; i < size.height; i++) {
      List<Map<String, String>> list = [];
      for (int j = 0; j < size.width; j++) {
        final json = cellList[i][j].toJson();
        list.add(json);
      }
      result['$i'] = list;
    }
    return result;
  }

  Map<String, Object> toJson() {
    return {
      'cells': cellsToMap(cells),
      'number': number,
      'puzzle': puzzle,
      'result': result.name,
      'moves': moves,
      'size': '${size.width}x${size.height}',
      'date': date.toString(),
      'difficulty': difficulty.name
    };
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    final listSize = json['size'].toString().split('x').toList();
    final furdleSize =
        Size(double.parse(listSize[0]), double.parse(listSize[1]));
    final map = (json['cells'] as Map<String, dynamic>);

    List<List<FCellState>> cellList = [];
    for (int i = 0; i < furdleSize.height; i++) {
      List<FCellState> list = [];
      for (int j = 0; j < furdleSize.width; j++) {
        FCellState cell = FCellState.fromJson((map['$i']! as List<dynamic>)[j]);
        list.add(cell);
      }
      cellList.add(list);
    }

    return Puzzle(
        cells: cellList,
        number: json['number'] as int,
        puzzle: json['puzzle'] as String,
        result: json['result'].toString().toPuzzleResult(),
        moves: json['moves'] as int,
        size: furdleSize,
        date: DateTime.parse(json['date'] as String),
        difficulty: json['difficulty'].toString().toDifficulty());
  }
}
