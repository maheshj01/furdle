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
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = ref.watch(settingsNotifierProvider).isDarkMode;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ScrollConfiguration(
          // No scrollbar
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                ReportBugWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class ReportBugWidget extends ConsumerWidget {
  const ReportBugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsNotifierProvider).isDarkMode;
    final screenSize = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(20.0),
      width: screenSize.width > 600 ? 600 : screenSize.width,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900.withValues(alpha: 0.5) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report_outlined,
                size: 24,
                color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Report a bug',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Found an issue? Help us improve by reporting it:',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          _ActionButton(
            icon: Icons.email_outlined,
            label: 'Email Support',
            onTap: () {
              Utility.launch(emailSource, isNewTab: true, mode: LaunchMode.platformDefault);
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.code_outlined,
            label: 'GitHub Issues',
            onTap: () {
              Utility.launch(sourceUrl);
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {
              context.push(WebViewPage.routeName);
            },
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor:
            isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
        highlightColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension WebLink on String {
  Widget toLink({Function()? onTap}) {
    return TextButton(
      onPressed: onTap,
      child: Text(this),
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
