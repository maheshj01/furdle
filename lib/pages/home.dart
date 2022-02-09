import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furdle/constants/constants.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/furdle.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/pages/furdle.dart';
import 'package:furdle/pages/keyboard.dart';
import 'package:furdle/pages/settings.dart';
import 'package:furdle/utils/navigator.dart';
import 'package:furdle/utils/word.dart';
import 'package:furdle/widgets/dialog.dart';
import 'package:share_plus/share_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
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
    _shakeController.dispose();
    super.dispose();
  }

  void _initAnimation() {
    _shakeController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _shakeAnimation = Tween(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  int difficultyToGridSize(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 4;
      case Difficulty.medium:
        return 5;
      case Difficulty.hard:
        return 6;
    }
  }

  bool isLetter(String x) {
    return x.length == 1 && x.codeUnitAt(0) >= 65 && x.codeUnitAt(0) <= 90;
  }

  void showFurdleDialog(
      {String? title, String? message, bool isSuccess = false}) {
    title ??= isSuccess ? 'Congratulations! 🎉' : '${fState.furdlePuzzle} 😞';
    message ??= isSuccess ? furdleCracked : failedToCrackFurdle;
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.translate(
              offset: Offset(0, 50 * a1.value),
              // scale: a1.value,
              child: FurdleDialog(
                title: title!,
                message: message!,
                onTimerComplete: () async {
                  isSolved = false;
                  isGameOver = false;
                  settingsController.isAlreadyPlayed = false;
                  await getWord();
                  popView(context);
                },
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

  SnackBar _snackBar({required String message, required Duration duration}) {
    final double margin = screenSize.width / 3;
    return SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: EdgeInsets.only(
          bottom: screenSize.height * 0.9 - kToolbarHeight,
          right: screenSize.width < 500 ? 20 : margin,
          left: screenSize.width < 500 ? 20 : margin),
    );
  }

  void showMessage(context, message,
      {bool isError = true,
      Duration? duration = const Duration(milliseconds: 1500)}) {
    if (isError) {
      _shakeController.reset();
      _shakeController.forward();
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(_snackBar(message: '$message', duration: duration!));
  }

  @override
  void initState() {
    super.initState();
    challenge = Puzzle.initialize(puzzle: '');
    fState.furdleSize = _size;
    fState.furdlePuzzle = challenge.puzzle;
    challenge.puzzleSize = _size;
    furdleNotifier = FurdleNotifier(fState);
    _initAnimation();
    getWord();
  }

  // TODO: Get the furdle grid Size
  Size difficultyToSize(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const Size(5.0, 7.0);
      case Difficulty.medium:
        return const Size(5.0, 6.0);
      case Difficulty.hard:
        return const Size(5.0, 5.0);
    }
  }

  Future<void> getWord() async {
    furdleNotifier.isLoading = true;
    firestore.DocumentReference<Map<String, dynamic>> _docRef =
        firestore.FirebaseFirestore.instance.collection('furdle').doc('stats');
    _docRef.get().then((firestore.DocumentSnapshot snapshot) {
      String word = '';
      if (snapshot.exists) {
        word = snapshot['word'];
        challenge.number = snapshot['number'];
        challenge.date = (snapshot['date'] as firestore.Timestamp).toDate();
        challenge.puzzle = word;
        _size = difficultyToSize(settingsController.difficulty);
        challenge.puzzleSize = _size;

        final DateTime nextFurdleTime =
            challenge.date.add(const Duration(hours: hoursUntilNextFurdle));
        final now = DateTime.now();
        final durationLeft = nextFurdleTime.difference(now);
        Puzzle _lastPlayedPuzzle = lastPuzzle();

        if (now.isAfter(nextFurdleTime) ||
            _lastPlayedPuzzle.number < challenge.number) {
          settingsController.timeLeft = Duration.zero;
        } else {
          settingsController.timeLeft = durationLeft;
        }
        settingsController.stats.number = challenge.number;

        bool isGameInProgress =
            _lastPlayedPuzzle.result == PuzzleResult.inprogress &&
                _lastPlayedPuzzle.moves > 0;
        if (isGameInProgress) {
          fState.row = _lastPlayedPuzzle.moves;
          fState.column = 0;
          fState.puzzle = _lastPlayedPuzzle;
        } else {
          bool isPuzzleAlreadyPlayed =
              _lastPlayedPuzzle.number == challenge.number &&
                  _lastPlayedPuzzle.puzzle == challenge.puzzle;
          if (isPuzzleAlreadyPlayed) {
            fState.row = _lastPlayedPuzzle.moves;
            fState.column = 0;
            fState.puzzle = _lastPlayedPuzzle;
            furdleNotifier.isLoading = false;
            showFurdleDialog(
              title: gameAlreadyPlayed,
              message: 'Next puzzle in',
            );
            settingsController.isAlreadyPlayed = true;
            isSolved = true;
            isGameOver = true;
            return;
          } else {
            fState.puzzle = challenge;
            isSolved = false;
            isGameOver = false;
            settingsController.isAlreadyPlayed = false;
            settingsController.stats.puzzle = Puzzle.initialize();
          }
        }
      } else {
        final furdleIndex = Random().nextInt(maxWords);
        word = furdleList[furdleIndex];
        showMessage(context, 'You are playing in offline mode',
            duration: const Duration(milliseconds: 2000));
      }
      fState.furdlePuzzle = challenge.puzzle;
      furdleNotifier.isLoading = false;
    });
  }

  /// Get the last played puzzle
  /// returns the inprogress game if it was left inComplete
  Puzzle lastPuzzle() {
    final lastPlayedPuzzle = settingsController.stats.puzzle;
    // if (lastPlayedPuzzle.moves > 0 &&
    //     lastPlayedPuzzle.result == PuzzleResult.inprogress) {
    // }
    return lastPlayedPuzzle;
  }

  void updateTimer() {
    firestore.DocumentReference<Map<String, dynamic>> _docRef =
        firestore.FirebaseFirestore.instance.collection('furdle').doc('stats');
    _docRef.get().then((firestore.DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        challenge.number = snapshot['number'];
        challenge.date = (snapshot['date'] as firestore.Timestamp).toDate();
        String word = '';
        challenge.puzzle = word;
        final DateTime nextFurdleTime =
            challenge.date.add(const Duration(hours: hoursUntilNextFurdle));
        final now = DateTime.now();
        final durationLeft = nextFurdleTime.difference(now);
        if (now.isAfter(nextFurdleTime)) {
          settingsController.timeLeft = Duration.zero;
        } else {
          settingsController.timeLeft = durationLeft;
        }
      }
    });
  }

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  /// grid size
  Size _size = defaultSize;
  ConfettiController confettiController = ConfettiController();
  bool isSolved = false;
  bool isGameOver = false;
  late Puzzle challenge;
  late Size screenSize;
  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    // settingsController.clear();
    return AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  widget.title,
                  style: const TextStyle(letterSpacing: 2),
                ),
                actions: [
                  IconButton(
                      onPressed: () async {
                        if (isSolved || isGameOver) {
                          fState.generateFurdleGrid();
                          final furdleScoreShareMessage =
                              'FURDLE ${fState.shareFurdle}';
                          if (!kIsWeb) {
                            await Share.share(furdleScoreShareMessage);
                          } else {
                            await Clipboard.setData(
                                ClipboardData(text: furdleScoreShareMessage));
                            showMessage(context, copiedToClipBoard,
                                isError: false);
                          }
                        } else {
                          showMessage(context, shareIncomplete);
                        }
                      },
                      icon: const Icon(Icons.share)),
                  IconButton(
                      onPressed: () {
                        navigate(context, const Settings());
                      },
                      icon: const Icon(Icons.settings)),
                ],
              ),
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -100,
                    left: screenSize.width / 2,
                    child: ConfettiWidget(
                      confettiController: confettiController,
                      blastDirection: 0,
                      blastDirectionality: BlastDirectionality.explosive,
                      particleDrag: 0.05,
                      emissionFrequency: screenSize.width < 400 ? 0.35 : 0.4,
                      minimumSize: const Size(10, 10),
                      maximumSize: const Size(50, 50),
                      numberOfParticles: 5,
                      gravity: 0.2,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder<FState>(
                            valueListenable: furdleNotifier,
                            builder: (x, FState state, z) {
                              if (furdleNotifier.isLoading) {
                                return Container(
                                  height: 200,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2.0, color: primaryBlue),
                                );
                              }
                              return AnimatedBuilder(
                                  animation: _shakeAnimation,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Container(
                                        padding: EdgeInsets.only(
                                            left: _shakeAnimation.value + 24.0,
                                            right:
                                                24.0 - _shakeAnimation.value),
                                        child: Furdle(
                                          fState: fState,
                                          size: _size,
                                        ));
                                  });
                            }),
                        const SizedBox(
                          height: 24,
                        ),
                        TweenAnimationBuilder<Offset>(
                            tween: Tween<Offset>(
                                begin: const Offset(0, 200),
                                end: const Offset(0, 0)),
                            duration: const Duration(milliseconds: 1000),
                            builder: (BuildContext context, Offset offset,
                                Widget? child) {
                              return Transform.translate(
                                offset: offset,
                                child: AnimatedContainer(
                                  margin: EdgeInsets.symmetric(
                                      vertical: settingsController.isFurdleMode
                                          ? 40.0
                                          : 10.0),
                                  duration: const Duration(milliseconds: 500),
                                  child: KeyBoardView(
                                    keyboardFocus: keyboardFocusNode,
                                    controller: textController,
                                    isFurdleMode: true,
                                    onKeyEvent:
                                        (String x, bool isPhysicalKeyEvent) {
                                      if (isSolved ||
                                          isGameOver ||
                                          settingsController.isAlreadyPlayed) {
                                        if (isPhysicalKeyEvent) return;
                                        updateTimer();
                                        showFurdleDialog(
                                            title: gameAlreadyPlayed,
                                            message: 'Next puzzle in');
                                        return;
                                      }
                                      final character = x.toLowerCase();
                                      if (character == 'enter') {
                                        /// check if word is complete
                                        /// TODO: check if word is valid 5 letter word
                                        final wordState = fState.validate();
                                        challenge.cells = fState.cells;
                                        if (wordState == Word.match) {
                                          isSolved = true;
                                          showFurdleDialog(isSuccess: true);
                                          confettiController.play();
                                          isGameOver = true;
                                          challenge.moves = fState.row;
                                          challenge.result = PuzzleResult.win;
                                          settingsController
                                              .gameOver(challenge);
                                        } else {
                                          isSolved = false;
                                          switch (wordState) {
                                            case Word.incomplete:
                                              showMessage(context,
                                                  'Word is incomplete!');
                                              break;
                                            case Word.invalid:
                                              showMessage(
                                                  context, 'Word not in list!');
                                              break;
                                            case Word.valid:

                                              /// User failed to crack the furdle
                                              if (fState.row == _size.height) {
                                                showFurdleDialog(
                                                    isSuccess: false);
                                                isGameOver = true;
                                                challenge.moves = fState.row;
                                                challenge.result =
                                                    PuzzleResult.lose;
                                                settingsController
                                                    .gameOver(challenge);
                                              } else {
                                                challenge.result =
                                                    PuzzleResult.inprogress;
                                              }
                                              break;
                                            default:
                                          }
                                        }
                                      } else if (character == 'delete' ||
                                          character == 'backspace') {
                                        fState.removeCell();
                                      } else if (isLetter(x.toUpperCase())) {
                                        if (fState.column >= _size.width) {
                                          return;
                                        }
                                        fState.addCell(character);
                                      } else {
                                        print('invalid Key event $character');
                                      }
                                      furdleNotifier.notify();
                                    },
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                    // duration: Duration(milliseconds: 500)
                  )
                ],
              ));
        });
  }
}
