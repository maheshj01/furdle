import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/pages/furdle.dart';
import 'package:flutter_template/pages/keyboard.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _toggleTheme() {
    if (settingsController.themeMode == ThemeMode.dark) {
      settingsController.updateThemeMode(ThemeMode.light);
    } else {
      settingsController.updateThemeMode(ThemeMode.dark);
    }
  }

  final keyboardFocusNode = FocusNode();
  final textController = TextEditingController();

  void toggle() {
    settingsController.isFurdleMode = !settingsController.isFurdleMode;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              tooltip: 'theme',
              icon: const Icon(Icons.dark_mode),
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
                top: 20,
                left: 20,
                child: Row(
                  children: [
                    const Text('Furdle'),
                    Switch(
                      value: settingsController.isFurdleMode,
                      onChanged: (x) => toggle(),
                    ),
                  ],
                )),
            Furdle(
              isDark: settingsController.themeMode == ThemeMode.dark,
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              bottom: settingsController.isFurdleMode ? 40.0 : 10.0,
              left: 0,
              right: 0,
              child: KeyBoardView(
                keyboardFocus: keyboardFocusNode,
                controller: textController,
                isFurdleMode: settingsController.isFurdleMode,
                onKeyEvent: (x) {
                  print(x);
                },
              ),
            ),
          ],
        ));
  }
}
