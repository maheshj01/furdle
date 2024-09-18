import 'package:furdle/models/keyboard.dart';
import 'package:furdle/models/puzzle.dart';

/// Class to represent the state of a cell in the grid
/// character is the letter in the cell
/// state is the state of the character entered in the cell
class FCellState {
  String character;
  Cell state;

  FCellState({this.character = '', this.state = Cell.empty});

  FCellState.defaultState()
      : character = '',
        state = Cell.empty;

  Map<String, String> toJson() {
    return {'character': character, 'state': state.name};
  }

  factory FCellState.fromJson(Map<String, dynamic> json) {
    Cell state = Cell.empty;
    switch (json['state']) {
      case 'empty':
        state = Cell.empty;
        break;
      case 'match':
        state = Cell.match;
        break;
      case 'misplaced':
        state = Cell.misplaced;
        break;
      case 'notExists':
        state = Cell.notExists;
        break;
      default:
        state = Cell.notExists;
        break;
    }
    return FCellState(
      character: json['character'],
      state: state,
    );
  }
}

enum Cell {
  /// letter is present in the right spot
  /// green color
  match(3),

  /// letter is present in the wrong spot
  /// orange color
  misplaced(2),

  /// letter is not present in any spot
  /// black color
  notExists(1),

  /// letter is empty
  /// grey color
  empty(0);

  final int priority;
  const Cell(this.priority);

  int toPriority() => priority;
}

enum Word {
  /// length is less than 5
  valid,

  /// word is incomplete, length is less than 5
  incomplete,

  /// word not in list
  invalid,

  /// word matches the target word
  match
}

enum GameStatus {
// User has submitted atleast one row
  inprogress,
  // All letters are in right position
  win,
  // User has exhausted all attempts
  lose,
// Game has not started yet
  none
}

class GameState {
  // column is the current column of the grid
  int row;
  // column is the current column of the grid
  int column;

  // status of the game
  GameStatus status;

  /// the puzzle to be solved
  Puzzle puzzle;

  /// Defines the state of furdle grid
  /// This is also used to define the color of the keys
  /// in the keyboard
  List<List<FCellState>> cells;

  KState? keyboardState = KState.initialize();

  bool get isGameOver => status == GameStatus.win || status == GameStatus.lose;

  GameState(
      {this.row = 0,
      this.column = 0,
      this.keyboardState,
      this.status = GameStatus.inprogress,
      this.cells = const [],
      required this.puzzle});

  void _initCells({Difficulty difficulty = Difficulty.medium}) {
    cells = <List<FCellState>>[];
    final gridSize = difficulty.toGridSize();
    for (int i = 0; i < gridSize.height; i++) {
      final List<FCellState> row = [];
      for (int j = 0; j < gridSize.width; j++) {
        row.add(FCellState.defaultState());
      }
      cells.add(row);
    }
  }

  Map<String, List<Map<String, String>>> cellsToMap() {
    final Map<String, List<Map<String, String>>> result = {};
    for (int i = 0; i < cells.length; i++) {
      final List<Map<String, String>> list = [];
      for (int j = 0; j < cells[0].length; j++) {
        final json = cells[i][j].toJson();
        list.add(json);
      }
      result['$i'] = list;
    }
    return result;
  }

  Map<String, Object> toJson() {
    return {
      'row': row,
      'column': column,
      'status': status.name,
      'puzzle': puzzle.toJson(),
      'keyboard': keyboardState!.toJson(),
      'cells': cellsToMap(),
    };
  }

  factory GameState.instance() {
    final _difficulty = Difficulty.medium;
    final _cells = _difficulty.toDefaultcells();
    final _kState = KState.initialize();
    return GameState(
        status: GameStatus.none,
        row: 0,
        column: 0,
        cells: _cells,
        keyboardState: _kState,
        puzzle: Puzzle.initialize());
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    final _difficulty = Difficulty.fromString(json['puzzle']['difficulty']);
    final puzzleSize = _difficulty.toGridSize();

    final map = (json['cells'] as Map<String, dynamic>);
    final List<List<FCellState>> cellList = [];
    for (int i = 0; i < puzzleSize.height; i++) {
      final List<FCellState> list = [];
      for (int j = 0; j < puzzleSize.width; j++) {
        final FCellState cell =
            FCellState.fromJson((map['$i']! as List<dynamic>)[j]);
        list.add(cell);
      }
      cellList.add(list);
    }

    return GameState(
        row: json['row'],
        cells: cellList,
        column: json['column'],
        puzzle: Puzzle.fromJson(json['puzzle']));
  }
}
