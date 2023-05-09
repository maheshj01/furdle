import 'package:flutter/material.dart';
import 'package:furdle/constants/colors.dart';
import 'package:furdle/main.dart';

class FurdleDialog extends StatefulWidget {
  const FurdleDialog(
      {Key? key,
      required this.title,
      required this.message,
      required this.showTimer,
      this.isAlreadyPlayed = false,
      this.onTimerComplete})
      : super(key: key);

  final Function? onTimerComplete;
  final String title;
  final String message;
  final bool showTimer;
  final bool isAlreadyPlayed;

  @override
  State<FurdleDialog> createState() => _FurdleDialogState();
}

class _FurdleDialogState extends State<FurdleDialog> {
  // appends 0 to timer if less than 10
  String toTimer(int time) {
    if (time < 10) {
      return '0' + time.toString();
    } else {
      return time.toString();
    }
  }

  bool _isAlreadyPlayed = false;

  @override
  void initState() {
    super.initState();
    _isAlreadyPlayed = widget.isAlreadyPlayed;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: settingsController,
        builder: (context, snapshot) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            elevation: 0.5,
            child: Container(
              height: 250,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _isAlreadyPlayed && widget.showTimer
                      ? TweenAnimationBuilder<Duration>(
                          duration: settingsController.timeLeft,
                          tween: Tween(
                              begin: settingsController.timeLeft,
                              end: Duration.zero),
                          onEnd: () {
                            _isAlreadyPlayed = false;
                            widget.onTimerComplete!();
                          },
                          builder: (BuildContext context, Duration value,
                              Widget? child) {
                            int hours = value.inHours;
                            int minutes = value.inMinutes;
                            final seconds = value.inSeconds % 60;
                            if (minutes > 60) {
                              minutes = (minutes - hours * 60) % 60;
                            }
                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: RichText(
                                    text: TextSpan(
                                  style: const TextStyle(
                                      color: primaryBlue,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: '⏰ ',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    TextSpan(
                                      text: toTimer(hours),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const TextSpan(text: 'hrs '),
                                    TextSpan(
                                      text: toTimer(minutes),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const TextSpan(text: 'mins '),
                                    TextSpan(
                                      text: toTimer(seconds),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const TextSpan(text: 'secs'),
                                  ],
                                )));
                          })
                      : const SizedBox(),
                ],
              ),
            ),
          );
        });
  }
}
