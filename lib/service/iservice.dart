import 'package:furdle/controller/game_notifier.dart';
import 'package:furdle/models/game.dart';

abstract class IGameService {
  Future<GameState> loadGame();
  Future<void> onGameStateChange(GameState state);
  Future<void> onGameOver(GameState state);
}
