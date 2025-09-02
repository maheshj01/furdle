import 'package:furdle/old/controller/game_state_notifier.dart';
import 'package:furdle/old/models/game.dart';

abstract class IGameService {
  Future<GameState> loadGame();
  Future<void> onGameStateChange(GameState state);
  Future<void> onGameOver(GameState state);
}
