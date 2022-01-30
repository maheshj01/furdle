import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/furdle.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/pages/furdle.dart';
import 'package:furdle/pages/keyboard.dart';
import 'package:furdle/pages/settings.dart';
import 'package:furdle/utils/navigator.dart';
import 'package:furdle/utils/settings_controller.dart';
import 'package:furdle/widgets/dialog.dart';

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
    puzzle = Puzzle.initialStats(puzzle: 'hello');
    puzzle.puzzleSize = _size;
    fState.furdlePuzzle = puzzle.puzzle;
    furdleNotifier = FurdleNotifier(fState);
  }

  /// grid size
  int _size = 5;

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
    return puzzle.puzzle[fState.column] == letter;
  }

  int containsIndex(letter) {
    return puzzle.puzzle.toLowerCase().indexOf(letter);
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
                title: isSuccess
                    ? 'Congratulations! 🎉'
                    : '${fState.furdlePuzzle} 😞',
                message: isSuccess
                    ? 'You cracked the Furdle of the Day!'
                    : 'You couldn\'t crack the Furdle of the Day!\nDon\'t let this happen again.\nBetter luck next time!',
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
  bool isGameOver = false;
  late Puzzle puzzle;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          final isDark = settingsController.themeMode == ThemeMode.dark;
          return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
                actions: [
                  IconButton(
                    onPressed: _toggleTheme,
                    tooltip: 'theme',
                    icon: Icon(!isDark ? Icons.dark_mode : Icons.brightness_4),
                  ),
                  IconButton(
                      onPressed: () {
                        navigate(context, const Settings());
                      },
                      icon: const Icon(Icons.speed)),
                ],
              ),
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () {
              //     showFurdleDialog(context);
              //   },
              //   child: const Icon(Icons.add),
              // ),
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -100,
                    left: size.width / 2,
                    child: ConfettiWidget(
                      confettiController: confettiController,
                      blastDirection: 0,
                      blastDirectionality: BlastDirectionality.explosive,
                      particleDrag: 0.05,
                      emissionFrequency: size.width < 400 ? 0.35 : 0.5,
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
                                isDark: settingsController.themeMode ==
                                    ThemeMode.dark,
                                fState: fState,
                                size: _size,
                              );
                            }),
                        const SizedBox(
                          height: 24,
                        ),
                        AnimatedContainer(
                          margin: EdgeInsets.symmetric(
                              vertical: settingsController.isFurdleMode
                                  ? 40.0
                                  : 10.0),
                          duration: const Duration(milliseconds: 500),
                          child: KeyBoardView(
                            keyboardFocus: keyboardFocusNode,
                            controller: textController,
                            isFurdleMode: true,
                            onKeyEvent: (x) {
                              if (isSolved || isGameOver) return;
                              final character = x.toLowerCase();
                              if (character == 'enter') {
                                if (fState.canBeSubmitted()) {
                                  isSolved = fState.submit();
                                  if (isSolved) {
                                    showFurdleDialog(context, isSuccess: true);
                                    confettiController.play();
                                    isGameOver = true;
                                    puzzle.moves = fState.row;
                                    puzzle.result = PuzzleResult.win;
                                    settingsController.gameOver(puzzle);
                                  } else {
                                    if (fState.row == _size) {
                                      showFurdleDialog(context,
                                          isSuccess: false);
                                      isGameOver = true;
                                      puzzle.moves = fState.row;
                                      puzzle.result = PuzzleResult.lose;
                                      settingsController.gameOver(puzzle);
                                    }
                                  }
                                } else {
                                  print(
                                      'word is incomplete ${fState.currentWord()}');
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
        });
  }
}
