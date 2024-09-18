import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/models/game.dart';
import 'package:furdle/service/storage_service.dart';
import 'package:furdle/shared/providers/storage_service_provider.dart';

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>(
  (ref) {
    final storage = ref.watch(storageServiceProvider);
    return GameStateNotifier(storage);
  },
);

class GameStateNotifier extends StateNotifier<GameState> {
  final StorageService storageService;

  GameStateNotifier(this.storageService) : super(GameState.instance()) {
    initGameState();
  }

  Future<void> initGameState() async {
    final stateJson =
        await storageService.get(AppConstants.APP_GAME_STATE_STORAGE_KEY);
    if (stateJson != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(stateJson as String);
        state = GameState.fromJson(jsonMap);
      } catch (e) {
        print('Error loading game state: $e');
        state = GameState.instance();
      }
    } else {
      state = GameState.instance();
    }
  }

  Future<void> saveGameState() async {
    final stateJson = json.encode(state.toJson());
    await storageService.set(
        AppConstants.APP_GAME_STATE_STORAGE_KEY, stateJson);
  }

  void updateGameState(GameState newState) {
    state = newState;
    saveGameState();
  }

  void resetGame() {
    state = GameState.instance();
    saveGameState();
  }

  Word submitWord() {
    final size = state.puzzle.size;
    final column = state.column;
    final row = state.row;
    if (column < size.width - 1) {
      return Word.incomplete;
    } else if (column == size.width) {
      final currentWord =
          state.cells[row].sublist(0, column).map((e) => e.character).join();
      if (currentWord == state.puzzle.puzzle) {
        state.status = GameStatus.win;
        saveGameState();
        return Word.match;
      }
    }
    return Word.valid;
  }

  String stateToGrid(Cell cell) {
    switch (cell) {
      case Cell.empty:
        return '⬜️';
      case Cell.misplaced:
        return '🟨';
      case Cell.match:
        return '🟩';
      case Cell.notExists:
        return '⬛️';
    }
  }

  String generateFurdleGrid() {
    bool isPuzzleCracked = state.status == GameStatus.win;
    final int attempts = isPuzzleCracked ? state.row : 0;
    String generatedFurdle =
        '#${state.puzzle.number} $attempts/${state.puzzle.size.height.toInt()}\n\n';
    for (int i = 0; i < state.puzzle.size.height; i++) {
      String currentRow = '';
      for (int j = 0; j < state.puzzle.size.width; j++) {
        currentRow += stateToGrid(state.cells[i][j].state);
      }
      currentRow += '\n';
      generatedFurdle += currentRow;
    }
    generatedFurdle += '\n$gameUrl';
    return generatedFurdle;
  }

  void addCell(String char) {
    final size = state.puzzle.size;
    final column = state.column;
    final row = state.row;
    if (column >= size.width) return;
    state.cells[row][column].character = char;
    state.column++;
    saveGameState();
    print(state.cells);
  }

  void removeCell() {
    final column = state.column;
    final row = state.row;
    if (column <= 0) return;
    state.column--;
    state.cells[row][column].character = '';
    saveGameState();
  }
}

class LoadingNotifier extends ValueNotifier<bool> {
  bool _isLoading = true;

  LoadingNotifier(super.value);

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    _notify();
  }

  void _notify() {
    notifyListeners();
  }
}
