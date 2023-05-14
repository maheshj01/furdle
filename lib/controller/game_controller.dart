import 'package:furdle/models/game_state.dart';
import 'package:furdle/service/game_service.dart';

class GameController {
  GameService? _gameService;
  GameState? _gameState;

  GameState get gameState => _gameState!;

  set gameState(GameState state) {
    _gameState = state;
    _onGameStateChange(state);
  }

  Future<void> initialize() async {
    _gameService = GameService();
    await _gameService!.initialize();
    _gameState = _gameService!.gameState;
  }

  Duration _timeLeft = Duration.zero;

  Duration get timeLeft => _timeLeft;

  set timeLeft(Duration duration) {
    _timeLeft = duration;
  }

  /// returns either a new puzzle or the last played puzzle,
  /// if the puzzle is not saved, gets a new puzzle from the server
  Future<GameState> loadGame() async {
    return await _gameService!.loadGame();
  }

  /// returns the last played puzzle otherwise a new puzzle
  Future<GameState> getSavedGame() async {
    return await _gameService!.getSavedGame();
  }

  Future<void> onGameOver(GameState state) async {
    await _gameService!.onGameOver(state);
    _onGameStateChange(gameState);
  }

  Future<void> _onGameStateChange(GameState state) async {
    await _gameService!.onGameStateChange(state);
  }
}
