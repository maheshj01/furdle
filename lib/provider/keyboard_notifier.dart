// Enum for letter status in the word
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LetterStatus {
  unknown,
  present,
  notPresent,
}

// Class to represent the state of a single key
class KeyState {
  final bool isPressed;
  final LetterStatus letterStatus;

  const KeyState({
    this.isPressed = false,
    this.letterStatus = LetterStatus.unknown,
  });

  KeyState copyWith({
    bool? isPressed,
    LetterStatus? letterStatus,
  }) {
    return KeyState(
      isPressed: isPressed ?? this.isPressed,
      letterStatus: letterStatus ?? this.letterStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeyState &&
        other.isPressed == isPressed &&
        other.letterStatus == letterStatus;
  }

  @override
  int get hashCode => isPressed.hashCode ^ letterStatus.hashCode;
}

// Class to manage the entire keyboard state
class KeyboardState {
  final Map<String, KeyState> keyStates;

  const KeyboardState({required this.keyStates});

  KeyboardState copyWith({
    Map<String, KeyState>? keyStates,
  }) {
    return KeyboardState(
      keyStates: keyStates ?? this.keyStates,
    );
  }

  // Helper method to get key state
  KeyState getKeyState(String key) {
    return keyStates[key] ?? const KeyState();
  }

  // Helper method to update a single key state
  KeyboardState updateKeyState(String key, KeyState newState) {
    final newKeyStates = Map<String, KeyState>.from(keyStates);
    newKeyStates[key] = newState;
    return copyWith(keyStates: newKeyStates);
  }

  // Helper method to set key pressed state
  KeyboardState setKeyPressed(String key, bool isPressed) {
    final currentState = getKeyState(key);
    return updateKeyState(key, currentState.copyWith(isPressed: isPressed));
  }

  // Helper method to set letter status
  KeyboardState setLetterStatus(String key, LetterStatus status) {
    final currentState = getKeyState(key);
    return updateKeyState(key, currentState.copyWith(letterStatus: status));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeyboardState && other.keyStates == keyStates;
  }

  @override
  int get hashCode => keyStates.hashCode;
}

// Notifier class for keyboard state management
class KeyboardNotifier extends StateNotifier<KeyboardState> {
  KeyboardNotifier() : super(_initialState);

  static KeyboardState get _initialState {
    final keyStates = <String, KeyState>{};

    // Initialize all letter keys
    for (int i = 0; i < 26; i++) {
      final letter = String.fromCharCode(65 + i); // A-Z
      keyStates[letter] = const KeyState();
    }

    // Initialize special keys
    keyStates[' '] = const KeyState(); // Space
    keyStates['Backspace'] = const KeyState();
    keyStates['Enter'] = const KeyState();

    return KeyboardState(keyStates: keyStates);
  }

  // Method to handle key press
  void onKeyPressed(String key, bool isPressed) {
    state = state.setKeyPressed(key, isPressed);
  }

  // Method to set letter status (for game logic)
  void setLetterStatus(String letter, LetterStatus status) {
    if (letter.length == 1 &&
        letter.toUpperCase().codeUnitAt(0) >= 65 &&
        letter.toUpperCase().codeUnitAt(0) <= 90) {
      state = state.setLetterStatus(letter.toUpperCase(), status);
    }
  }

  // Method to reset all key pressed states
  void resetPressedStates() {
    final newKeyStates = <String, KeyState>{};
    for (final entry in state.keyStates.entries) {
      newKeyStates[entry.key] = entry.value.copyWith(isPressed: false);
    }
    state = state.copyWith(keyStates: newKeyStates);
  }

  // Method to reset all letter statuses
  void resetLetterStatuses() {
    final newKeyStates = <String, KeyState>{};
    for (final entry in state.keyStates.entries) {
      newKeyStates[entry.key] =
          entry.value.copyWith(letterStatus: LetterStatus.unknown);
    }
    state = state.copyWith(keyStates: newKeyStates);
  }

  // Method to reset everything
  void reset() {
    state = _initialState;
  }
}

// Provider for the keyboard notifier
final keyboardProvider =
    StateNotifierProvider<KeyboardNotifier, KeyboardState>((ref) {
  return KeyboardNotifier();
});

// Provider for individual key states
final keyStateProvider = Provider.family<KeyState, String>((ref, key) {
  final keyboardState = ref.watch(keyboardProvider);
  return keyboardState.getKeyState(key);
});
