import 'package:flutter/material.dart';
import 'package:furdle/models/models.dart';

class AppConstants {
  /// length of words in list
  static const int maxWords = 2334;

  static Size defaultSize = Difficulty.easy.toGridSize();

  static const int hoursUntilNextFurdle = 24;

  static const String collectionProd = 'furdle';
  static const String statsProd = 'stats';

  static const String collectionDev = 'furdle_dev';
  static const String statsDev = 'stats_dev';
  static const String APP_THEME_STORAGE_KEY = 'app_theme';
  static const String APP_SETTINGS_STORAGE_KEY = 'app_settings';
  static const String APP_GAME_STATE_STORAGE_KEY = 'app_game_state';
}
