import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/models/FurdleState.dart';
import 'package:flutter_template/pages/furdle.dart';
import 'package:flutter_template/pages/keyboard.dart';

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

  void toggle() {
    settingsController.isFurdleMode = !settingsController.isFurdleMode;
    setState(() {});
  }

  FState fState = FState();
  late FurdleNotifier furdleNotifier;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < _size; i++) {
      fState.addCell(FCellState(character: '', state: KeyState.isDefault));
    }
    furdleNotifier = FurdleNotifier(fState);
  }

  /// grid size
  int _size = 5;

  String furdle = 'Hello';

  KeyState characterToState(String letter) {
    int index = containsIndex(letter);
    if (index < 0) {
      return KeyState.notExists;
    } else if (isRightSpot(letter, index)) {
      return KeyState.exists;
    } else {
      return KeyState.misplaced;
    }
  }

  bool isRightSpot(String letter, int index) {
    return furdle[index] == letter;
  }

  int containsIndex(letter) {
    return furdle.toLowerCase().indexOf(letter);
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
                top: 20,
                left: 20,
                child: Row(
                  children: [
                    const Text('Furdle'),
                    Switch(
                      value: settingsController.isFurdleMode,
                      onChanged: (x) => toggle(),
                    ),
                  ],
                )),
            ValueListenableBuilder<FState>(
                valueListenable: furdleNotifier,
                builder: (x, y, z) {
                  return Furdle(
                    isDark: settingsController.themeMode == ThemeMode.dark,
                    fState: fState,
                    size: _size,
                  );
                }),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              bottom: settingsController.isFurdleMode ? 40.0 : 10.0,
              left: 0,
              right: 0,
              child: KeyBoardView(
                keyboardFocus: keyboardFocusNode,
                controller: textController,
                isFurdleMode: settingsController.isFurdleMode,
                onKeyEvent: (x) {
                  final character = x.toLowerCase();
                  if (character == 'enter' && fState.cellSize == _size) {
                    fState.clear();
                    fState.row++;
                  } else if (character == 'delete' ||
                      character == 'backspace') {
                    fState.removeCell();
                  } else {
                    fState.addCell(FCellState(
                        character: character,
                        state: characterToState(character)));
                  }
                  furdleNotifier.notify();
                },
              ),
            ),
          ],
        ));
  }
}
