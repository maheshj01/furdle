import 'package:confetti/confetti.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furdle/constants/constants.dart';
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

  late LoadingNotifier furdleNotifier;
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

  void showFurdleDialog(
      {String? title,
      String? message,
      bool isSuccess = false,
      bool showTimer = true}) {
    title ??= isSuccess
        ? 'Congratulations! 🎉'
        : '${_state.puzzle.puzzle.toUpperCase()} 😞';
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
                isAlreadyPlayed: _state.isAlreadyPlayed,
                onTimerComplete: () async {
                  _state.isGameOver = false;
                  _state.isAlreadyPlayed = false;
                  Navigate.popView(context);
                  await loadGame();
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
    furdleNotifier = LoadingNotifier(false);
    _initAnimation();
    loadGame();
    analytics.setCurrentScreen(screenName: 'Furdle');
  }

  Future<void> loadGame() async {
    furdleNotifier.isLoading = true;
    _state = GameState.instance();
    await gameController.initialize();
    _state = gameController.gameState;
    _state = await getGame();
    final currentPuzzle = _state.puzzle;
    final DateTime nextPuzzleTime =
        currentPuzzle.date!.add(const Duration(hours: hoursUntilNextFurdle));
    if (currentPuzzle.result == PuzzleResult.none) {
      _state.isGameOver = false;
      _state.isAlreadyPlayed = false;
    } else if (currentPuzzle.result == PuzzleResult.win) {
      _state.isGameOver = true;
      _state.isAlreadyPlayed = true;
      showFurdleDialog(
          title: gameAlreadyPlayed, message: 'Next puzzle in', isSuccess: true);
    } else if (currentPuzzle.result == PuzzleResult.lose) {
      _state.isGameOver = true;
      _state.isAlreadyPlayed = true;
      showFurdleDialog(
          title: gameAlreadyPlayed,
          message: 'Next puzzle in \n$nextPuzzleTime',
          isSuccess: false);
    } else {
      /// Game is in progress
      _state.isAlreadyPlayed = false;
      _state.isGameOver = false;
    }
    gameController.gameState = _state;
    gameController.gameState.updateKeyboard();
    settingsController.stats.number = currentPuzzle.number;
    furdleNotifier.isLoading = false;
  }

  Future<GameState> getGame() async {
    final _localGame = await gameController.loadGame();
    if (_localGame.puzzle.isOffline) {
      Utility.showMessage(context, 'You are playing in offline mode',
          duration: const Duration(milliseconds: 2000));
    }
    // gameController.gameState.cells = challenge.cells;
    return _localGame;
  }

  void updateTimer() async {
    // firestore.DocumentReference<Map<String, dynamic>> _docRef = firestore
    //     .FirebaseFirestore.instance
    //     .collection(collectionProd)
    //     .doc(statsProd);
    // final docSnapshot = await _docRef.get();
    // if (docSnapshot.exists) {
    //   challenge.number = docSnapshot.get('number')
    //   challenge.date = (docSnapshot.get('date') as firestore.Timestamp).toDate();
    //   String word = '';
    //   challenge.puzzle = word;
    final _currentPuzzle = _state.puzzle;
    final DateTime nextFurdleTime =
        _currentPuzzle.date!.add(const Duration(hours: hoursUntilNextFurdle));
    final now = DateTime.now();
    final durationLeft = nextFurdleTime.difference(now);
    if (now.isAfter(nextFurdleTime)) {
      gameController.timeLeft = Duration.zero;
    } else {
      gameController.timeLeft = durationLeft;
    }
    // }
  }

  /// User pressed the keys on virtual or physical keyboard
  Future<void> onKeyEvent(String x, bool isPhysicalKeyEvent) async {
    Puzzle _currentPuzzle = _state.puzzle;
    if (_state.isGameOver ||
        _state.isAlreadyPlayed ||
        _currentPuzzle.result == PuzzleResult.win ||
        _currentPuzzle.result == PuzzleResult.lose) {
      /// User presses keys from physical Keyboard on game over
      if (isPhysicalKeyEvent) return;
      analytics.logEvent(name: 'KeyPressed', parameters: {'key': x});
      final DateTime nextPuzzleTime = _state.puzzle.nextRun!;
      final durationLeft = nextPuzzleTime.difference(DateTime.now());
      gameController.timeLeft = durationLeft;
      _state.isAlreadyPlayed = true;
      showFurdleDialog(
        title: gameAlreadyPlayed,
        message: 'Next puzzle in',
      );
      return;
    }
    final character = x.toLowerCase();
    if (character == kEnterKey) {
      /// check if word is complete
      final wordState = _state.submitWord();
      if (wordState == Word.match) {
        _state.isGameOver = true;
        _currentPuzzle.result = PuzzleResult.win;
        updateTimer();
        confettiController.play();
        _state.isGameOver = true;
        _currentPuzzle.moves = _state.row;
        _currentPuzzle.result = PuzzleResult.win;
        _state.puzzle = _currentPuzzle;
        gameController.onGameOver(_state);
        Future.delayed(const Duration(milliseconds: 500), (() {
          showFurdleDialog(isSuccess: true);
        }));
      } else {
        _state.isGameOver = false;
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
            if (_state.row == _state.puzzle.size.height) {
              updateTimer();
              showFurdleDialog(isSuccess: false);
              _state.isGameOver = true;
              _currentPuzzle.moves = _state.row;
              _currentPuzzle.result = PuzzleResult.lose;
              _state.puzzle = _currentPuzzle;
              gameController.onGameOver(_state);
            } else {
              _currentPuzzle.result = PuzzleResult.inprogress;
              // analytics.logEvent(name: 'word guessed', parameters: {'word': fState.row});
            }
            break;
          default:
        }
      }
    } else if (character == 'delete' || character == 'backspace') {
      _state.removeCell();
    } else if (x.toUpperCase().isLetter()) {
      if (_state.column >= _state.puzzle.size.width) {
        return;
      }
      _state.addCell(character);
    } else {
      print('invalid Key event $character');
    }
    gameController.gameState = _state;

    /// Update the UI with new state
    furdleNotifier.isLoading = false;
  }

  void shakeFurdle() {
    _shakeController.reset();
    _shakeController.forward();
  }

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  ConfettiController confettiController = ConfettiController();
  late GameState _state;

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
                          Navigate.push(
                            context,
                            const HelpPage(),
                            transitionType: TransitionType.scale,
                          );
                        },
                        icon: const Icon(Icons.help)),
                    actions: [
                      IconButton(
                          onPressed: () async {
                            if (_state.isGameOver) {
                              _state.generateFurdleGrid();
                              final furdleScoreShareMessage =
                                  '#FURDLE ${_state.shareFurdle}';
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
                            Navigate.push(context, const SettingsPage());
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
                    ValueListenableBuilder<bool>(
                        valueListenable: furdleNotifier,
                        builder: (x, bool isLoading, z) {
                          if (isLoading) {
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
                                    child: FurdleGrid(
                                      state: _state,
                                      // onGameOver: (Puzzle puzzle) {},
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
