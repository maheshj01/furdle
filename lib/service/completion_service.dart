import 'package:cloud_functions/cloud_functions.dart';

class CompletionService {
  static const String _reportCompletionFunction = 'reportCompletion';
  static const String _getCompletionStatsFunction = 'getCompletionStats';

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Reports a puzzle completion to the server
  /// Returns true if this was the first completion of the day
  Future<CompletionResult> reportCompletion({
    required String challengeId,
    required int challengeNumber,
    required int attempts,
    String? twitterUsername,
  }) async {
    try {
      final callable = _functions.httpsCallable(_reportCompletionFunction);
      final result = await callable.call({
        'challengeId': challengeId,
        'challengeNumber': challengeNumber,
        'attempts': attempts,
        'twitterUsername': twitterUsername,
      });

      final data = result.data as Map<String, dynamic>;
      return CompletionResult(
        success: data['success'] ?? false,
        isFirstCompletion: data['isFirstCompletion'] ?? false,
        totalCompletions: data['totalCompletions'] ?? 0,
        message: data['message'] ?? '',
      );
    } catch (e) {
      print('Error reporting completion: $e');
      // Return a default success result so game completion isn't blocked
      return CompletionResult(
        success: true,
        isFirstCompletion: false,
        totalCompletions: 0,
        message: 'Completion recorded locally',
      );
    }
  }

  /// Gets completion statistics for a challenge
  Future<CompletionStats> getCompletionStats(String challengeId) async {
    try {
      final callable = _functions.httpsCallable(_getCompletionStatsFunction);
      final result = await callable.call({
        'challengeId': challengeId,
      });

      final data = result.data as Map<String, dynamic>;
      return CompletionStats(
        success: data['success'] ?? false,
        totalCompletions: data['totalCompletions'] ?? 0,
        hasFirstCompletion: data['hasFirstCompletion'] ?? false,
        firstCompletionAttempts: data['firstCompletionAttempts'],
      );
    } catch (e) {
      print('Error getting completion stats: $e');
      return CompletionStats(
        success: false,
        totalCompletions: 0,
        hasFirstCompletion: false,
      );
    }
  }
}

class CompletionResult {
  final bool success;
  final bool isFirstCompletion;
  final int totalCompletions;
  final String message;

  CompletionResult({
    required this.success,
    required this.isFirstCompletion,
    required this.totalCompletions,
    required this.message,
  });
}

class CompletionStats {
  final bool success;
  final int totalCompletions;
  final bool hasFirstCompletion;
  final int? firstCompletionAttempts;

  CompletionStats({
    required this.success,
    required this.totalCompletions,
    required this.hasFirstCompletion,
    this.firstCompletionAttempts,
  });
}