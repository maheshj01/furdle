// class to represent the state of a single key
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/ui/keyboard.dart';

class KeyState {
  /// The event type of the key
  /// whether the key is pressed or released or tap cancelled
  final KeyEventType event;

  /// Whether the key is a physical key
  final bool isPhysicalKey;

  /// Whether the key is a special key
  /// like space, backspace, enter
  final bool isSpecial;

  /// The status of the letter in the word
  final CellType cellType;
  final DateTime? timeStamp;
  final String key; // Add the key identifier

  const KeyState({
    required this.key,
    this.event = KeyEventType.keyUp,
    this.isPhysicalKey = false,
    this.cellType = CellType.empty,
    this.timeStamp,
    this.isSpecial = false,
  });

  KeyState copyWith({
    String? key,
    KeyEventType? event,
    bool? isPhysicalKey,
    CellType? cellType,
    DateTime? timeStamp,
    bool? isSpecial,
    int? widthCount,
  }) {
    return KeyState(
      key: key ?? this.key,
      event: event ?? this.event,
      isPhysicalKey: isPhysicalKey ?? this.isPhysicalKey,
      cellType: cellType ?? this.cellType,
      timeStamp: timeStamp ?? this.timeStamp,
      isSpecial: isSpecial ?? this.isSpecial,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeyState &&
        other.key == key &&
        other.event == event &&
        other.isPhysicalKey == isPhysicalKey &&
        other.cellType == cellType &&
        other.timeStamp == timeStamp &&
        other.isSpecial == isSpecial;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      event.hashCode ^
      isPhysicalKey.hashCode ^
      cellType.hashCode ^
      timeStamp.hashCode ^
      isSpecial.hashCode;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'event': event.index,
      'isPhysicalKey': isPhysicalKey,
      'cellType': cellType.index,
      'timeStamp': timeStamp?.millisecondsSinceEpoch,
      'isSpecial': isSpecial,
    };
  }

  static KeyState fromJson(Map<String, dynamic> json) {
    return KeyState(
      key: json['key'] as String,
      event: KeyEventType.values[json['event'] as int? ?? 0],
      isPhysicalKey: json['isPhysicalKey'] as bool? ?? false,
      cellType: CellType.values[json['cellType'] as int? ?? 0],
      timeStamp: json['timeStamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timeStamp'] as int)
          : null,
      isSpecial: json['isSpecial'] as bool? ?? false,
    );
  }
}
