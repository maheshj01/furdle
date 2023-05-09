import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:confetti/confetti.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furdle/constants/constants.dart';
import 'package:furdle/controller/game_controller.dart';
import 'package:furdle/extensions.dart';
import 'package:furdle/main.dart';
import 'package:furdle/models/game_state.dart';
import 'package:furdle/models/puzzle.dart';
import 'package:furdle/pages/game_view.dart';
import 'package:furdle/pages/help.dart';
import 'package:furdle/pages/keyboard.dart';
import 'package:furdle/pages/settings.dart';
import 'package:furdle/utils/navigator.dart';
import 'package:furdle/utils/utility.dart';
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

  GameState gState = GameState(
    puzzle: Puzzle.initialize(),
  );
  late FurdleNotifier furdleNotifier;
  @override
  void dispose() {
    keyboardFocusNode.dispose();
    textController.dispose();
    _shakeController.dispose();
    furdleNotifier.dispose();
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
        : '${gState.puzzle.puzzle.toUpperCase()} 😞';
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
                  gState.isGameOver = false;
                  gameController.isAlreadyPlayed = false;
                  await loadGame();
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
    challenge = Puzzle.initialize();
    gState.puzzle.size = defaultSize;
    gState.puzzle.puzzle = challenge.puzzle;
    challenge.size = defaultSize;
    furdleNotifier = FurdleNotifier(gState);
    _initAnimation();
    loadGame();
    analytics.setCurrentScreen(screenName: 'Furdle');
  }

  Future<Puzzle> getPuzzle() async {
    challenge = await gameController.getPuzzle();
    if (challenge.isOffline) {
      Utility.showMessage(context, 'You are playing in offline mode',
          duration: const Duration(milliseconds: 2000));
    }
    gState.puzzle = challenge;
    return challenge;
  }

  Future<void> loadGame() async {
    await gameController.initialize();
    furdleNotifier.isLoading = true;
    challenge = await getPuzzle();
    final now = DateTime.now();
    final DateTime nextPuzzleTime =
        challenge.date!.add(const Duration(hours: hoursUntilNextFurdle));
    if (challenge.result == PuzzleResult.none) {
      challenge.result = PuzzleResult.inprogress;
    } else {
      /// Game is Inprogress
      final durationLeft = nextPuzzleTime.difference(now);
      if (challenge.result == PuzzleResult.inprogress) {
        gState.row = challenge.moves;
        gState.column = 0;
        gState.puzzle = challenge;
        gState.isPuzzleCracked = false;
      } else {
        /// Game is either won or lost
        gState.isPuzzleCracked = challenge.result == PuzzleResult.win;
        gState.row = challenge.moves;
        gState.column = 0;
        gState.puzzle = challenge;
        furdleNotifier.isLoading = false;
        showFurdleDialog(
            title: gameAlreadyPlayed,
            message: 'Next puzzle in',
            isSuccess: challenge.result == PuzzleResult.win);
        return;
      }
    }
    settingsController.stats.number = challenge.number;
    furdleNotifier.isLoading = false;
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
            challenge.date!.add(const Duration(hours: hoursUntilNextFurdle));
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

  /// User pressed the keys on virtual or physical keyboard
  Future<void> onKeyEvent(String x, bool isPhysicalKeyEvent) async {
    analytics.logEvent(name: 'KeyPressed', parameters: {'key': x});
    if (gState.isGameOver || gameController.isAlreadyPlayed) {
      /// User presses keys from physical Keyboard on game over
      if (isPhysicalKeyEvent) return;
      showFurdleDialog(title: gameAlreadyPlayed, message: 'Next puzzle in');
      return;
    }
    final character = x.toLowerCase();
    if (character == kEnterKey) {
      /// check if word is complete
      final wordState = gState.validate();
      challenge.cells = gState.cells;
      if (wordState == Word.match) {
        gState.isGameOver = true;
        gState.isPuzzleCracked = true;
        updateTimer();
        confettiController.play();
        gState.isGameOver = true;
        challenge.moves = gState.row;
        challenge.result = PuzzleResult.win;
        gameController.onGameOver(challenge);
        Future.delayed(const Duration(milliseconds: 500), (() {
          showFurdleDialog(isSuccess: true);
        }));
      } else {
        gState.isGameOver = false;
        gState.isPuzzleCracked = false;
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
            if (gState.row == gState.puzzle.size.height) {
              updateTimer();
              showFurdleDialog(isSuccess: false);
              gState.isGameOver = true;
              challenge.moves = gState.row;
              challenge.result = PuzzleResult.lose;
              gameController.onGameOver(challenge);
            } else {
              challenge.result = PuzzleResult.inprogress;
              // analytics.logEvent(name: 'word guessed', parameters: {'word': fState.row});
            }
            break;
          default:
        }
      }
    } else if (character == 'delete' || character == 'backspace') {
      gState.removeCell();
    } else if (x.toUpperCase().isLetter()) {
      if (gState.column >= gState.puzzle.size.width) {
        return;
      }
      gState.addCell(character);
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
  ConfettiController confettiController = ConfettiController();
  GameController gameController = GameController();

  /// This is a puzzle which is fetched from the server
  /// and it will always be stored locally at every key press
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
                            if (gState.isGameOver) {
                              gState.generateFurdleGrid();
                              final furdleScoreShareMessage =
                                  '#FURDLE ${gState.shareFurdle}';
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
                            navigate(context, const SettingsPage());
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
                                      gameState: gState,
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
