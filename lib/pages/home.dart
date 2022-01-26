import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/models/key.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _toggleTheme() {
    if (settingsController.themeMode == ThemeMode.dark) {
      settingsController.updateThemeMode(ThemeMode.light);
    } else {
      settingsController.updateThemeMode(ThemeMode.dark);
    }
  }

  final keyboardFocusNode = FocusNode();
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              tooltip: 'theme',
              icon: const Icon(Icons.dark_mode),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                focusNode: keyboardFocusNode,
                controller: textController,
                maxLines: 20,
              ),
              KeyBoardView(
                keyboardFocus: keyboardFocusNode,
                controller: textController,
              ),
            ],
          ),
        ));
  }
}

class KeyBoardView extends StatefulWidget {
  final FocusNode? keyboardFocus;
  const KeyBoardView({Key? key, this.keyboardFocus, this.controller})
      : super(key: key);
  final TextEditingController? controller;
  @override
  _KeyBoardViewState createState() => _KeyBoardViewState();
}

class _KeyBoardViewState extends State<KeyBoardView> {
  late FocusNode keyboardFocus;
  late KeyBindrr bindrr;

  @override
  void dispose() {
    super.dispose();
    keyboardFocus.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bindrr = KeyBindrr(character: '', isPressed: false);
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(keyboardFocus);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth / 15;
        final keysize = size.clamp(20.0, 60.0);
        Size keySize = Size(keysize, keysize);

        Widget buildKeyRow(String string,
            {Map<String, SpecialKey>? specialKeys}) {
          final keys = string.buildKeys(bindrr, keySize: keySize,
              onPressed: (character) {
            setState(() {
              bindrr.character = character;
            });
          });
          if (specialKeys != null) {
            for (var key in specialKeys.keys) {
              final specialKey = specialKeys[key];
              keys.insert(
                  specialKey!.position,
                  KeyBuilder(
                      keyLabel: specialKey.character,
                      keySize: specialKey.size,
                      isPressed: bindrr.character == key && bindrr.isPressed
                          ? true
                          : false,
                      onPressed: (String character) {
                        if (character == 'delete') {
                          delete();
                        }
                        setState(() {
                          bindrr.character = character;
                        });
                      }));
            }
          }
          return Row(
              mainAxisAlignment: MainAxisAlignment.center, children: keys);
        }

        Widget buildSpace() {
          return Padding(
            padding: const EdgeInsets.only(left: 120.0),
            child: KeyBuilder(
                keyLabel: 'Space',
                keySize: keySize,
                onPressed: (String character) {
                  setState(() {
                    bindrr.character = character;
                  });
                },
                isPressed: (bindrr.isPressed && bindrr.character == ' '
                    ? true
                    : false),
                isSpaceKey: true),
          );
        }

        return KeyboardListener(
          focusNode: keyboardFocus,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              final character = event.logicalKey.keyLabel;
              if (character == 'Backspace') {
                delete();
              }
              setState(() {
                bindrr.isPressed = true;
                bindrr.character = character;
              });
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
              Text('Key Pressed: ${bindrr.character}'),
              buildKeyRow('`1234567890-=', specialKeys: {
                'Backspace': SpecialKey(
                  character: 'delete',
                  position: 13,
                  size: Size(keySize.width * 1.9, keySize.height),
                ),
              }),
              buildKeyRow('qwertyuiop[]\\', specialKeys: {
                'Tab': SpecialKey(
                  character: 'tab',
                  position: 0,
                  size: Size(keySize.width * 1.9, keySize.height),
                ),
              }),
              buildKeyRow('asdfghjkl;\'', specialKeys: {
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
              buildKeyRow('zxcvbnm,./', specialKeys: {
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
              buildSpace()
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

class KeyBuilder extends StatefulWidget {
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
  State<KeyBuilder> createState() => _KeyBuilderState();
}

class _KeyBuilderState extends State<KeyBuilder> {
  @override
  Widget build(BuildContext context) {
    final double _keySize = widget.keySize.width;
    final color = settingsController.themeMode == ThemeMode.dark
        ? Theme.of(context).splashColor
        : Colors.grey.withOpacity(0.5);
    double scaleFactor = _keySize / 60;
    bool isSpecialKey = widget.keyLabel.length > 2;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        splashColor: color,
        borderRadius: BorderRadius.circular(6),
        onTap: () => widget.onPressed(widget.keyLabel),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height:
              isSpecialKey ? min(widget.keySize.height, _keySize) : _keySize,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
              color: widget.isPressed ? color : null,
              borderRadius: BorderRadius.circular(6),
              border: Border.all()),
          width: widget.isSpaceKey ? _keySize * 5 : _keySize,
          alignment: Alignment.center,
          child: Text(
            widget.keyLabel.toUpperCase(),
            textScaleFactor: scaleFactor,
            style: TextStyle(
              fontSize: isSpecialKey ? 8 : 20,
            ),
          ),
        ),
      ),
    );
  }
}
