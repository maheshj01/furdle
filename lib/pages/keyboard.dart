import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/models/models.dart';
import 'package:furdle/shared/providers/game_state_provider.dart';
import 'package:furdle/shared/theme/theme.dart';

class KeyBoardView extends ConsumerStatefulWidget {
  /// defines whether the keyboard to be shown is for furdle mode
  final bool isFurdleMode;
  final Function(String, bool) onKeyEvent;
  final FocusNode? keyboardFocus;
  const KeyBoardView(
      {Key? key,
      this.keyboardFocus,
      this.controller,
      required this.onKeyEvent,
      this.isFurdleMode = false})
      : super(key: key);
  final TextEditingController? controller;
  @override
  _KeyBoardViewState createState() => _KeyBoardViewState();
}

class _KeyBoardViewState extends ConsumerState<KeyBoardView> {
  late FocusNode keyboardFocus;

  @override
  void dispose() {
    super.dispose();
    keyboardFocus.dispose();
  }

  @override
  void initState() {
    super.initState();
    keyboardFocus = widget.keyboardFocus ?? FocusNode();
    controller = widget.controller ?? TextEditingController();
  }

  late final TextEditingController? controller;

  void delete() {
    final text = controller!.text;
    if (text.isEmpty) {
      return;
    }
    controller!.text = text.substring(0, text.length - 1);
  }

  bool isCapsLockOn = false;

  /// determine if key is pressed ;
  bool isKeyPressed(String label) {
    if (isCapsLockOn && label == 'Caps Lock') {
      return true;
    } else {
      return bindrr.character == label && bindrr.isPressed;
    }
  }

  /// update special Characters
  void updateBindrr(String x) {
    setState(() {
      bindrr.character = x;
    });
    widget.onKeyEvent(bindrr.character, false);
  }

  KeyBindrr bindrr = KeyBindrr(character: '', isPressed: false);
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(keyboardFocus);
    });
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthFactor = widget.isFurdleMode ? 11 : 18;
        final size = constraints.maxWidth / widthFactor;
        final keysize = size.clamp(20.0, 50.0);
        final Size keySize = Size(keysize, keysize);

        Widget buildKeyRow(String string,
            {Map<String, SpecialKey>? specialKeys}) {
          final _characters =
              isCapsLockOn ? string.toUpperCase() : string.toLowerCase();
          final keys = _characters.buildKeys(bindrr, keySize: keySize,
              onPressed: (character) {
            setState(() {
              bindrr.character = character;
            });
            HapticFeedback.heavyImpact();
            widget.onKeyEvent(bindrr.character, false);
          });

          /// Special Key Events ![A-z]
          if (specialKeys != null && !widget.isFurdleMode) {
            for (var key in specialKeys.keys) {
              final specialKey = specialKeys[key];
              keys.insert(
                  specialKey!.position,
                  KeyBuilder(
                      keyLabel: specialKey.character,
                      keySize: specialKey.size,
                      isPressed: isKeyPressed(key),
                      onPressed: (String character) {
                        if (character == 'delete' && !widget.isFurdleMode) {
                          delete();
                        }
                        updateBindrr(character);
                      }));
            }
          }
          return Row(
              mainAxisAlignment: MainAxisAlignment.center, children: keys);
        }

        Widget buildSpace() {
          return KeyBuilder(
              keyLabel: 'Space',
              keySize: keySize,
              onPressed: updateBindrr,
              isPressed: isKeyPressed(' '),
              isSpaceKey: true);
        }

        return KeyboardListener(
          focusNode: keyboardFocus,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              final character = event.logicalKey.keyLabel;
              if (character == 'Backspace') {
                delete();
              } else if (character == 'Caps Lock') {
                isCapsLockOn = !isCapsLockOn;
              }
              setState(() {
                bindrr.isPressed = true;
                bindrr.character = character;
              });
              widget.onKeyEvent(bindrr.character, true);
            } else if (event is KeyUpEvent) {
              /// Delay for key fade animation
              Future.delayed(const Duration(milliseconds: 200), () {
                setState(() {
                  bindrr.isPressed = false;
                });
              });
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widget.isFurdleMode
                  ? const SizedBox()
                  : buildKeyRow('`1234567890-=', specialKeys: {
                      'Backspace': SpecialKey(
                        character: 'delete',
                        position: 13,
                        size: Size(keySize.width * 1.9, keySize.height),
                      ),
                    }),
              buildKeyRow(widget.isFurdleMode ? 'qwertyuiop' : 'qwertyuiop[]\\',
                  specialKeys: {
                    'Tab': SpecialKey(
                      character: 'tab',
                      position: 0,
                      size: Size(keySize.width * 1.9, keySize.height),
                    ),
                  }),
              buildKeyRow(widget.isFurdleMode ? 'asdfghjkl' : 'asdfghjkl;\'',
                  specialKeys: {
                    'Caps Lock': SpecialKey(
                      character: 'Caps Lock',
                      position: 0,
                      size: Size(keySize.width * 2, keySize.height),
                    ),
                    'Enter': SpecialKey(
                      character: 'return',
                      position: 12,
                      size: Size(keySize.width * 2, keySize.height),
                    ),
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.isFurdleMode
                      ? KeyBuilder(
                          keyLabel: 'Enter',
                          onPressed: updateBindrr,
                          isPressed: isKeyPressed('Enter'),
                          keySize: Size(keySize.width * 1.4, keySize.height),
                        )
                      : const SizedBox(),
                  buildKeyRow(widget.isFurdleMode ? 'zxcvbnm' : 'zxcvbnm,./',
                      specialKeys: {
                        'Shift Left': SpecialKey(
                          character: 'Shift',
                          position: 0,
                          size: Size(keySize.width * 2.5, keySize.height),
                        ),
                        'Shift Right': SpecialKey(
                          character: 'Shift',
                          position: 11,
                          size: Size(keySize.width * 2.5, keySize.height),
                        ),
                      }),
                  widget.isFurdleMode
                      ? KeyBuilder(
                          keyLabel: 'delete',
                          onPressed: updateBindrr,
                          isPressed: isKeyPressed('Backspace'),
                          keySize: Size(keySize.width * 1.4, keySize.height))
                      : const SizedBox(),
                ],
              ),
              widget.isFurdleMode ? const SizedBox() : buildSpace()
            ],
          ),
        );
      },
    );
  }
}

