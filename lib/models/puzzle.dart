import 'package:flutter/material.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/models/furdle.dart';

enum PuzzleResult { win, lose, inprogress }
enum Difficulty { easy, medium, hard }

class Puzzle {
  late int _number;
  late String _puzzle;
  late PuzzleResult _result;
  late int _moves;
  late Size _puzzleSize;
  late DateTime _date;
  late Difficulty _difficulty;
  late List<List<FCellState>> _cells;

  Puzzle.initialize({String puzzle = ''}) {
    _cells = [];
    _number = 0;
    _puzzle = puzzle;
    _result = PuzzleResult.inprogress;
    _moves = 0;
    _puzzleSize = defaultSize;
    _date = DateTime.now();
    _difficulty = Difficulty.medium;
  }

  Puzzle.fromStats(String puzzle, PuzzleResult result, int moves,
      Size puzzleSize, DateTime date, Difficulty difficulty, int number) {
    _cells = [];
    _number = number;
    _puzzle = puzzle;
    _result = result;
    _moves = moves;
    _puzzleSize = puzzleSize;
    _date = date;
    _difficulty = difficulty;
  }

  Puzzle(
      {required List<List<FCellState>> cells,
      required String puzzle,
      required PuzzleResult result,
      required int moves,
      required Size puzzleSize,
      required DateTime date,
      required Difficulty difficulty,
      required int number}) {
    _cells = cells;
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

  List<List<FCellState>> get cells => _cells;

  set cells(List<List<FCellState>> value) {
    _cells = value;
  }

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

  Map<String, List<Map<String, String>>> cellsToMap(
      List<List<FCellState>> cellList) {
    final Map<String, List<Map<String, String>>> result = {};
    for (int i = 0; i < _puzzleSize.height; i++) {
      List<Map<String, String>> list = [];
      for (int j = 0; j < _puzzleSize.width; j++) {
        final json = cellList[i][j].toJson();
        list.add(json);
      }
      result['$i'] = list;
    }
    return result;
  }

  Map<String, Object> toJson() {
    return {
      'cells': cellsToMap(_cells),
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
        result: json['result'] == 'win'
            ? PuzzleResult.win
            : json['result'] == 'lose'
                ? PuzzleResult.lose
                : PuzzleResult.inprogress,
        moves: json['moves'] as int,
        puzzleSize: furdleSize,
        date: DateTime.parse(json['date'] as String),
        difficulty: json['difficulty'] == 'easy'
            ? Difficulty.easy
            : json['difficulty'] == 'medium'
                ? Difficulty.medium
                : Difficulty.hard);
  }
}
