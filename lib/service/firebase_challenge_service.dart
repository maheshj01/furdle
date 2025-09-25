import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furdle/models/daily_challenge.dart';

class FirebaseChallengeService {
  static const String _collectionName = 'furdle';
  static const String _documentName = 'stats';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the current daily challenge from Firebase
  Future<DailyChallenge?> getCurrentChallenge() async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(_documentName).get();

      if (!doc.exists) {
        print('Challenge document does not exist');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        print('Challenge document has no data');
        return DailyChallenge.initialize();
      }

      return DailyChallenge.fromFirestore(data);
    } catch (e) {
      print('Error fetching daily challenge: $e');
      return null;
    }
  }

  /// Checks if the current challenge is still valid (not expired)
  bool isChallengeValid(DailyChallenge challenge) {
    final now = DateTime.now();
    return now.isBefore(challenge.nextRun);
  }

  /// Gets a formatted date string for the challenge
  String getChallengeDateString(DailyChallenge challenge) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[challenge.date.month - 1]} ${challenge.date.day}, ${challenge.date.year}';
  }
}
