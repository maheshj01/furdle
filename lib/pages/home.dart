import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/main.dart';

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
        body: const KeyBoardView());
  }
}

class KeyBindrr {
  String character;
  bool isPressed;
  KeyBindrr({this.character = '', this.isPressed = false});
}

class KeyBoardView extends StatefulWidget {
  const KeyBoardView({Key? key}) : super(key: key);

  @override
  _KeyBoardViewState createState() => _KeyBoardViewState();
}

class _KeyBoardViewState extends State<KeyBoardView> {
  final keyboardFocus = FocusNode();
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
  }

  @override
  Widget build(BuildContext context) {
    Widget buildKeyRow(String string) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: string.buildKeys(bindrr, onPressed: (character) {
          setState(() {
            bindrr.character = character;
          });
        }),
      );
    }

    Widget buildSpace() {
      return Padding(
        padding: const EdgeInsets.only(left: 120.0),
        child: KeyBuilder(
            keyLabel: 'Space',
            onPressed: (String character) {
              setState(() {
                bindrr.character = character;
              });
            },
            isPressed:
                (bindrr.isPressed && bindrr.character == ' ' ? true : false),
            isSpaceKey: true),
      );
    }

    FocusScope.of(context).requestFocus(keyboardFocus);

    return KeyboardListener(
      focusNode: keyboardFocus,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          setState(() {
            bindrr.isPressed = true;
            bindrr.character = event.character.toString();
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
          buildKeyRow('qwertyuiop[]\\'),
          buildKeyRow('asdfghjkl;\''),
          buildKeyRow('zxcvbnm,./'),
          buildSpace()
        ],
      ),
    );
  }
}

extension on String {
  List<Widget> buildKeys(KeyBindrr keyBindrr, {Function(String)? onPressed}) =>
      split('')
          .map((e) => KeyBuilder(
                keyLabel: e,
                isPressed: keyBindrr.character == e && keyBindrr.isPressed
                    ? true
                    : false,
                onPressed: (String character) => onPressed!(character),
              ))
          .toList();
}

class KeyBuilder extends StatefulWidget {
  final String keyLabel;
  final Function(String) onPressed;
  final bool isSpaceKey;
  final bool isPressed;
  const KeyBuilder(
      {Key? key,
      required this.keyLabel,
      required this.onPressed,
      required this.isPressed,
      this.isSpaceKey = false})
      : super(key: key);

  @override
  State<KeyBuilder> createState() => _KeyBuilderState();
}

class _KeyBuilderState extends State<KeyBuilder> {
  @override
  void didUpdateWidget(covariant KeyBuilder oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print('updated');
  }

  @override
  Widget build(BuildContext context) {
    final double _keySize = 60;

    final color = settingsController.themeMode == ThemeMode.dark
        ? Theme.of(context).splashColor
        : Colors.grey.withOpacity(0.5);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        splashColor: color,
        borderRadius: BorderRadius.circular(10),
        onTap: () => widget.onPressed(widget.keyLabel),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _keySize,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
              color: widget.isPressed ? color : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all()),
          width: widget.isSpaceKey ? _keySize * 5 : _keySize,
          alignment: Alignment.center,
          child: Text(
            widget.keyLabel.toUpperCase(),
            textScaleFactor: 0.8,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
