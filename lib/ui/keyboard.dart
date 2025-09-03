import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/colors.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/provider/keyboard_notifier.dart';
import 'package:furdle/utils/extensions.dart';

enum KeyEventType {
  keyDown,
  keyUp,
  keyCancel,
}

class FurdleKeyboard extends ConsumerStatefulWidget {
  final Function(String key, KeyEventType event, bool physicalKey)?
      onKeyPressed;
  final bool? autoFocus;

  /// whether to enable haptic feedback for the key press
  final bool? enableFeedback;
  final double? maxWidth; // Add maxWidth parameter
  const FurdleKeyboard(
      {this.onKeyPressed,
      this.autoFocus = true,
      this.maxWidth,
      this.enableFeedback = true,
      super.key});

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
        if (widget.enableFeedback! && next.event == KeyEventType.keyUp) {
          HapticFeedback.lightImpact();
        }
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
          if (widget.enableFeedback!) {
            HapticFeedback.lightImpact();
          }
          keyboardNotifier.onKeyPressed(key, KeyEventType.keyUp, true);
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth ?? context.maxKeyboardWidth(),
        ),
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
              characters: [
                'Enter',
                'Z',
                'X',
                'C',
                'V',
                'B',
                'N',
                'M',
                'Backspace'
              ],
            ),
          ],
        ),
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
      children: characters.map((character) {
        final isSpecial = character == Constants.keyboardBackspaceKey ||
            character == Constants.keyboardEnterKey;

        // Use Flexible with different flex values for special keys
        return Flexible(
          flex: isSpecial ? 2 : 1, // Special keys get 2x the space
          child: _Key(character),
        );
      }).toList(),
    );
  }
}

class _Key extends ConsumerWidget {
  final String character;
  final double? width;
  final double? height;
  final double? fontSize;
  const _Key(this.character, {this.width, this.height, this.fontSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyState = ref.watch(keyStateProvider(character));
    final keyboardNotifier = ref.read(keyboardProvider.notifier);
    final isPressed = keyState.event == KeyEventType.keyDown;
    final isSpecial = character == Constants.keyboardBackspaceKey ||
        character == Constants.keyboardEnterKey;
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
          width: double.infinity, // Take full width of Flexible parent
          height: height ?? context.sp(32),
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
              fontSize: fontSize ?? context.sp(isSpecial ? 10 : 16),
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
