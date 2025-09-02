import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/colors.dart';
import 'package:furdle/provider/keyboard_notifier.dart';

enum KeyEventType {
  keyDown,
  keyUp,
  keyCancel,
}

class FurdleKeyboard extends ConsumerStatefulWidget {
  final Function(String key, KeyEventType event, bool physicalKey)?
      onKeyPressed;
  final bool? autoFocus;
  const FurdleKeyboard({this.onKeyPressed, this.autoFocus = true, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FurdleKeyboardState();
}

class _FurdleKeyboardState extends ConsumerState<FurdleKeyboard> {
  @override
  Widget build(BuildContext context) {
    final keyboardNotifier = ref.read(keyboardProvider.notifier);

    // Listen to the last key event and call the onKeyPressed callback
    ref.listen<KeyState?>(lastKeyEventProvider, (previous, next) {
      if (next != null && widget.onKeyPressed != null) {
        widget.onKeyPressed!.call(
          next.key,
          next.event,
          next.isPhysicalKey,
        );
      }
    });

    return KeyboardListener(
      autofocus: widget.autoFocus!,
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final key = _getKeyLabel(event.logicalKey);
          keyboardNotifier.onKeyPressed(key, KeyEventType.keyDown, true);
        } else if (event is KeyUpEvent) {
          final key = _getKeyLabel(event.logicalKey);
          keyboardNotifier.onKeyPressed(key, KeyEventType.keyUp, true);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _KeyRow(
            characters: ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
          ),
          _KeyRow(
            characters: ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
          ),
          _KeyRow(
            characters: ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
          ),
        ],
      ),
    );
  }

  String _getKeyLabel(LogicalKeyboardKey key) {
    // Handle special keys
    if (key == LogicalKeyboardKey.space) return ' ';
    if (key == LogicalKeyboardKey.backspace) return 'Backspace';
    if (key == LogicalKeyboardKey.enter) return 'Enter';

    // Handle letter keys
    final label = key.keyLabel;
    if (label.length == 1 &&
        label.toUpperCase().codeUnitAt(0) >= 65 &&
        label.toUpperCase().codeUnitAt(0) <= 90) {
      return label.toUpperCase();
    }

    return label;
  }
}

class _KeyRow extends ConsumerWidget {
  final List<String> characters;
  const _KeyRow({required this.characters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: characters.map((character) => _Key(character)).toList(),
    );
  }
}

class _Key extends ConsumerWidget {
  final String character;

  const _Key(this.character);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyState = ref.watch(keyStateProvider(character));
    final keyboardNotifier = ref.read(keyboardProvider.notifier);
    final isPressed = keyState.event == KeyEventType.keyDown;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: InkWell(
        onTapDown: (details) {
          keyboardNotifier.onKeyPressed(character, KeyEventType.keyDown, false);
        },
        onTapUp: (details) {
          keyboardNotifier.onKeyPressed(character, KeyEventType.keyUp, false);
        },
        onTapCancel: () {
          keyboardNotifier.onKeyPressed(
              character, KeyEventType.keyCancel, false);
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getKeyColor(keyState),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isPressed ? Colors.blue : Colors.grey,
              width: isPressed ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            character,
            style: TextStyle(
              color: _getTextColor(keyState),
              fontWeight: isPressed ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Color _getKeyColor(KeyState keyState) {
    if (keyState.event == KeyEventType.keyDown) {
      return Colors.blue.withValues(alpha: 0.3);
    }

    switch (keyState.letterStatus) {
      case LetterStatus.present:
        return AppColors.green;
      case LetterStatus.notPresent:
        return AppColors.black;
      case LetterStatus.wrongPosition:
        return AppColors.yellow;
      case LetterStatus.unknown:
      default:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  Color _getTextColor(KeyState keyState) {
    if (keyState.event == KeyEventType.keyDown) {
      return Colors.blue;
    }

    switch (keyState.letterStatus) {
      case LetterStatus.present:
        return Colors.green.shade700;
      case LetterStatus.notPresent:
        return Colors.red.shade700;
      case LetterStatus.unknown:
      default:
        return Colors.black;
    }
  }
}
