import 'package:flutter/material.dart';
import 'package:flutter_template/main.dart';
import 'package:flutter_template/utils/utility.dart';

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
        body: Column(
          children: [KeyBoardView()],
        ));
  }
}

class KeyBoardView extends StatefulWidget {
  const KeyBoardView({Key? key}) : super(key: key);

  @override
  _KeyBoardViewState createState() => _KeyBoardViewState();
}

class _KeyBoardViewState extends State<KeyBoardView> {
  final String letters = 'abcdefghijklmnopqrstuvwxyz';
  @override
  Widget build(BuildContext context) {
    Widget buildKeyRow(String string) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: string.buildKeys(),
      );
    }

    Widget buildSpace() {
      return Padding(
        padding: const EdgeInsets.only(left: 120.0),
        child:
            KeyBuilder(keyLabel: 'Space', onPressed: () {}, isSpaceKey: true),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildKeyRow('qwertyuiop'),
        buildKeyRow('asdfghjkl'),
        buildKeyRow('zxcvbnm'),
        buildSpace()
      ],
    );
  }
}

extension on String {
  List<Widget> buildKeys() => split('')
      .map((e) => KeyBuilder(
            keyLabel: e,
            onPressed: () {},
          ))
      .toList();
}

class KeyBuilder extends StatefulWidget {
  final String keyLabel;
  final VoidCallback onPressed;
  final bool isSpaceKey;

  const KeyBuilder(
      {Key? key,
      required this.keyLabel,
      required this.onPressed,
      this.isSpaceKey = false})
      : super(key: key);

  @override
  State<KeyBuilder> createState() => _KeyBuilderState();
}

class _KeyBuilderState extends State<KeyBuilder> {
  final double _keySize = 60;
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: widget.onPressed,
        child: Container(
          height: _keySize,
          width: widget.isSpaceKey ? _keySize * 5 : _keySize,
          alignment: Alignment.center,
          child: Text(
            widget.keyLabel.toUpperCase(),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
