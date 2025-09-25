// Enum for letter status in the word
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/state/key_state.dart';
import 'package:furdle/state/keyboard_state.dart';
import 'package:furdle/ui/keyboard.dart';

// Notifier class for keyboard state management
class KeyboardNotifier extends StateNotifier<KeyboardState> {
  KeyboardNotifier() : super(_initialState);

  static KeyboardState get _initialState {
    final keyStates = <String, KeyState>{};

    // Initialize all letter keys
    for (int i = 0; i < 26; i++) {
      final letter = String.fromCharCode(65 + i); // A-Z
      keyStates[letter] = KeyState(key: letter);
    }

    // Initialize special keys
    // keyStates[Constants.keyboardSpaceKey] = const KeyState(key: ' '); // Space
    keyStates[Constants.keyboardBackspaceKey] =
        const KeyState(key: Constants.keyboardBackspaceKey, isSpecial: true);
    keyStates[Constants.keyboardEnterKey] =
        const KeyState(key: Constants.keyboardEnterKey, isSpecial: true);

    return KeyboardState(keyStates: keyStates, keyEventHistory: []);
  }

  // Method to handle key press
  void onKeyPressed(String key, KeyEventType event, bool isPhysicalKey,
      {bool isSpecial = false, int widthCount = 1, DateTime? timestamp}) {
    state = state.setKeyPressed(key, event,
        isPhysicalKey: isPhysicalKey, timeStamp: timestamp ?? DateTime.now());
  }

  // Method to set letter status (for game logic)
  void setLetterStatus(String letter, CellType cellType) {
    if (letter.length == 1 &&
        letter.toUpperCase().codeUnitAt(0) >= 65 &&
        letter.toUpperCase().codeUnitAt(0) <= 90) {
      state = state.setLetterStatus(letter.toUpperCase(), cellType);
    }
  }

  // Method to reset all key pressed states
  void resetPressedStates() {
    final newKeyStates = <String, KeyState>{};
    for (final entry in state.keyStates.entries) {
      newKeyStates[entry.key] = entry.value.copyWith(event: KeyEventType.keyUp);
    }
    state = state.copyWith(keyStates: newKeyStates);
  }

  // Method to reset all letter statuses
  void resetLetterStatuses() {
    final newKeyStates = <String, KeyState>{};
    for (final entry in state.keyStates.entries) {
      newKeyStates[entry.key] = entry.value.copyWith(cellType: CellType.unknown);
    }
    state = state.copyWith(keyStates: newKeyStates);
  }

  // Method to clear event history
  void clearEventHistory() {
    state = state.clearEventHistory();
  }

  // Method to reset everything
  void reset() {
    state = _initialState;
  }

  // Method to restore state without triggering events
  void restoreState(KeyboardState restoredState) {
    // Only restore the key states, not the event history to avoid triggering listeners
    state = state.copyWith(
      keyStates: restoredState.keyStates,
      // Don't restore keyEventHistory to prevent triggering lastKeyEventProvider
    );
  }
}

// Provider for the keyboard notifier
final keyboardProvider = StateNotifierProvider<KeyboardNotifier, KeyboardState>((ref) {
  return KeyboardNotifier();
});

// Provider for individual key states
final keyStateProvider = Provider.family<KeyState, String>((ref, key) {
  final keyboardState = ref.watch(keyboardProvider);
  return keyboardState.getKeyState(key);
});

// Provider for key event history
final keyEventHistoryProvider = Provider<List<KeyState>>((ref) {
  final keyboardState = ref.watch(keyboardProvider);
  return keyboardState.keyEventHistory;
});

// Provider for the last key event
final lastKeyEventProvider = Provider<KeyState?>((ref) {
  final keyboardState = ref.watch(keyboardProvider);
  return keyboardState.lastKeyEvent;
});
