import 'package:flutter/material.dart';
import 'package:furdle/main.dart';

class FurdleDialog extends StatelessWidget {
  const FurdleDialog(
      {Key? key,
      required this.title,
      required this.message,
      this.onTimerComplete})
      : super(key: key);

  final Function? onTimerComplete;
  final String title;
  final String message;

  // appends 0 to timer if less than 10
  String toTimer(int time) {
    if (time < 10) {
      return '0' + time.toString();
    } else {
      return time.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0.5,
      child: Container(
        width: 350,
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            settingsController.isAlreadyPlayed
                ? TweenAnimationBuilder<Duration>(
                    duration: settingsController.timeLeft,
                    tween: Tween(
                        begin: settingsController.timeLeft, end: Duration.zero),
                    onEnd: () {
                      settingsController.isAlreadyPlayed = false;
                      onTimerComplete!();
                    },
                    builder:
                        (BuildContext context, Duration value, Widget? child) {
                      final minutes = value.inMinutes;
                      final seconds = value.inSeconds % 60;
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: RichText(
                              text: TextSpan(
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              const TextSpan(
                                text: '⏰ ',
                                style: TextStyle(fontSize: 24),
                              ),
                              TextSpan(
                                text: toTimer(minutes),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const TextSpan(text: 'mins '),
                              TextSpan(
                                text: toTimer(seconds),
                                style: const TextStyle(fontSize: 24),
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
  }
}
