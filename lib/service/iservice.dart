import 'package:furdle/models/game_state.dart';

abstract class IGameService {
  Future<GameState> loadGame();
  Future<void> onGameStateChange(GameState state);
  Future<void> onGameOver(GameState state);
}
