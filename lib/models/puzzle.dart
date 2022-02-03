import 'package:flutter/material.dart';
import 'package:furdle/constants/const.dart';

enum PuzzleResult { win, lose }
enum Difficulty { easy, medium, hard }

class Puzzle {
  late int _number;
  late String _puzzle;
  late PuzzleResult _result;
  late int _moves;
  late Size _puzzleSize;
  late DateTime _date;
  late Difficulty _difficulty;

  Puzzle.initialStats({String puzzle = ''}) {
    _number = 0;
    _puzzle = puzzle;
    _result = PuzzleResult.lose;
    _moves = 0;
    _puzzleSize = defaultSize;
    _date = DateTime.now();
    _difficulty = Difficulty.medium;
  }

  Puzzle.fromStats(String puzzle, PuzzleResult result, int moves,
      Size puzzleSize, DateTime date, Difficulty difficulty, int number) {
    _number = number;
    _puzzle = puzzle;
    _result = result;
    _moves = moves;
    _puzzleSize = puzzleSize;
    _date = date;
    _difficulty = difficulty;
  }

  Puzzle(
      {required String puzzle,
      required PuzzleResult result,
      required int moves,
      required Size puzzleSize,
      required DateTime date,
      required Difficulty difficulty,
      required int number}) {
    _number = number;
    _puzzle = puzzle;
    _result = result;
    _moves = moves;
    _puzzleSize = puzzleSize;
    _date = DateTime.now();
    _difficulty = difficulty;
  }

  String get puzzle => _puzzle;

  PuzzleResult get result => _result;

  int get moves => _moves;

  Size get puzzleSize => _puzzleSize;

  DateTime get date => _date;

  Difficulty get difficulty => _difficulty;

  int get number => _number;

  set number(int value) {
    _number = value;
  }

  set moves(int value) {
    _moves = value;
  }

  set puzzleSize(Size value) {
    _puzzleSize = value;
  }

  set puzzle(String value) {
    _puzzle = value;
  }

  set result(PuzzleResult value) {
    _result = value;
  }

  set date(DateTime value) {
    _date = value;
  }

  set difficulty(Difficulty value) {
    _difficulty = value;
  }

  void onMatchPlayed(Puzzle puzzle) {
    _result = puzzle.result;
    _moves = puzzle.moves;
    _puzzleSize = puzzle.puzzleSize;
    _date = DateTime.now();
    _difficulty = puzzle.difficulty;
  }

  Map<String, Object> toJson() {
    return {
      'number': _number,
      'puzzle': _puzzle,
      'result': _result.name,
      'moves': _moves,
      'size': '${_puzzleSize.width}x${_puzzleSize.height}',
      'date': _date.toString(),
      'difficulty': _difficulty.name
    };
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    final listSize = json['size'].toString().split('x').toList();
    return Puzzle(
        number: json['number'] as int,
        puzzle: json['puzzle'] as String,
        result: json['result'] == 'win' ? PuzzleResult.win : PuzzleResult.lose,
        moves: json['moves'] as int,
        puzzleSize: Size(double.parse(listSize[0]), double.parse(listSize[1])),
        date: DateTime.parse(json['date'] as String),
        difficulty: json['difficulty'] == 'easy'
            ? Difficulty.easy
            : json['difficulty'] == 'medium'
                ? Difficulty.medium
                : Difficulty.hard);
  }
}
