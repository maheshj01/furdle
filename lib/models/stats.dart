import 'package:furdle/models/puzzle.dart';

class Stats {
  List<Puzzle> _puzzles;
  int _total;
  int _won;
  int _lost;
  int _averageTime;

  Stats.initialStats()
      : _won = 0,
        _puzzles = [],
        _lost = 0,
        _total = 0,
        _averageTime = 0;

  int get averageTime => _averageTime;

  set averageTime(int value) {
    _averageTime = value;
  }

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  int get lost => _lost;

  set lost(int value) {
    _lost = value;
  }

  int get won => _won;

  set won(int value) {
    _won = value;
  }

  List<Puzzle> get puzzles => _puzzles;

  set puzzles(List<Puzzle> value) {
    _puzzles = value;
    total = _puzzles.length;
    won = _puzzles.where((p) => p.result == PuzzleResult.win).length;
    lost = total - won;
  }
}
