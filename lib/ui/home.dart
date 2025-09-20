import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart' hide KeyEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/old/pages/help.dart';
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/ui/grid_board.dart';
import 'package:furdle/ui/keyboard.dart';
import 'package:furdle/ui/title_bar.dart';
import 'package:furdle/utils/extensions.dart';
import 'package:furdle/utils/utility.dart' show Utility;
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    slideAnimation = Tween<double>(begin: 0, end: 1).animate(slideController);
    slideController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameStateProvider.notifier).startGame();
    });
  }

  @override
  void dispose() {
    slideController.dispose();
    super.dispose();
  }

  void playConfetti() {
    confettiController.play();
  }

  void handleKeyPress(String character, KeyEventType event, bool physicalKey) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final gameState = ref.read(gameStateProvider);
    if (gameState.status == GameStatus.win ||
        gameState.status == GameStatus.lose) {
      print("game over");
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
          final result = gameStateNotifier.submitWord();

          // Read the updated game state after submission
          final updatedGameState = ref.read(gameStateProvider);

          if (result == SubmitWordResult.match) {
            playConfetti();
            _handleGameOver(updatedGameState);
          } else if (updatedGameState.status == GameStatus.lose) {
            _handleGameOver(updatedGameState);
          } else {
            final screenSize = MediaQuery.of(context).size;
            Utility.showMessage(
              context,
              result.friendlyString,
              margin: EdgeInsets.only(
                  bottom: screenSize.height * 0.6 - kToolbarHeight),
            );
          }
          print("result: ${result.friendlyString}");
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
      // You can show a win dialog, update UI, etc.
      _showGameOverDialog("Congratulations! You won!", gameState.targetWord);
    } else if (gameState.status == GameStatus.lose) {
      // Handle lose scenario
      print(" Game Lost! Target word was: ${gameState.targetWord}");
      // You can show a lose dialog, update UI, etc.
      _showGameOverDialog("Game Over! The word was:", gameState.targetWord);
    }
  }

  void _showGameOverDialog(String title, String targetWord) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text("The word was: $targetWord"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally restart the game
                ref.read(gameStateProvider.notifier).startGame();
              },
              child: Text("Play Again"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  Expanded(child: GridBoard()),
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
                      onPressed: () async {}, icon: const Icon(Icons.share)),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.settings)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
