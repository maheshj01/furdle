// Enum for letter status in the word
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/ui/keyboard.dart';

enum LetterStatus {
  unknown,
  present,
  notPresent,
  wrongPosition,
}

// Class to represent the state of a single key
class KeyState {
  /// The event type of the key
  /// whether the key is pressed or released or tap cancelled
  final KeyEventType event;

  /// Whether the key is a physical key
  final bool isPhysicalKey;

  /// The status of the letter in the word
  final LetterStatus letterStatus;
  final DateTime? timeStamp;
  final String key; // Add the key identifier

  const KeyState({
    required this.key,
    this.event = KeyEventType.keyUp,
    this.isPhysicalKey = false,
    this.letterStatus = LetterStatus.unknown,
    this.timeStamp,
  });

  KeyState copyWith({
    String? key,
    KeyEventType? event,
    bool? isPhysicalKey,
    LetterStatus? letterStatus,
    DateTime? timeStamp,
  }) {
    return KeyState(
      key: key ?? this.key,
      event: event ?? this.event,
      isPhysicalKey: isPhysicalKey ?? this.isPhysicalKey,
      letterStatus: letterStatus ?? this.letterStatus,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeyState &&
        other.key == key &&
        other.event == event &&
        other.isPhysicalKey == isPhysicalKey &&
        other.letterStatus == letterStatus &&
        other.timeStamp == timeStamp;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      event.hashCode ^
      isPhysicalKey.hashCode ^
      letterStatus.hashCode ^
      timeStamp.hashCode;
}

// Class to manage the entire keyboard state
class KeyboardState {
  final Map<String, KeyState> keyStates;
  final List<KeyState> keyEventHistory; // Track order of key events

  const KeyboardState({
    required this.keyStates,
    this.keyEventHistory = const [],
  });

  KeyboardState copyWith({
    Map<String, KeyState>? keyStates,
    List<KeyState>? keyEventHistory,
  }) {
    return KeyboardState(
      keyStates: keyStates ?? this.keyStates,
      keyEventHistory: keyEventHistory ?? this.keyEventHistory,
    );
  }

  // Helper method to get key state
  KeyState getKeyState(String key) {
    return keyStates[key] ?? KeyState(key: key);
  }

  // Helper method to update a single key state
  KeyboardState updateKeyState(String key, KeyState newState) {
    final newKeyStates = Map<String, KeyState>.from(keyStates);
    newKeyStates[key] = newState;
    return copyWith(keyStates: newKeyStates);
  }

  // Helper method to set key pressed state
  KeyboardState setKeyPressed(String key, KeyEventType event,
      {bool isPhysicalKey = false, DateTime? timeStamp}) {
    final currentState = getKeyState(key);
    final newState = currentState.copyWith(
      key: key,
      event: event,
      isPhysicalKey: isPhysicalKey,
      timeStamp: timeStamp ?? DateTime.now(),
    );

    // Add to event history
    final newEventHistory = List<KeyState>.from(keyEventHistory);
    newEventHistory.add(newState);

    return updateKeyState(key, newState).copyWith(
      keyEventHistory: newEventHistory,
    );
  }

  // Helper method to set letter status
  KeyboardState setLetterStatus(String key, LetterStatus status) {
    final currentState = getKeyState(key);
    return updateKeyState(key, currentState.copyWith(letterStatus: status));
  }

  // Get the last key event
  KeyState? get lastKeyEvent {
    return keyEventHistory.isNotEmpty ? keyEventHistory.last : null;
  }

  // Get recent key events (last N events)
  List<KeyState> getRecentKeyEvents(int count) {
    if (keyEventHistory.isEmpty) return [];
    final start =
        keyEventHistory.length > count ? keyEventHistory.length - count : 0;
    return keyEventHistory.sublist(start);
  }

  // Clear event history
  KeyboardState clearEventHistory() {
    return copyWith(keyEventHistory: []);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeyboardState &&
        other.keyStates == keyStates &&
        other.keyEventHistory == keyEventHistory;
  }

  @override
  int get hashCode => keyStates.hashCode ^ keyEventHistory.hashCode;
}

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
    keyStates[' '] = const KeyState(key: ' '); // Space
    keyStates['Backspace'] = const KeyState(key: 'Backspace');
    keyStates['Enter'] = const KeyState(key: 'Enter');

    return KeyboardState(keyStates: keyStates, keyEventHistory: []);
  }

  // Method to handle key press
  void onKeyPressed(String key, KeyEventType event, bool isPhysicalKey,
      {DateTime? timestamp}) {
    state = state.setKeyPressed(key, event,
        isPhysicalKey: isPhysicalKey, timeStamp: timestamp ?? DateTime.now());
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
      newKeyStates[entry.key] = entry.value.copyWith(event: KeyEventType.keyUp);
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

  // Method to clear event history
  void clearEventHistory() {
    state = state.clearEventHistory();
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
