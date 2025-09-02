import 'package:flutter/material.dart';
import 'package:furdle/old/models/models.dart';

class Constants {
  Constants._();

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

  // Challenge storage keys
  static const String CHALLENGE_PROGRESS_KEY = 'challenge_current_progress';
  static const String CHALLENGE_COMPLETED_IDS_KEY = 'challenge_completed_ids';

  // Keyboard key mappings
  static const String KEYBOARD_ENTER_KEY = 'Enter';
  static const String KEYBOARD_BACKSPACE_KEY = 'Backspace';
  static const String KEYBOARD_SPACE_KEY = 'Space';
  static const String KEYBOARD_SHIFT_KEY = 'Shift';
  static const String KEYBOARD_CAPS_LOCK_KEY = 'Caps Lock';
  static const String KEYBOARD_TAB_KEY = 'Tab';
  static const String KEYBOARD_DELETE_KEY = 'Delete';
  static const String KEYBOARD_ESCAPE_KEY = 'Escape';
}
