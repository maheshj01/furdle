import 'package:furdle/models/puzzle.dart';

abstract class IGameService {
  Future<Puzzle>  loadGame();
  void initialize();
  Future<void> onGameOver(Puzzle puzzle);
}
