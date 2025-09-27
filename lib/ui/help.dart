import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/exports.dart' hide AppColors;
import 'package:furdle/provider/game_state_notifier.dart';
import 'package:furdle/provider/settings_notifier.dart';
import 'package:furdle/state/key_state.dart';
import 'package:furdle/ui/webview.dart';
import 'package:furdle/utils/utility.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends ConsumerWidget {
  const HelpPage({Key? key}) : super(key: key);
  static String title = helpTitle;
  static String path = '/how-to-play';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget subTitle(String subTitle, {double fontSize = 24, double vPadding = 8}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: vPadding),
        child: Text(
          subTitle,
          style: TextStyle(
              fontSize: fontSize, fontWeight: fontSize >= 20 ? FontWeight.w500 : FontWeight.normal),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = ref.watch(settingsNotifierProvider).isDarkMode;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(title), actions: [
        IconButton(
            onPressed: () {
              context.pop(true);
            },
            icon: const Icon(Icons.close))
      ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                screenSize.width < 600 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(Constants.description,
                    style: const TextStyle(
                      fontSize: 16,
                    )),
              ),
              const Divider(),
              subTitle('Examples'),
              subTitle('Case 1 (Green)', fontSize: 20),
              "GREAT".toWord(2, isDarkMode, KeyState(key: 'G', cellType: CellType.match)),
              subTitle(Constants.case1, fontSize: 16),
              subTitle('Case 2 (Orange)', fontSize: 20),
              "PLANE".toWord(1, isDarkMode, KeyState(key: 'L', cellType: CellType.misplaced)),
              subTitle(Constants.case2, fontSize: 16),
              subTitle('Case 3 (Black)', fontSize: 20),
              "DAISY".toWord(4, isDarkMode, KeyState(key: 'Y', cellType: CellType.notExists)),
              subTitle(Constants.case3, fontSize: 16),
              if (kIsWeb)
                Container(
                    alignment: Alignment.center,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        Utility.launch(playStoreUrl);
                      },
                      child: Image.asset('assets/googleplay.png'),
                    )),
              subTitle('Report a bug', fontSize: 16),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    children: [
                      'Email'.toLink(onTap: () {
                        Utility.launch(emailSource,
                            isNewTab: true, mode: LaunchMode.platformDefault);
                      }),
                      const SizedBox(
                        height: 10,
                      ),
                      'Github'.toLink(onTap: () {
                        Utility.launch(
                          sourceUrl,
                        );
                      })
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(bottom: 50.0),
                  child: 'Privacy Policy'.toLink(
                    onTap: () {
                      context.push(WebViewPage.routeName);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

extension WebLink on String {
  Widget toLink({Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        this,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
          // decorationStyle: TextDecorationStyle.solid
        ),
      ),
    );
  }
}

extension ExampleWord on String {
  Widget toWord(int index, bool isDarkMode, KeyState keyState, {double boxSize = 40}) {
    return Material(
      color: Colors.transparent,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (int i = 0; i < length; i++)
          Container(
            height: boxSize,
            width: boxSize,
            alignment: Alignment.center,
            decoration: buttonDecoration(
              true,
              false,
              i == index
                  ? colorFromKeyState(keyState, isDarkMode)
                  : isDarkMode
                      ? Color.fromARGB(255, 46, 46, 46)
                      : Colors.grey.withValues(alpha: 0.15),
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Text(
              this[i].toUpperCase(),
              style: TextStyle(
                  height: 1.1,
                  letterSpacing: 2,
                  fontSize: 24,
                  color: i == index
                      ? textColorFromKeyState(keyState, isDarkMode)
                      : isDarkMode
                          ? Colors.white
                          : Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          )
      ]),
    );
  }
}
