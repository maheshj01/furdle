import 'package:cloud_firestore/cloud_firestore.dart';

class DailyChallenge {
  final DateTime date;
  final DateTime nextRun;
  final int number;
  final String word;

  const DailyChallenge({
    required this.date,
    required this.nextRun,
    required this.number,
    required this.word,
  });

  factory DailyChallenge.initialize() {
    return DailyChallenge(
      date: DateTime.now(),
      nextRun: DateTime.now().add(const Duration(days: 1)),
      number: 0,
      word: '',
    );
  }

  factory DailyChallenge.fromFirestore(Map<String, dynamic> data) {
    return DailyChallenge(
      date: (data['date'] as Timestamp).toDate(),
      nextRun: (data['nextRun'] as Timestamp).toDate(),
      number: data['number'] as int,
      word: data['word'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'nextRun': nextRun.millisecondsSinceEpoch,
      'number': number,
      'word': word,
    };
  }

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      nextRun: DateTime.fromMillisecondsSinceEpoch(json['nextRun'] as int),
      number: json['number'] as int,
      word: json['word'] as String,
    );
  }

  @override
  String toString() {
    return 'DailyChallenge(number: $number, word: $word, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyChallenge &&
        other.number == number &&
        other.word == word &&
        other.date.day == date.day &&
        other.date.month == date.month &&
        other.date.year == date.year;
  }

  @override
  int get hashCode {
    return number.hashCode ^
        word.hashCode ^
        date.day.hashCode ^
        date.month.hashCode ^
        date.year.hashCode;
  }
}
