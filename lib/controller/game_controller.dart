import 'package:furdle/models/game_state.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/service/game_service.dart';

class GameController {
  GameService? _gameService;

  Future<void> initialize() async {
    _gameService = GameService();
    await _gameService!.initialize();
  }

  /// returns either a new puzzle or the last played puzzle,
  /// if the puzzle is not saved, gets a new puzzle from the server
  Future<Puzzle> getPuzzle() async {
    return await _gameService!.loadGame();
  }

  /// returns the last played puzzle otherwise a new puzzle
  Future<Puzzle> getLastPlayedPuzzle() async {
    return await _gameService!.getSavedPuzzle();
  }

  Future<void> onGameOver(Puzzle puzzle) async {
    await _gameService!.onGameOver(puzzle);
  }

  Future<void> saveGameState(GameState state) async {
    await _gameService!.saveCurrentFurdle(state.puzzle);
  }
}
