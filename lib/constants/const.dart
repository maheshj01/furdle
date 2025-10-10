class Constants {
  Constants._();

  static const String gameUrl = 'https://furdle.web.app';

  static const String appVersion = '0.3.9+13';

  static const String dateFormatter = 'MMM dd, y';

  /// October 09, 2025 12:00 PM
  static const String dateTimeFormatter = 'MMMM dd, y hh:mm a';

  ///
  /// Oct 09, 2025 12:00 PM
  static const String dateTimeFormatter2 = 'MMM dd, y hh:mm a';

  static const String timeFormatter = 'hh:mm a';

  /// length of words in list
  static const int maxWords = 2334;

  static const int hoursUntilNextFurdle = 24;

  static const String collectionProd = 'furdle';
  static const String statsProd = 'stats';

  static const String collectionDev = 'furdle_dev';
  static const String statsDev = 'stats_dev';
  static const String appThemeKey = 'app_theme';
  static const String appSettingsKey = 'app_settings';
  static const String appGameStateKey = 'app_game_state';

  static const String currentChallenge = 'current_challenge';
  static const String completedStatesKey = 'completed_states';

  static final String description = """
  Your goal is to guess a 5 letter word in 6 tries.

  Each guess must be a valid five-letter word. Hit the enter button to submit.

  After submitting each word, the color of the tiles will change to indicate how close your guess was to the word.
  """;

  static String case1 = 'The letter E is in the word and in the correct spot';
  static String case2 = 'The letter L is in the word but in the wrong spot.';
  static String case3 = 'The letter Y is not in the word at any spot';

  static const String shareIncomplete = 'You can\'t share a furdle that hasn\'t been solved yet!';

  static const String scoreCopiedToClipboard = 'Score copied to clipboard';
  // Challenge storage keys
  static const String challengeProgressKey = 'challenge_current_progress';
  static const String challengeCompletedIdsKey = 'challenge_completed_ids';

  // Keyboard key mappings
  static const String keyboardEnterKey = 'Enter';
  static const String keyboardBackspaceKey = 'Backspace';
  static const String keyboardSpaceKey = 'Space';
  static const String keyboardShiftKey = 'Shift';
  static const String keyboardCapsLockKey = 'Caps Lock';
  static const String keyboardTabKey = 'Tab';
  static const String keyboardDeleteKey = 'Delete';
  static const String keyboardEscapeKey = 'Escape';

  static const String letterAKey = 'A';
  static const String letterBKey = 'B';
  static const String letterCKey = 'C';
  static const String letterDKey = 'D';
  static const String letterEKey = 'E';
  static const String letterFKey = 'F';
  static const String letterGKey = 'G';
  static const String letterHKey = 'H';
  static const String letterIKey = 'I';
  static const String letterJKey = 'J';
  static const String letterKKey = 'K';
  static const String letterLKey = 'L';
  static const String letterMKey = 'M';
  static const String letterNKey = 'N';
  static const String letterOKey = 'O';
  static const String letterPKey = 'P';
  static const String letterQKey = 'Q';
  static const String letterRKey = 'R';
  static const String letterSKey = 'S';
  static const String letterTKey = 'T';
  static const String letterUKey = 'U';
  static const String letterVKey = 'V';
  static const String letterWKey = 'W';
  static const String letterXKey = 'X';
  static const String letterYKey = 'Y';
  static const String letterZKey = 'Z';
}
