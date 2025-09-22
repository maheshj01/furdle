import 'dart:convert';

import 'package:furdle/models/daily_challenge.dart';
import 'package:furdle/service/storage_service.dart';
import 'package:furdle/state/game_state.dart' show GameState;
import 'package:furdle/state/keyboard_state.dart' show KeyboardState;
import 'package:hive/hive.dart';

class HiveStorageService implements StorageService {
  static const String _gameStateBoxName = 'gameState';
  static const String _keyboardStateBoxName = 'keyboardState';
  static const String _settingsBoxName = 'settings';

  Box<String>? _gameStateBox;
  Box<String>? _keyboardStateBox;
  Box<String>? _settingsBox;

  bool _initialized = false;

  @override
  bool get hasInitialized => _initialized;

  @override
  void init() {
    // Initialization is handled in initializeHive
  }

  Future<void> initializeHive() async {
    if (_initialized) return;

    // Open boxes - we'll use String boxes and handle JSON serialization manually
    _gameStateBox = await Hive.openBox<String>(_gameStateBoxName);
    _keyboardStateBox = await Hive.openBox<String>(_keyboardStateBoxName);
    _settingsBox = await Hive.openBox<String>(_settingsBoxName);

    _initialized = true;
  }

  @override
  Future<Object?> get(String key) async {
    await _ensureInitialized();

    // Try different boxes based on key pattern
    if (key.contains('game_state') || key.contains('app_game_state')) {
      return _gameStateBox?.get(key);
    } else if (key.contains('keyboard')) {
      return _keyboardStateBox?.get(key);
    } else {
      return _settingsBox?.get(key);
    }
  }

  @override
  Future<bool> set(String key, String data) async {
    await _ensureInitialized();

    try {
      // Route to appropriate box based on key pattern
      if (key.contains('game_state') || key.contains('app_game_state')) {
        await _gameStateBox?.put(key, data);
      } else if (key.contains('keyboard')) {
        await _keyboardStateBox?.put(key, data);
      } else {
        await _settingsBox?.put(key, data);
      }
      return true;
    } catch (e) {
      print('Error setting key $key: $e');
      return false;
    }
  }

  @override
  Future<bool> remove(String key) async {
    await _ensureInitialized();

    try {
      if (key.contains('game_state') || key.contains('app_game_state')) {
        await _gameStateBox?.delete(key);
      } else if (key.contains('keyboard')) {
        await _keyboardStateBox?.delete(key);
      } else {
        await _settingsBox?.delete(key);
      }
      return true;
    } catch (e) {
      print('Error removing key $key: $e');
      return false;
    }
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();

    await _gameStateBox?.clear();
    await _keyboardStateBox?.clear();
    await _settingsBox?.clear();
  }

  @override
  Future<bool> has(String key) async {
    await _ensureInitialized();

    if (key.contains('game_state') || key.contains('app_game_state')) {
      return _gameStateBox?.containsKey(key) ?? false;
    } else if (key.contains('keyboard')) {
      return _keyboardStateBox?.containsKey(key) ?? false;
    } else {
      return _settingsBox?.containsKey(key) ?? false;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initializeHive();
    }
  }

  // Specialized methods for game state
  Future<GameState?> getGameState() async {
    await _ensureInitialized();
    final jsonString = _gameStateBox?.get('current_game_state');
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return GameState.fromJson(json);
      } catch (e) {
        print('Error deserializing game state: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveGameState(GameState gameState) async {
    await _ensureInitialized();
    try {
      final jsonString = jsonEncode(gameState.toJson());
      await _gameStateBox?.put('current_game_state', jsonString);
    } catch (e) {
      print('Error saving game state: $e');
    }
  }

  // Specialized methods for keyboard state
  Future<KeyboardState?> getKeyboardState() async {
    await _ensureInitialized();
    final jsonString = _keyboardStateBox?.get('current_keyboard_state');
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return KeyboardState.fromJson(json);
      } catch (e) {
        print('Error deserializing keyboard state: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveKeyboardState(KeyboardState keyboardState) async {
    await _ensureInitialized();
    try {
      final jsonString = jsonEncode(keyboardState.toJson());
      await _keyboardStateBox?.put('current_keyboard_state', jsonString);
    } catch (e) {
      print('Error saving keyboard state: $e');
    }
  }

  // Challenge tracking methods
  Future<void> saveCurrentChallenge(DailyChallenge challenge) async {
    await _ensureInitialized();
    try {
      final jsonString = jsonEncode(challenge.toJson());
      await _settingsBox?.put('current_challenge', jsonString);
    } catch (e) {
      print('Error saving current challenge: $e');
    }
  }

  Future<DailyChallenge?> getCurrentChallenge() async {
    await _ensureInitialized();
    final jsonString = _settingsBox?.get('current_challenge');
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return DailyChallenge.fromJson(json);
      } catch (e) {
        print('Error deserializing current challenge: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> markChallengeCompleted(String challengeId) async {
    await _ensureInitialized();
    try {
      await _settingsBox?.put('completed_challenge_$challengeId', 'true');
    } catch (e) {
      print('Error marking challenge completed: $e');
    }
  }

  Future<bool> isChallengeCompleted(String challengeId) async {
    await _ensureInitialized();
    final completed = _settingsBox?.get('completed_challenge_$challengeId');
    return completed == 'true';
  }

  Future<void> clearCompletedChallenges() async {
    await _ensureInitialized();
    try {
      final keys = _settingsBox?.keys.where((key) => key.toString().startsWith('completed_challenge_')).toList() ?? [];
      for (final key in keys) {
        await _settingsBox?.delete(key);
      }
    } catch (e) {
      print('Error clearing completed challenges: $e');
    }
  }

  // Close all boxes
  Future<void> close() async {
    await _gameStateBox?.close();
    await _keyboardStateBox?.close();
    await _settingsBox?.close();
    _initialized = false;
  }
}
