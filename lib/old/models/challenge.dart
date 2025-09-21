import 'package:cloud_firestore/cloud_firestore.dart';

/// Local play status for a challenge on this device
enum ChallengePlayStatus {
  notStarted,
  inProgress,
  completed,
}

/// Server-sourced daily challenge
class Challenge {
  final int id; // incremental number published by backend
  final String word; // 5-letter word for the day
  final DateTime publishedAt; // UTC time when this challenge was published
  final DateTime nextRun; // UTC time when the next challenge goes live

  const Challenge({
    required this.id,
    required this.word,
    required this.publishedAt,
    required this.nextRun,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'publishedAt': publishedAt.toIso8601String(),
        'nextRun': nextRun.toIso8601String(),
      };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as int,
        word: json['word'] as String,
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        nextRun: DateTime.parse(json['nextRun'] as String),
      );

  /// Create from Firestore doc `furdle/stats` produced by Cloud Functions
  factory Challenge.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final Timestamp dateTs = data['date'] as Timestamp;
    final Timestamp nextRunTs = data['nextRun'] as Timestamp;
    return Challenge(
      id: (data['number'] as num).toInt(),
      word: data['word'] as String,
      publishedAt: dateTs.toDate().toUtc(),
      nextRun: nextRunTs.toDate().toUtc(),
    );
  }
}

/// Local-only persistence describing how the user is interacting with a challenge
class ChallengeProgress {
  final int challengeId;
  final ChallengePlayStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const ChallengeProgress({
    required this.challengeId,
    required this.status,
    this.startedAt,
    this.completedAt,
  });

  ChallengeProgress copyWith({
    ChallengePlayStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) =>
      ChallengeProgress(
        challengeId: challengeId,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
      );

  Map<String, dynamic> toJson() => {
        'challengeId': challengeId,
        'status': status.name,
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    final statusString = json['status'] as String? ?? 'notStarted';
    final ChallengePlayStatus status;
    switch (statusString) {
      case 'inProgress':
        status = ChallengePlayStatus.inProgress;
        break;
      case 'completed':
        status = ChallengePlayStatus.completed;
        break;
      case 'notStarted':
      default:
        status = ChallengePlayStatus.notStarted;
    }
    return ChallengeProgress(
      challengeId: (json['challengeId'] as num).toInt(),
      status: status,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

/// Result for startup decision
enum ChallengeDecision {
  resumeExisting, // there is a local challenge in progress
  startNew, // new challenge available and not yet completed
  showCompletedTimer, // today's challenge is already completed on this device
}

class ChallengeStartupResult {
  final Challenge challenge;
  final ChallengeDecision decision;

  const ChallengeStartupResult({
    required this.challenge,
    required this.decision,
  });
}
