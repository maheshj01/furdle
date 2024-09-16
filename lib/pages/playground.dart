import 'package:confetti/confetti.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/constants.dart';
import 'package:furdle/models/game_state.dart';
import 'package:furdle/pages/game_view.dart';
import 'package:furdle/pages/help.dart';
import 'package:furdle/pages/keyboard.dart';
import 'package:furdle/pages/settings.dart';
import 'package:furdle/shared/extensions.dart';
import 'package:furdle/shared/providers/game_state_provider.dart';
import 'package:furdle/shared/theme/colors.dart';
import 'package:furdle/utils/utility.dart';
import 'package:furdle/widgets/dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class PlayGround extends ConsumerStatefulWidget {
  const PlayGround({Key? key, this.title = appTitle}) : super(key: key);
  static String path = '/';
  final String title;

  @override
  ConsumerState<PlayGround> createState() => _PlayGroundState();
}

class _PlayGroundState extends ConsumerState<PlayGround>
    with SingleTickerProviderStateMixin {
  final keyboardFocusNode = FocusNode();
  final textController = TextEditingController();

  void toggle() {
    // settingsController.isFurdleMode = !settingsController.isFurdleMode;
    setState(() {});
  }

  late LoadingNotifier loadingNotifier;
  @override
  void dispose() {
    keyboardFocusNode.dispose();
    textController.dispose();
    _shakeController.dispose();
    loadingNotifier.dispose();
    super.dispose();
  }

  void _initShakeAnimation() {
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
                  // loadingNotifier.isLoading = true;
                  // _state = await gameController.getNewGame();
                  // gameController.gameState = _state;
                  // gameController.gameState.initKeyboard();
                  // settingsController.stats.number = _state.puzzle.number;
                  // loadingNotifier.isLoading = false;
                  // Navigate.popView(context);
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
    loadingNotifier = LoadingNotifier(false);
    _initShakeAnimation();
    analytics.logScreenView(screenName: 'Furdle');
    setUp();
  }

  /// New Device? show How to play
  Future<void> setUp() async {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   await Future.delayed(const Duration(milliseconds: 1500));
    //   final deviceId = settingsController.deviceId;
    //   if (deviceId.isEmpty) {
    //     settingsController.registerDevice();
    //     context.push('${HelpPage.path}');
    //   }
    // });
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

  void onKeyEvent(String key, bool isPhysicalKeyEvent) {
    if (key == 'Enter') {
      _state.submitWord();
    } else if (key == 'Backspace') {
      _state.removeCell();
    } else {
      _state.addCell(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    Utility.screenSize = MediaQuery.of(context).size;
    _state = ref.watch(gameStateProvider);
    // settingsController.clear();
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
            top: Utility.screenSize.width > 600 ? 0 : kToolbarHeight / 2,
            // alignment: Alignment.topCenter,
            child: FurdleBar(
              title: appTitle,
              leading: IconButton(
                  onPressed: () {
                    context.push('${HelpPage.path}');
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
                          await Clipboard.setData(
                              ClipboardData(text: furdleScoreShareMessage));
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
                      context.push('${SettingsPage.path}');
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
                  valueListenable: loadingNotifier,
                  builder: (x, bool isLoading, z) {
                    if (isLoading) {
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2.0, color: AppColors.primary),
                      );
                    }
                    return AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (BuildContext context, Widget? child) {
                          return Container(
                              padding: EdgeInsets.only(
                                  left: _shakeAnimation.value + 24.0,
                                  right: 24.0 - _shakeAnimation.value),
                              child: FurdleGrid());
                        });
                  }),
              const SizedBox(
                height: 24,
              ),
              TweenAnimationBuilder<Offset>(
                  tween: Tween<Offset>(
                      begin: const Offset(0, 200), end: const Offset(0, 0)),
                  duration: const Duration(milliseconds: 1000),
                  builder:
                      (BuildContext context, Offset offset, Widget? child) {
                    return Transform.translate(
                      offset: offset,
                      child: AnimatedContainer(
                        margin: EdgeInsets.symmetric(
                            vertical: true //settingsController.isFurdleMode
                                ? 40.0
                                : 10.0),
                        duration: const Duration(milliseconds: 500),
                        child: KeyBoardView(
                          keyboardFocus: keyboardFocusNode,
                          controller: textController,
                          isFurdleMode: true,
                          onKeyEvent: onKeyEvent,
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
