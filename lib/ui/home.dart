import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart' hide KeyEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/old/pages/help.dart';
import 'package:furdle/ui/keyboard.dart';
import 'package:furdle/ui/title_bar.dart';
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
  }

  @override
  void dispose() {
    slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
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
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: SlideTransition(
                  position:
                      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                          .animate(slideController),
                  child: FurdleKeyboard(
                    onKeyPressed: (String character, KeyEventType event,
                        bool physicalKey) {
                      if (event == KeyEventType.keyCancel) {
                        return;
                      }

                      print(
                          "key pressed: $character, event: ${event.name}  physicalKey: $physicalKey");
                    },
                  ),
                ),
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
