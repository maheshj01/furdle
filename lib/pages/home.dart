import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/models/furdle.dart';
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
    super.initState();
    for (int i = 0; i < _size; i++) {
      List<FCellState> row = [];
      for (int j = 0; j < _size; j++) {
        row.add(FCellState.defaultState());
      }
      fState.cells.add(row);
    }
    fState.furdleSize = _size;
    fState.furdlePuzzle = furdle;
    furdleNotifier = FurdleNotifier(fState);
  }

  /// grid size
  int _size = 5;

  String furdle = 'hello';

  KeyState characterToState(String letter) {
    int index = containsIndex(letter);
    if (index < 0) {
      return KeyState.notExists;
    } else if (letterExists(index, letter)) {
      return KeyState.exists;
    } else {
      return KeyState.misplaced;
    }
  }

  bool letterExists(int index, String letter) {
    return furdle[fState.column] == letter;
  }

  int containsIndex(letter) {
    return furdle.toLowerCase().indexOf(letter);
  }

  bool isLetter(String x) {
    return x.length == 1 && x.codeUnitAt(0) >= 65 && x.codeUnitAt(0) <= 90;
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
                    const Text('Furdle Mode'),
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
                  if (character == 'enter') {
                    if (fState.isFilled()) {
                      bool isSolved = fState.submit();
                      print('puzzle solved=$isSolved');
                    } else {
                      print('word is incomplete ${fState.currentWord()}');
                    }
                  } else if (character == 'delete' ||
                      character == 'backspace') {
                    fState.removeCell();
                  } else if (isLetter(x.toUpperCase())) {
                    fState.addCell(
                      FCellState(
                          character: character,
                          state: characterToState(character)),
                    );
                  } else {
                    print('invalid Key event $character');
                  }
                  furdleNotifier.notify();
                },
              ),
            ),
          ],
        ));
  }
}
