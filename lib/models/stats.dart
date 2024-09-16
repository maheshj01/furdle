import 'package:furdle/models/puzzle.dart';

class Stats {
  List<Puzzle> puzzles;
  Puzzle puzzle;
  int number;
  int total;
  int won;
  int lost;

  Stats({
    required this.puzzles,
    required this.puzzle,
    required this.number,
    required this.total,
    required this.won,
    required this.lost,
  });

  Stats.initialStats()
      : won = 0,
        puzzle = Puzzle.initialize(),
        number = 0,
        puzzles = [],
        lost = 0,
        total = 0;

  /// to json for saving to disk

  Map<String, dynamic> toJson() {
    return {
      'puzzles': puzzles.map((p) => p.toJson()).toList(),
      'puzzle': puzzle.toJson(),
      'number': number,
      'total': total,
      'won': won,
      'lost': lost,
    };
  }

  /// from json for loading from disk

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      puzzles: json['puzzles']
          .map<Puzzle>((p) => Puzzle.fromJson(p as Map<String, dynamic>))
          .toList(),
      puzzle: Puzzle.fromJson(json['puzzle'] as Map<String, dynamic>),
      number: json['number'] as int,
      total: json['total'] as int,
      won: json['won'] as int,
      lost: json['lost'] as int,
    );
  }

  /// list of all puzzles played by user
  void setPuzzles(List<Puzzle> value) {
    puzzles = value;
    total = puzzles.length;
    won = 0;
    lost = total - won;
  }
}
