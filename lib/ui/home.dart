import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide KeyEvent;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/state/game_state.dart';
import 'package:furdle/ui/dialog.dart';
import 'package:furdle/ui/grid_board.dart';
import 'package:furdle/ui/help.dart';
import 'package:furdle/ui/keyboard.dart';
import 'package:furdle/ui/settings.dart';
import 'package:furdle/ui/title_bar.dart';
import 'package:furdle/utils/extensions.dart';
import 'package:furdle/utils/utility.dart' show Utility;
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class Home extends ConsumerStatefulWidget {
  static String route = '/';
  final String title;
  const Home({super.key, required this.title});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  final ConfettiController confettiController = ConfettiController();
  late AnimationController slideController;
  late Animation<double> slideAnimation;
  late AnimationController gridScaleController;
  late Animation<double> gridScaleAnimation;

  GameState? _completedGameToShow;
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    slideAnimation = Tween<double>(begin: 0, end: 1).animate(slideController);

    // Grid scale animation with spring effect
    gridScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    gridScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: gridScaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    slideController.forward();
    gridScaleController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final completedGame =
          await ref.read(gameStateProvider.notifier).startGame();
      if (completedGame != null && mounted) {
        setState(() {
          _completedGameToShow = completedGame;
        });
      }
    });
  }

  @override
  void dispose() {
    slideController.dispose();
    gridScaleController.dispose();
    super.dispose();
  }

  void playConfetti() {
    confettiController.play();
  }

  void _handleWordSubmission(GameStateNotifier gameStateNotifier) async {
    try {
      final result = await gameStateNotifier.submitWord();

      // Read the updated game state after submission
      final updatedGameState = ref.read(gameStateProvider);
      if (result == SubmitWordResult.match) {
        _handleGameOver(updatedGameState);
        playConfetti();
      } else if (updatedGameState.status == GameStatus.lose) {
        _handleGameOver(updatedGameState);
      } else {
        final screenSize = MediaQuery.of(context).size;
        Utility.showMessage(
          context,
          result.friendlyString,
          margin:
              EdgeInsets.only(bottom: screenSize.height * 0.6 - kToolbarHeight),
        );
      }
    } catch (e) {
      print("Error submitting word: $e");
      Utility.showMessage(context, "Error submitting word");
    }
  }

  void handleKeyPress(String character, KeyEventType event, bool physicalKey) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final gameState = ref.read(gameStateProvider);
    if (gameState.status == GameStatus.win ||
        gameState.status == GameStatus.lose) {
      _handleGameOver(gameState);
      return;
    }
    if (event == KeyEventType.keyCancel) {
      return;
    } else if (event == KeyEventType.keyUp) {
      switch (character) {
        case Constants.keyboardBackspaceKey:
          gameStateNotifier.deleteLetter();
          break;
        case Constants.keyboardEnterKey:
          print("GameState before submit: ${gameState.status}");
          _handleWordSubmission(gameStateNotifier);
          break;
        default:
          // Check if game is over before allowing letter input
          final currentGameState = ref.read(gameStateProvider);
          if (currentGameState.status == GameStatus.win ||
              currentGameState.status == GameStatus.lose) {
            return;
          }
          if (character.isLetter) {
            gameStateNotifier.addLetter(character);
          }
      }

      // print(
      //     "key pressed: $character, event: ${event.name}  physicalKey: $physicalKey");
    }
  }

  void _handleGameOver(GameState gameState) {
    if (gameState.status == GameStatus.win) {
      // Handle win scenario
      print("🎉 Game Won! Target word was: ${gameState.targetWord}");
      print("🎉 Next game date: ${gameState.nextGameDate}");
      // You can show a win dialog, update UI, etc.
      _showGameOverDialog("Congratulations! You won!", gameState);
    } else if (gameState.status == GameStatus.lose) {
      // Handle lose scenario
      print(" Game Lost! Target word was: ${gameState.targetWord}");
      print("🎉 Next game date: ${gameState.nextGameDate}");
      // You can show a lose dialog, update UI, etc.
      _showGameOverDialog("Game Over! The word was:", gameState);
    }
  }

  void _showGameOverDialog(String title, GameState gameState) {
    final targetWord = gameState.targetWord;
    final nextGameDate = gameState.nextGameDate;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ResponsiveGameOverDialog(
          title: title,
          targetWord: targetWord,
          nextGameDate: nextGameDate,
          onPlayAgain: () {
            Navigator.of(context).pop();
            // Reset dialog state and start a new local game
            setState(() {
              _completedGameToShow = null;
              _hasShownDialog = false;
            });
            ref.read(gameStateProvider.notifier).startGame(playAgain: true);
            confettiController.stop();
          },
          onClose: () {
            Navigator.of(context).pop();
          },
          onTimerComplete: () {
            Navigator.of(context).pop();
            // Reset dialog state and start the next game
            setState(() {
              _completedGameToShow = null;
              _hasShownDialog = false;
            });
            ref.read(gameStateProvider.notifier).startGame(playAgain: false);
            confettiController.stop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show dialog for completed game if needed
    if (_completedGameToShow != null && !_hasShownDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasShownDialog) {
          _hasShownDialog = true;
          _showGameOverDialog(
            _completedGameToShow!.status == GameStatus.win
                ? "Game Already Completed! You won!"
                : "Game Already Completed! You lost!",
            _completedGameToShow!,
          );
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  Expanded(
                    child: ScaleTransition(
                      scale: gridScaleAnimation,
                      child: GridBoard(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 1), end: Offset.zero)
                          .animate(slideController),
                      child: FurdleKeyboard(
                        onKeyPressed: (String character, KeyEventType event,
                            bool physicalKey) {
                          handleKeyPress(character, event, physicalKey);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirection: 0,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.1,
                minimumSize: const Size(10, 10),
                maximumSize: const Size(50, 50),
                numberOfParticles: 5,
                gravity: 0.2,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: TitleBar(
                title: widget.title,
                leading: IconButton(
                    onPressed: () {
                      context.go(HelpPage.path);
                    },
                    icon: const Icon(Icons.help)),
                actions: [
                  IconButton(
                      onPressed: () async {
                        final gameState = ref.read(gameStateProvider);
                        if (gameState.status == GameStatus.inprogress) {
                          Utility.showMessage(context,
                              "You can't share a furdle that hasn't been solved yet!");
                          return;
                        }
                        final result = Utility.generateFurdleGrid(gameState);
                        final furdleScoreShareMessage = 'FURDLE ${result}';

                        if (!kIsWeb) {
                          await SharePlus.instance.share(
                              ShareParams(text: furdleScoreShareMessage));
                        } else {
                          await Clipboard.setData(
                              ClipboardData(text: furdleScoreShareMessage));
                          Utility.showMessage(
                              context, "Score copied to clipboard");
                        }
                      },
                      icon: const Icon(Icons.share)),
                  IconButton(
                      onPressed: () {
                        context.push(SettingsPage.path);
                      },
                      icon: const Icon(Icons.settings)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
