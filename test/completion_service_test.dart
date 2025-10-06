import 'package:flutter_test/flutter_test.dart';
import 'package:furdle/service/completion_service.dart';

void main() {
  group('CompletionService data classes', () {
    test('CompletionResult should create correctly', () {
      final result = CompletionResult(
        success: true,
        isFirstCompletion: true,
        totalCompletions: 1,
        message: 'First completion!',
      );

      expect(result.success, equals(true));
      expect(result.isFirstCompletion, equals(true));
      expect(result.totalCompletions, equals(1));
      expect(result.message, equals('First completion!'));
    });

    test('CompletionStats should create correctly', () {
      final stats = CompletionStats(
        success: true,
        totalCompletions: 5,
        hasFirstCompletion: true,
        firstCompletionAttempts: 3,
      );

      expect(stats.success, equals(true));
      expect(stats.totalCompletions, equals(5));
      expect(stats.hasFirstCompletion, equals(true));
      expect(stats.firstCompletionAttempts, equals(3));
    });

    test('CompletionStats should handle null firstCompletionAttempts', () {
      final stats = CompletionStats(
        success: true,
        totalCompletions: 0,
        hasFirstCompletion: false,
      );

      expect(stats.firstCompletionAttempts, isNull);
    });
  });
}