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
        body: SingleChildScrollView(
          child: Column(
            children: const [
              TextField(
                maxLines: 20,
              ),
              KeyBoardView(),
            ],
          ),
        ));
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
    FocusScope.of(context).requestFocus(keyboardFocus);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth / 15;
        double keySize = size.clamp(20, 60);
        Widget buildKeyRow(String string) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: string.buildKeys(bindrr, keySize: keySize,
                onPressed: (character) {
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
      },
    );
  }
}

extension on String {
  List<Widget> buildKeys(KeyBindrr keyBindrr,
          {Function(String)? onPressed, double? keySize}) =>
      split('')
          .map((e) => KeyBuilder(
                keyLabel: e,
                keySize: keySize!,
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
  final double keySize;
  const KeyBuilder(
      {Key? key,
      required this.keyLabel,
      required this.onPressed,
      required this.isPressed,
      this.keySize = 60.0,
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
  }

  @override
  Widget build(BuildContext context) {
    final double _keySize = widget.keySize;

    final color = settingsController.themeMode == ThemeMode.dark
        ? Theme.of(context).splashColor
        : Colors.grey.withOpacity(0.5);
    double scaleFactor = _keySize / 60;
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
              borderRadius: BorderRadius.circular(_keySize / 6),
              border: Border.all()),
          width: widget.isSpaceKey ? _keySize * 5 : _keySize,
          alignment: Alignment.center,
          child: Text(
            widget.keyLabel.toUpperCase(),
            textScaleFactor: scaleFactor,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