extension on String {
  List<Widget> buildKeys(KeyBindrr keyBindrr,
          {Function(String)? onPressed, Size? keySize}) =>
      split('')
          .map((e) => KeyBuilder(
                keyLabel: e,
                keySize: keySize!,
                isPressed:
                    keyBindrr.character.toLowerCase() == e.toLowerCase() &&
                            keyBindrr.isPressed
                        ? true
                        : false,
                onPressed: (String character) => onPressed!(character),
              ))
          .toList();
}

class KeyBuilder extends ConsumerStatefulWidget {
  const KeyBuilder(
      {Key? key,
      required this.keyLabel,
      required this.onPressed,
      required this.isPressed,
      this.keySize = const Size(60, 60),
      this.isSpaceKey = false})
      : super(key: key);

  final String keyLabel;

  /// onPressed callback when key is pressed
  /// via mouse click
  final Function(String) onPressed;

  final bool isSpaceKey;

  final bool isPressed;

  final Size keySize;

  @override
  ConsumerState<KeyBuilder> createState() => _KeyBuilderState();
}

class _KeyBuilderState extends ConsumerState<KeyBuilder> {
  Color stateToColor(Cell state) {
    switch (state) {
      case Cell.match:
        return Colors.green;
      case Cell.notExists:
        return Colors.black87;
      case Cell.misplaced:
        return Colors.yellow[800]!;
      case Cell.empty:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double _keySize = widget.keySize.width;
    final themeMode = ref.watch(appThemeProvider);
    final bool isDark = themeMode == ThemeMode.dark;
    final color =
        isDark ? Theme.of(context).splashColor : Colors.grey.withOpacity(0.5);
    final double scaleFactor = _keySize / 60;
    final bool isSpecialKey = widget.keyLabel.length > 1;
    final GameState state = ref.watch(gameStateProvider);
    final keyState =
        state.kState.keyboardState[widget.keyLabel.toLowerCase()] ?? Cell.empty;
    final keyColor = stateToColor(keyState);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        splashColor: color,
        borderRadius: BorderRadius.circular(6),
        onTap: () => widget.onPressed(widget.keyLabel),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isSpecialKey ? min(widget.keySize.height, _keySize) : 48,
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
          decoration: BoxDecoration(
              color: widget.isPressed ? Colors.grey[600] : keyColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all()),
          width: widget.isSpaceKey ? _keySize * 5 : _keySize,
          alignment: Alignment.center,
          child: Text(
            widget.keyLabel,
            textScaler: TextScaler.linear(scaleFactor),
            style: TextStyle(
                fontSize: isSpecialKey ? 10 : 25,
                color: keyState == Cell.notExists ? Colors.white : null),
          ),
        ),
      ),
    );
  }
}
