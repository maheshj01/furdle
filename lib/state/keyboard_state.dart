// Class to manage the entire keyboard state
import 'package:furdle/constants/const.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/state/key_state.dart';
import 'package:furdle/ui/keyboard.dart';

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
    final isSpecial = isSpecialKey(key);
    final newState = currentState.copyWith(
      key: key,
      event: event,
      isPhysicalKey: isPhysicalKey,
      isSpecial: isSpecial,
      widthCount: isSpecial ? 2 : 1,
      timeStamp: timeStamp ?? DateTime.now(),
    );

    // Add to event history
    final newEventHistory = List<KeyState>.from(keyEventHistory);
    newEventHistory.add(newState);

    return updateKeyState(key, newState).copyWith(
      keyEventHistory: newEventHistory,
    );
  }

  bool isSpecialKey(String key) {
    switch (key) {
      case Constants.keyboardBackspaceKey:
      case Constants.keyboardEnterKey:
      case Constants.keyboardSpaceKey:
      case Constants.keyboardShiftKey:
      case Constants.keyboardCapsLockKey:
      case Constants.keyboardTabKey:
      case Constants.keyboardDeleteKey:
      case Constants.keyboardEscapeKey:
        return true;
      default:
        return false;
    }
  }

  // Helper method to set letter status
  KeyboardState setLetterStatus(String key, CellType cellType) {
    final currentState = getKeyState(key);
    return updateKeyState(key, currentState.copyWith(cellType: cellType));
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

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'keyStates': keyStates.map((key, value) => MapEntry(key, value.toJson())),
      'keyEventHistory':
          keyEventHistory.map((event) => event.toJson()).toList(),
    };
  }

  static KeyboardState fromJson(Map<String, dynamic> json) {
    final keyStatesJson = json['keyStates'] as Map<String, dynamic>? ?? {};
    final keyStates = keyStatesJson.map(
      (key, value) =>
          MapEntry(key, KeyState.fromJson(value as Map<String, dynamic>)),
    );

    final keyEventHistoryJson = json['keyEventHistory'] as List? ?? [];
    final keyEventHistory = keyEventHistoryJson
        .map((event) => KeyState.fromJson(event as Map<String, dynamic>))
        .toList();

    return KeyboardState(
      keyStates: keyStates,
      keyEventHistory: keyEventHistory,
    );
  }
}
