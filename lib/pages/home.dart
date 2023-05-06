import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:confetti/confetti.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furdle/constants/constants.dart';
import 'package:furdle/extensions.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/furdle.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/pages/furdle.dart';
import 'package:furdle/pages/help.dart';
import 'package:furdle/pages/keyboard.dart';
import 'package:furdle/pages/settings.dart';
import 'package:furdle/utils/navigator.dart';
import 'package:furdle/utils/utility.dart';
import 'package:furdle/utils/word.dart';
import 'package:furdle/widgets/dialog.dart';
import 'package:share_plus/share_plus.dart';

class PlayGround extends StatefulWidget {
  const PlayGround({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PlayGroundState createState() => _PlayGroundState();
}

class _PlayGroundState extends State<PlayGround>
    with SingleTickerProviderStateMixin {
  final keyboardFocusNode = FocusNode();
  final textController = TextEditingController();

  void toggle() {
    settingsController.isFurdleMode = !settingsController.isFurdleMode;
    setState(() {});
  }

  GameState fState = GameState();
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
    return difficulty.toDifficulty();
  }

  void showFurdleDialog(
      {String? title,
      String? message,
      bool isSuccess = false,
      bool showTimer = true}) {
    title ??= isSuccess
        ? 'Congratulations! 🎉'
        : '${fState.puzzle.puzzle.toUpperCase()} 😞';
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
                showTimer: showTimer,
                onTimerComplete: () async {
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

  @override
  void initState() {
    super.initState();
    challenge = Puzzle.initialize(puzzle: '');
    fState.gridSize = defaultSize;
    fState.furdlePuzzle = challenge.puzzle;
    challenge.puzzleSize = defaultSize;
    furdleNotifier = FurdleNotifier(fState);
    _initAnimation();
    getWord();
    analytics.setCurrentScreen(screenName: 'Furdle');
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
        _size = settingsController.difficulty.toGridSize();
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
          isGameOver = false;
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
            isGameOver = true;
            return;
          } else {
            fState.puzzle = challenge;
            isGameOver = false;
            settingsController.isAlreadyPlayed = false;
            settingsController.stats.puzzle = Puzzle.initialize();
          }
        }
      } else {
        final furdleIndex = Random().nextInt(maxWords);
        word = furdleList[furdleIndex];
        Utility.showMessage(context, 'You are playing in offline mode',
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

  Future<void> onKeyEvent(String x, bool isPhysicalKeyEvent) async {
    analytics.logEvent(name: 'KeyPressed', parameters: {'key': x});
    if (isGameOver || settingsController.isAlreadyPlayed) {
      if (isPhysicalKeyEvent) return;
      showFurdleDialog(title: gameAlreadyPlayed, message: 'Next puzzle in');
      return;
    }
    final character = x.toLowerCase();
    if (character == 'enter') {
      /// check if word is complete
      final wordState = fState.validate();
      challenge.cells = fState.cells;
      if (wordState == Word.match) {
        isGameOver = true;
        updateTimer();
        confettiController.play();
        isGameOver = true;
        challenge.moves = fState.row;
        challenge.result = PuzzleResult.win;
        settingsController.gameOver(challenge);
        Future.delayed(const Duration(milliseconds: 500), (() {
          showFurdleDialog(isSuccess: true);
        }));
      } else {
        isGameOver = false;
        switch (wordState) {
          case Word.incomplete:
            shakeFurdle();
            Utility.showMessage(context, 'Word is incomplete!');
            break;
          case Word.invalid:
            shakeFurdle();
            Utility.showMessage(context, 'Word not in list!');
            break;
          case Word.valid:

            /// User failed to crack the furdle
            if (fState.row == _size.height) {
              updateTimer();
              showFurdleDialog(isSuccess: false);
              isGameOver = true;
              challenge.moves = fState.row;
              challenge.result = PuzzleResult.lose;
              settingsController.gameOver(challenge);
            } else {
              challenge.result = PuzzleResult.inprogress;
              // analytics.logEvent(name: 'word guessed', parameters: {'word': fState.row});
            }
            break;
          default:
        }
      }
    } else if (character == 'delete' || character == 'backspace') {
      fState.removeCell();
    } else if (x.toUpperCase().isLetter()) {
      if (fState.column >= _size.width) {
        return;
      }
      fState.addCell(character);
    } else {
      print('invalid Key event $character');
    }
    furdleNotifier.notify();
  }

  void shakeFurdle() {
    _shakeController.reset();
    _shakeController.forward();
  }

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Size _size = defaultSize;
  ConfettiController confettiController = ConfettiController();
  bool isGameOver = false;
  late Puzzle challenge;
  @override
  Widget build(BuildContext context) {
    Utility.screenSize = MediaQuery.of(context).size;
    // settingsController.clear();
    return AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          return Scaffold(
              body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                  top: Utility.screenSize.width > 600 ? 0 : kToolbarHeight / 2,
                  // alignment: Alignment.topCenter,
                  child: FurdleBar(
                    title: 'Furdle',
                    leading: IconButton(
                        onPressed: () {
                          navigate(
                            context,
                            HelpPage(),
                            type: SlideTransitionType.btt,
                          );
                        },
                        icon: const Icon(Icons.help)),
                    actions: [
                      IconButton(
                          onPressed: () async {
                            if (isGameOver) {
                              fState.generateFurdleGrid();
                              final furdleScoreShareMessage =
                                  '#FURDLE ${fState.shareFurdle}';
                              if (!kIsWeb) {
                                await Share.share(furdleScoreShareMessage);
                              } else {
                                await Clipboard.setData(ClipboardData(
                                    text: furdleScoreShareMessage));
                                Utility.showMessage(
                                  context,
                                  copiedToClipBoard,
                                );
                              }
                            } else {
                              Utility.showMessage(context, shareIncomplete);
                            }
                          },
                          icon: const Icon(Icons.share)),
                      IconButton(
                          onPressed: () {
                            navigate(context, const Settings());
                          },
                          icon: const Icon(Icons.settings)),
                    ],
                  )),
              Positioned(
                top: -100,
                left: Utility.screenSize.width / 2,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirection: 0,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.35,
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
                    const SizedBox(
                      height: 50,
                    ),
                    ValueListenableBuilder<GameState>(
                        valueListenable: furdleNotifier,
                        builder: (x, GameState state, z) {
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
                              builder: (BuildContext context, Widget? child) {
                                return Container(
                                    padding: EdgeInsets.only(
                                        left: _shakeAnimation.value + 24.0,
                                        right: 24.0 - _shakeAnimation.value),
                                    child: Furdle(
                                      gameState: fState,
                                      onGameOver: (Puzzle puzzle) {},
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
                                    (String x, bool isPhysicalKeyEvent) =>
                                        onKeyEvent(x, isPhysicalKeyEvent),
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

class FurdleBar extends StatefulWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final String title;
  const FurdleBar(
      {Key? key,
      this.leading,
      this.actions,
      required this.title,
      this.backgroundColor = Colors.transparent})
      : super(key: key);

  @override
  _FurdleBarState createState() => _FurdleBarState();
}

class _FurdleBarState extends State<FurdleBar> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.leading!,
          widget.title.toTitle(),
          Row(children: widget.actions!)
        ],
      ),
    );
  }
}
