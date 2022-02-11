import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:furdle/exports.dart';
import 'package:furdle/utils/utility.dart';

class HelpPage extends StatelessWidget {
  HelpPage({Key? key}) : super(key: key);
  final String title = helpTitle;

  @override
  Widget build(BuildContext context) {
    String description = """
  Your goal is to guess a 5 letter word in N tries.
  N can be 4,5,6 based on the Difficulty level.
   - 4: Hard
   - 6: Medium (default)
   - 7: Easy
  
  Each guess must be a valid five-letter word. Hit the enter button to submit.
 
  After submitting each word, the color of the tiles will change to show how close your guess was to the word.
  """;

    const String case1 = 'The letter E is in the word and in the correct spot';
    const String case2 = 'The letter L is in the word but in the wrong spot.';
    const String case3 = 'The letter Y is not in the word at any spot';

    Widget subTitle(String subTitle,
        {double fontSize = 24, double vPadding = 8}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding),
        child: Text(
          subTitle,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontSize >= 20 ? FontWeight.w500 : FontWeight.normal),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: screenSize.width < 600
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(description,
                    style: const TextStyle(
                      fontSize: 16,
                    )),
              ),
              const Divider(),
              subTitle('Examples'),
              subTitle('Case 1', fontSize: 20),
              "GREAT".toWord(2),
              subTitle(case1, fontSize: 16),
              subTitle('Case 2', fontSize: 20),
              "PLANE".toWord(1, color: yellow),
              subTitle(case2, fontSize: 16),
              subTitle('Case 3', fontSize: 20),
              "DAISY".toWord(4, color: black),
              subTitle(case3, fontSize: 16),
              if (kIsWeb)
                Container(
                    alignment: Alignment.center,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(playStoreUrl);
                      },
                      child: Image.network(
                          'https://github.com/maheshmnj/vocabhub/raw/master/assets/googleplay.png'),
                    )),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}

extension ExampleWord on String {
  Widget toWord(int index, {double boxSize = 40, Color color = green}) {
    return Material(
      color: Colors.transparent,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (int i = 0; i < length; i++)
          Container(
              height: boxSize,
              width: boxSize,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: Text(
                this[i].toUpperCase(),
                style: const TextStyle(
                    height: 1.1,
                    letterSpacing: 2,
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: i == index ? color : grey))
      ]),
    );
  }
}
