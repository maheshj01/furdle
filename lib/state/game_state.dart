import 'package:furdle/provider/game_state_notifier.dart';

class GameState {
  /// the id of the game an incremental value starting from 1
  final int id;

  /// the size of the grid
  /// default size is 5x5
  final GridSize size;

  /// the row of the grid where the user is currently typing
  final int row;

  /// the column of the grid where the user is currently typing
  final int column;

  /// Current game status (none, inprogress, win, lose)
  final GameStatus status;

  /// The target word/puzzle to solve
  final String targetWord;

  /// Current word being typed (for validation)
  final String currentWord;

  /// List of all words submitted so far
  final List<String> submittedWords;

  /// Grid cells state (character + cell state for each position)
  final List<List<CellState>> cells;

  /// Game difficulty level
  final Difficulty? difficulty;

  /// Whether the current word is valid
  final bool isCurrentWordValid;

  /// Last submitted word result
  final SubmitWordResult? lastSubmitResult;

  /// Game start time
  final DateTime? startTime;

  /// Game end time (if completed)
  final DateTime? endTime;

  /// Number of hints used
  final int hintsUsed;

  final DateTime? nextGameDate;

  /// Game type
  final GameType gameType;

  GameState({
    required this.id,
    this.gameType = GameType.daily,
    this.size = const GridSize(width: 5, height: 6),
    required this.row,
    required this.column,
    required this.status,
    required this.targetWord,
    this.currentWord = '',
    this.submittedWords = const [],
    required this.cells,
    this.difficulty = Difficulty.medium,
    this.isCurrentWordValid = false,
    this.lastSubmitResult,
    this.startTime,
    this.endTime,
    this.hintsUsed = 0,
    this.nextGameDate,
  });

  GameState copyWith({
    int? id,
    GameType? gameType,
    GameStatus? status,
    String? targetWord,
    List<List<CellState>>? cells,
    Difficulty? difficulty,
    bool? isCurrentWordValid,
    SubmitWordResult? lastSubmitResult,
    DateTime? startTime,
    DateTime? endTime,
    int? hintsUsed,
    int? row,
    int? column,
    GridSize? size,
    String? currentWord,
    List<String>? submittedWords,
    DateTime? nextGameDate,
  }) {
    return GameState(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      row: row ?? this.row,
      column: column ?? this.column,
      status: status ?? this.status,
      targetWord: targetWord ?? this.targetWord,
      cells: cells ?? this.cells,
      difficulty: difficulty ?? this.difficulty,
      isCurrentWordValid: isCurrentWordValid ?? this.isCurrentWordValid,
      lastSubmitResult: lastSubmitResult,
      startTime: startTime,
      endTime: endTime,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      currentWord: currentWord ?? this.currentWord,
      submittedWords: submittedWords ?? this.submittedWords,
      size: size ?? this.size,
      nextGameDate: nextGameDate ?? this.nextGameDate,
    );
  }

  static GameState instance() {
    return GameState(
      id: 0,
      row: 0,
      column: 0,
      size: const GridSize(width: 5, height: 6),
      gameType: GameType.daily,
      status: GameStatus.none,
      targetWord: '',
      cells: defaultGrid(),
      difficulty: Difficulty.medium,
      isCurrentWordValid: false,
      lastSubmitResult: null,
      startTime: null,
      endTime: null,
      hintsUsed: 0,
      nextGameDate: null,
    );
  }

  static List<List<CellState>> defaultGrid() => List.generate(
        6,
        (row) => List.generate(
          5,
          (column) => CellState(character: '', cellType: CellType.empty),
        ),
      );

  // Helper getters
  bool get isGameOver => status == GameStatus.win || status == GameStatus.lose;
  bool get isGameWon => status == GameStatus.win;
  bool get isGameLost => status == GameStatus.lose;
  bool get canSubmit => currentWord.length == size.width && isCurrentWordValid;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameType': gameType.index,
      'size': size.toJson(),
      'row': row,
      'column': column,
      'status': status.index,
      'targetWord': targetWord,
      'currentWord': currentWord,
      'submittedWords': submittedWords,
      'cells': cells.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
      'difficulty': difficulty?.index,
      'isCurrentWordValid': isCurrentWordValid,
      'lastSubmitResult': lastSubmitResult?.index,
      'startTime': startTime?.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'hintsUsed': hintsUsed,
      'nextGameDate': nextGameDate?.millisecondsSinceEpoch,
    };
  }

  static GameState fromJson(Map<String, dynamic> json) {
    // This is a temporary fix for backward compatibility with older versions of the app
    // TODO: remove this after next 5 releases
    if (!json.containsKey('gameType')) {
      json['gameType'] = 0;
    }
    return GameState(
      id: json['id'] as int,
      size: GridSize.fromJson(json['size'] as Map<String, dynamic>),
      row: json['row'] as int,
      column: json['column'] as int,
      gameType: GameType.values[json['gameType'] as int],
      status: GameStatus.values[json['status'] as int],
      targetWord: json['targetWord'] as String,
      currentWord: json['currentWord'] as String? ?? '',
      submittedWords: List<String>.from(json['submittedWords'] as List? ?? []),
      cells: (json['cells'] as List)
          .map((row) => (row as List)
              .map((cell) => CellState.fromJson(cell as Map<String, dynamic>))
              .toList())
          .toList(),
      difficulty: json['difficulty'] != null ? Difficulty.values[json['difficulty'] as int] : null,
      isCurrentWordValid: json['isCurrentWordValid'] as bool? ?? false,
      lastSubmitResult: json['lastSubmitResult'] != null
          ? SubmitWordResult.values[json['lastSubmitResult'] as int]
          : null,
      startTime: json['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int)
          : null,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      nextGameDate: json['nextGameDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['nextGameDate'] as int)
          : null,
    );
  }
}
