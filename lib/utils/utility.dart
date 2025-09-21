import 'package:flutter/material.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/state/game_state.dart';
import 'package:furdle/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// State Color for either furdle or Keyboard
class Utility {
  static Future<void> launch(String url,
      {bool isNewTab = true,
      LaunchMode mode = LaunchMode.externalApplication}) async {
    await launchUrl(
      Uri.parse(url),
      mode: mode,
      webOnlyWindowName: isNewTab ? '_blank' : '_self',
    );
  }

  static void showMessage(context, message,
      {Duration? duration = const Duration(milliseconds: 1500),
      EdgeInsetsGeometry? margin}) {
    ScaffoldMessenger.of(context).showSnackBar(
        snackBar(message: '$message', duration: duration!, margin: margin));
  }

  static String generateFurdleGrid(GameState state) {
    final isPuzzleCracked = state.status == GameStatus.win;
    if (!isPuzzleCracked) {
      return 'You can\'t share a furdle that hasn\'t been solved yet!';
    }
    final int attempts = isPuzzleCracked ? state.row + 1 : 0;
    String generatedFurdle = '#1 $attempts/${state.size.height.toInt()}\n\n';
    for (int i = 0; i < state.size.height; i++) {
      String currentRow = '';
      for (int j = 0; j < state.size.width; j++) {
        currentRow += stateToGrid(state.cells[i][j].cellType);
      }
      currentRow += '\n';
      generatedFurdle += currentRow;
    }
    generatedFurdle += '\n${Constants.gameUrl}';
    return generatedFurdle;
  }

  static String stateToGrid(CellType cell) {
    switch (cell) {
      case CellType.empty:
        return '⬜️';
      case CellType.misplaced:
        return '🟨';
      case CellType.match:
        return '🟩';
      case CellType.notExists:
        return '⬛️';
      case CellType.unknown:
        return '⬜️';
    }
  }
}
