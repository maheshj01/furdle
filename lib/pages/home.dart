import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/models/furdle.dart';
import 'package:flutter_template/pages/furdle.dart';
import 'package:flutter_template/pages/keyboard.dart';
import 'package:flutter_template/widgets/dialog.dart';

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
  void dispose() {
    keyboardFocusNode.dispose();
    textController.dispose();
    super.dispose();
  }

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

  void showFurdleDialog(BuildContext context, {bool isSuccess = false}) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.translate(
              offset: Offset(0, 50 * a1.value),
              // scale: a1.value,
              child: FurdleDialog(
                title: isSuccess ? 'Congratulations! 🎉' : 'Furdle 😞',
                message: isSuccess
                    ? 'You cracked the Furdle of the Day!'
                    : 'You couldn\'t crack the Furdle of the Day!\nDon\'t let this happen again, Better luck next time!',
              ));
        },
        transitionDuration: const Duration(milliseconds: 300),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
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
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  ValueListenableBuilder<FState>(
                      valueListenable: furdleNotifier,
                      builder: (x, y, z) {
                        return Furdle(
                          isDark:
                              settingsController.themeMode == ThemeMode.dark,
                          fState: fState,
                          size: _size,
                        );
                      }),
                  AnimatedContainer(
                    margin: EdgeInsets.symmetric(
                        vertical:
                            settingsController.isFurdleMode ? 40.0 : 10.0),
                    duration: const Duration(milliseconds: 500),
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
                              showFurdleDialog(context, isSuccess: true);
                              confettiController.play();
                            }
                          } else if (fState.row == size) {
                            showFurdleDialog(context, isSuccess: false);
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
              ),
              // duration: Duration(milliseconds: 500)
            )
          ],
        ));
  }
}
