
import 'package:flutter/material.dart';

class KeyBindrr {
  String character;
  bool isPressed;
  KeyBindrr({this.character = '', this.isPressed = false});
}

class SpecialKey {
  String character;

  /// position of key in the Row
  int position;
  Size size;
  SpecialKey(
      {this.character = '', this.position = 0, this.size = const Size(60, 60)});
}