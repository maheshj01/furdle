import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/old/models/challenge.dart';
import 'package:furdle/old/service/storage_service.dart';
import 'package:furdle/old/shared/providers/storage_service_provider.dart';

/// Storage keys for challenge-specific local state
class ChallengeStorageKeys {
  static const String currentProgress = Constants.challengeProgressKey;
  static const String completedSet = Constants.challengeCompletedIdsKey;
}

/// Repository that reads the daily challenge doc and manages local progress
class ChallengeRepository {
  ChallengeRepository({required this.firestore, required this.storage});

  final FirebaseFirestore firestore;
  final StorageService storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection(Constants.collectionProd);

  DocumentReference<Map<String, dynamic>> get _statsDoc =>
      _collection.doc(Constants.statsProd);

  Future<Challenge> fetchTodayChallenge() async {
    final snap = await _statsDoc.get();
    return Challenge.fromFirestore(snap);
  }

  Future<ChallengeProgress?> readCurrentProgress() async {
    final raw = await storage.get(ChallengeStorageKeys.currentProgress);
    if (raw is! String || raw.isEmpty) return null;
    try {
      return ChallengeProgress.fromJson(
          json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeCurrentProgress(ChallengeProgress progress) async {
    await storage.set(
      ChallengeStorageKeys.currentProgress,
      json.encode(progress.toJson()),
    );
  }

  Future<Set<int>> readCompletedIds() async {
    final raw = await storage.get(ChallengeStorageKeys.completedSet);
    if (raw is! String || raw.isEmpty) return <int>{};
    try {
      final list = (json.decode(raw) as List<dynamic>).cast<int>();
      return list.toSet();
    } catch (_) {
      return <int>{};
    }
  }

  Future<void> writeCompletedIds(Set<int> ids) async {
    await storage.set(
      ChallengeStorageKeys.completedSet,
      json.encode(ids.toList()),
    );
  }

  /// Apply the startup rules and return what the app should do
  Future<ChallengeStartupResult> resolveStartup() async {
    final serverChallenge = await fetchTodayChallenge();

    // 1) If we have an in-progress challenge locally, resume it
    final progress = await readCurrentProgress();
    if (progress != null &&
        progress.status == ChallengePlayStatus.inProgress &&
        progress.challengeId == serverChallenge.id) {
      return ChallengeStartupResult(
        challenge: serverChallenge,
        decision: ChallengeDecision.resumeExisting,
      );
    }

    // 2) If user already completed today's challenge, show timer
    final completed = await readCompletedIds();
    if (completed.contains(serverChallenge.id)) {
      return ChallengeStartupResult(
        challenge: serverChallenge,
        decision: ChallengeDecision.showCompletedTimer,
      );
    }

    // 3) No progress and not completed ⇒ start new challenge
    final newProgress = ChallengeProgress(
      challengeId: serverChallenge.id,
      status: ChallengePlayStatus.notStarted,
    );
    await writeCurrentProgress(newProgress);

    return ChallengeStartupResult(
      challenge: serverChallenge,
      decision: ChallengeDecision.startNew,
    );
  }

  /// Mark as started when user begins typing
  Future<void> markStarted(int challengeId) async {
    final progress = (await readCurrentProgress()) ??
        ChallengeProgress(
            challengeId: challengeId, status: ChallengePlayStatus.notStarted);
    await writeCurrentProgress(progress.copyWith(
      status: ChallengePlayStatus.inProgress,
      startedAt: progress.startedAt ?? DateTime.now().toUtc(),
    ));
  }

  /// Mark completion and remember in the completed set
  Future<void> markCompleted(int challengeId) async {
    final progress = (await readCurrentProgress()) ??
        ChallengeProgress(
            challengeId: challengeId, status: ChallengePlayStatus.notStarted);
    await writeCurrentProgress(progress.copyWith(
      status: ChallengePlayStatus.completed,
      completedAt: DateTime.now().toUtc(),
    ));

    final done = await readCompletedIds();
    done.add(challengeId);
    await writeCompletedIds(done);
  }
}

final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final firestore = ref.watch(_firestoreProvider);
  return ChallengeRepository(firestore: firestore, storage: storage);
});

/// Runs the startup decision tree and returns what the app should do right now
final challengeStartupProvider =
    FutureProvider<ChallengeStartupResult>((ref) async {
  final repo = ref.watch(challengeRepositoryProvider);
  return repo.resolveStartup();
});
