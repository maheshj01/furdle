enum PuzzleResult { win, lose }

class Puzzle {
  late String _puzzle;
  late PuzzleResult _result;
  late int _moves;
  late int _puzzleSize;
  late DateTime _date;

  Puzzle.initialStats({String puzzle = ''}) {
    _puzzle = puzzle;
    _result = PuzzleResult.lose;
    _moves = 0;
    _puzzleSize = 0;
    _date = DateTime.now();
  }

  Puzzle.fromStats(String puzzle, PuzzleResult result, int moves,
      int puzzleSize, DateTime date) {
    _puzzle = puzzle;
    _result = result;
    _moves = moves;
    _puzzleSize = puzzleSize;
    _date = date;
  }

  Puzzle(
      {required String puzzle,
      required PuzzleResult result,
      required int moves,
      required int puzzleSize,
      required DateTime date}) {
    _puzzle = puzzle;
    _result = result;
    _moves = moves;
    _puzzleSize = puzzleSize;
    _date = DateTime.now();
  }

  String get puzzle => _puzzle;
  PuzzleResult get result => _result;
  int get moves => _moves;
  int get puzzleSize => _puzzleSize;
  DateTime get date => _date;

  set moves(int value) {
    _moves = value;
  }

  set puzzleSize(int value) {
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

  void onMatchPlayed(Puzzle puzzle) {
    _result = puzzle.result;
    _moves = puzzle.moves;
    _puzzleSize = puzzle.puzzleSize;
    _date = DateTime.now();
  }

  Map<String, Object> toJson() {
    return {
      'puzzle': _puzzle,
      'result': _result.name,
      'moves': _moves,
      'size': _puzzleSize,
      'date': _date.toString(),
    };
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      puzzle: json['puzzle'] as String,
      result: json['result'] == 'win' ? PuzzleResult.win : PuzzleResult.lose,
      moves: json['moves'] as int,
      puzzleSize: json['size'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
