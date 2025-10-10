import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/provider/hive_storage_provider.dart';
import 'package:furdle/service/hive_storage_service.dart';
import 'package:furdle/state/game_state.dart';

/// Provider class for tracking user streak and completed game states
class GamesProvider extends AsyncNotifier<List<GameState>> {
  HiveStorageService get _storageService => ref.read(hiveStorageServiceProvider);

  @override
  Future<List<GameState>> build() async {
    return await getCompletedGames();
  }

  /// Saves a completed game state to List of completed game states
  Future<void> saveCompletedGame(GameState gameState) async {
    try {
      final allCompletedGameStates = await getCompletedGames();
      allCompletedGameStates.add(gameState);
      final jsonString =
          jsonEncode(allCompletedGameStates.map((GameState state) => state.toJson()).toList());
      await _storageService.set(Constants.completedStatesKey, jsonString);
      state = AsyncValue.data([...allCompletedGameStates]);
    } catch (e) {
      print('Error saving completed state: $e');
    }
  }

  /// Gets the list of completed game states
  Future<List<GameState>> getCompletedGames() async {
    final completedStates = await _storageService.get(Constants.completedStatesKey);
    if (completedStates == null) {
      return [];
    }
    final List<dynamic> jsonArray = jsonDecode(completedStates as String);
    // exclude inprogress games
    // final filteredJsonArray = jsonArray
    //     .where((json) => GameStatus.values[json['status'] as int] != GameStatus.inprogress)
    //     .toList();

    // print('filteredJsonArray: $filteredJsonArray');
    // print("value: ${GameStatus.values}");
    // return filteredJsonArray.map((json) => GameState.fromJson(json)).toList();
    return jsonArray.map((json) => GameState.fromJson(json)).toList();
  }

  /// Gets a completed game state by id
  Future<GameState?> getCompletedState(int stateId) async {
    final allCompletedGameStates = await getCompletedGames();
    try {
      final completedState = allCompletedGameStates.firstWhere((state) => state.id == stateId);
      return completedState;
    } catch (e) {
      // firstWhere throws an exception if no element is found
      return null;
    }
  }

  /// Calculates the current streak based on completed daily challenges
  Future<int> calculateCurrentStreak() async {
    final completedStates = await getCompletedGames();
    if (completedStates.isEmpty) return 0;

    // Filter only daily challenges and sort by date
    final dailyChallenges = completedStates
        .where((state) => state.gameType == GameType.daily && state.status == GameStatus.win)
        .toList();

    if (dailyChallenges.isEmpty) return 0;

    // Sort by start time (most recent first)
    dailyChallenges
        .sort((a, b) => (b.startTime ?? DateTime.now()).compareTo(a.startTime ?? DateTime.now()));

    int streak = 0;
    DateTime? lastChallengeDate;

    for (final state in dailyChallenges) {
      final startTime = state.startTime ?? DateTime.now();
      final challengeDate = DateTime(startTime.year, startTime.month, startTime.day);

      if (lastChallengeDate == null) {
        // First challenge
        streak = 1;
        lastChallengeDate = challengeDate;
      } else {
        // Check if this challenge is consecutive (previous day)
        final expectedDate = lastChallengeDate.subtract(const Duration(days: 1));
        if (challengeDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          lastChallengeDate = challengeDate;
        } else {
          // Streak broken
          break;
        }
      }
    }

    return streak;
  }

  /// Gets the longest streak achieved
  Future<int> getLongestStreak() async {
    final completedStates = await getCompletedGames();
    if (completedStates.isEmpty) return 0;

    // Filter only daily challenges and sort by date
    final dailyChallenges = completedStates
        .where((state) => state.gameType == GameType.daily && state.status == GameStatus.win)
        .toList();

    if (dailyChallenges.isEmpty) return 0;

    // Sort by start time (oldest first)
    dailyChallenges
        .sort((a, b) => (a.startTime ?? DateTime.now()).compareTo(b.startTime ?? DateTime.now()));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastChallengeDate;

    for (final state in dailyChallenges) {
      final startTime = state.startTime ?? DateTime.now();
      final challengeDate = DateTime(startTime.year, startTime.month, startTime.day);

      if (lastChallengeDate == null) {
        currentStreak = 1;
        lastChallengeDate = challengeDate;
      } else {
        // Check if this challenge is consecutive (next day)
        final expectedDate = lastChallengeDate.add(const Duration(days: 1));
        if (challengeDate.isAtSameMomentAs(expectedDate)) {
          currentStreak++;
          lastChallengeDate = challengeDate;
        } else {
          // Streak broken, update longest streak and reset
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
          currentStreak = 1;
          lastChallengeDate = challengeDate;
        }
      }
    }

    // Check if the final streak is the longest
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    return longestStreak;
  }

  /// Gets the total number of games won
  Future<int> getTotalGamesWon() async {
    final completedStates = await getCompletedGames();
    return completedStates.where((state) => state.status == GameStatus.win).length;
  }

  /// Gets the total number of daily challenges completed
  Future<int> getTotalDailyChallengesCompleted() async {
    final completedStates = await getCompletedGames();
    return completedStates
        .where((state) => state.gameType == GameType.daily && state.status == GameStatus.win)
        .length;
  }

  /// Clears all completed states (useful for testing or reset)
  Future<void> clearAllCompletedStates() async {
    await _storageService.remove(Constants.completedStatesKey);
  }
}

/// Provider for StreakProvider instance
final gamesProvider = AsyncNotifierProvider<GamesProvider, List<GameState>>(GamesProvider.new);
