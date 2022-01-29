import 'package:confetti/confetti.dart';
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

  void showFurdleDialog(BuildContext context) {
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) => AlertDialog(
    //           title: const Text('Congratulations!'),
    //           content: const Text('You solved the puzzle!'),
    //           actions: <Widget>[
    //             IconButton(
    //                 icon: const Icon(Icons.close),
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                 })
    //           ],
    //         ));

    showGeneralDialog(
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return const SizedBox();
        },
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.4),
        barrierLabel: '',
        transitionBuilder: (context, anim1, anim2, child) {
          return Transform.translate(
            offset: Offset(0.0, anim1.value * 200),
            child: Material(
              child: Container(
                height: 200,
                width: 200,
                alignment: Alignment.center,
                child: SizedBox(
                  height: 200,
                  child: Column(
                    children: const [
                      Text('Congratulations!'),
                      SizedBox(
                        height: 20,
                      ),
                      Text('You solved the puzzle!'),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300));
  }

  ConfettiController confettiController = ConfettiController();
  bool isSolved = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showFurdleDialog(context);
          },
          child: const Icon(Icons.add),
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
            Positioned(
              top: -100,
              left: size.width / 2,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirection: 0,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.5,
                minimumSize: const Size(10, 10),
                maximumSize: const Size(50, 50),
                numberOfParticles: 5,
                gravity: 0.2,
              ),
            ),
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
                  if (isSolved) return;
                  final character = x.toLowerCase();
                  if (character == 'enter') {
                    if (fState.isFilled()) {
                      isSolved = fState.submit();
                      print('puzzle solved=$isSolved');
                      if (isSolved) {
                        showFurdleDialog(context);
                        confettiController.play();
                      }
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
