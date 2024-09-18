import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/strings.dart';
import 'package:furdle/models/game.dart';

class KState{
  final Map<String, Cell> _keyboardState = {};

  Map<String, Cell> get keyboardState => _keyboardState;

  KState.initialize() {
    _keyboardState.clear();
    alphabets.split('').toList().forEach((element) {
      final state = FCellState(character: element, state: Cell.empty);
      updateKey(state);
    });
  }

  Map<String, Object> toJson(){
    final Map<String, Object> json = {};
    _keyboardState.forEach((key, value) {
      json[key] = value.name;
    });
    return json;
  }

  void fromJson(Map<String, dynamic> json){
    _keyboardState.clear();
    json.forEach((key, value) {
      final state = FCellState(character: key, state: Cell.empty);
      updateKey(state);
    });
  }

  void updateKey(FCellState key) {
    _keyboardState[key.character] = key.state;
  }
}
