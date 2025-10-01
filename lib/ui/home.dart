import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide KeyEvent;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/provider/hive_storage_provider.dart';
import 'package:furdle/state/game_state.dart';
import 'package:furdle/ui/components/index.dart';
import 'package:furdle/ui/dialog.dart';
import 'package:furdle/ui/grid_board.dart';
import 'package:furdle/ui/help.dart';
import 'package:furdle/ui/keyboard.dart';
import 'package:furdle/ui/settings.dart';
import 'package:furdle/ui/title_bar.dart';
import 'package:furdle/utils/extensions.dart';
import 'package:furdle/utils/utility.dart';
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
      // Check if this is the first launch and navigate to help page
      final storageService = ref.read(hiveStorageServiceProvider);
      final isFirstLaunch = await storageService.isFirstLaunch();

      final completedGame = await ref.read(gameStateProvider.notifier).startGame();
      if (completedGame != null && mounted) {
        setState(() {
          _completedGameToShow = completedGame;
        });
      }
      if (isFirstLaunch && mounted) {
        // Mark as launched to prevent showing help page again
        await storageService.markAsLaunched();
        // Navigate to help page
        Future.delayed(const Duration(seconds: 1), () {
          context.go(HelpPage.path);
        });
      }
    });
    _initShakeAnimation();
  }

  @override
  void dispose() {
    slideController.dispose();
    gridScaleController.dispose();
    _shakeController.dispose();
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
        if (result == SubmitWordResult.incomplete || result == SubmitWordResult.invalid) {
          SettingsSnackBar.showError(
            context,
            message: result.friendlyString,
          );
          shakeFurdle();
        }
      }
    } catch (e) {
      SettingsSnackBar.showError(context, message: "Error submitting word");
    }
  }

  void handleKeyPress(String character, KeyEventType event, bool physicalKey) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final gameState = ref.read(gameStateProvider);
    if (gameState.status == GameStatus.win || gameState.status == GameStatus.lose) {
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
      // You can show a win dialog, update UI, etc.
      _showGameOverDialog("Congratulations! You won!", gameState);
    } else if (gameState.status == GameStatus.lose) {
      // Handle lose scenario
      // You can show a lose dialog, update UI, etc.
      _showGameOverDialog("Game Over!", gameState);
    }
  }

  void _initShakeAnimation() {
    _shakeController =
        AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _shakeAnimation = Tween(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  void shakeFurdle() {
    HapticFeedback.heavyImpact();
    _shakeController.reset();
    _shakeController.forward();
  }

  void restartGame() {
    Navigator.of(context).pop();
    // Reset dialog state and start a new local game
    setState(() {
      _completedGameToShow = null;
      _hasShownDialog = false;
    });
    ref.read(gameStateProvider.notifier).startGame(playAgain: true);
    confettiController.stop();
  }

  void _showGameOverDialog(String title, GameState gameState) {
    final targetWord = gameState.targetWord;
    final nextGameDate = gameState.nextGameDate;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ResponsiveGameOverDialog(
          title: title,
          targetWord: targetWord,
          nextGameDate: nextGameDate,
          onPlayAgain: restartGame,
          onClose: () {
            Navigator.of(context).pop();
          },
          onShare: () async {
            if (!gameState.isGameOver) {
              SettingsSnackBar.showError(context, message: Constants.shareIncomplete);
              return;
            }
            final result = Utility.generateFurdleGrid(gameState);
            final furdleScoreShareMessage = 'FURDLE $result';
            if (!kIsWeb) {
              await SharePlus.instance.share(ShareParams(text: furdleScoreShareMessage));
            } else {
              await Clipboard.setData(ClipboardData(text: furdleScoreShareMessage));
              SettingsSnackBar.showInfo(context, message: Constants.scoreCopiedToClipboard);
            }
          },
          onTimerComplete: restartGame,
        );
      },
    );
  }

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
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
    final gameState = ref.watch(gameStateProvider);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Expanded(
                      child: AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (BuildContext context, Widget? child) {
                            final bool isAnimating = _shakeController.isAnimating;
                            final padding = isAnimating ? 24 : 0;
                            return Container(
                                padding: EdgeInsets.only(
                                    left: _shakeAnimation.value + padding,
                                    right: padding - _shakeAnimation.value),
                                child: ScaleTransition(
                                  scale: gridScaleAnimation,
                                  child: GridBoard(),
                                ));
                          })),
                  Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                          .animate(slideController),
                      child: FurdleKeyboard(
                        onKeyPressed: (String character, KeyEventType event, bool physicalKey) {
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
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TitleBar(
                  title: widget.title,
                  leading: IconButton(
                      onPressed: () {
                        context.go(HelpPage.path);
                      },
                      icon: const Icon(Icons.help)),
                  actions: [
                    IconButton(
                        onPressed: () {
                          context.push(SettingsPage.path);
                        },
                        icon: const Icon(Icons.settings)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
