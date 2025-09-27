import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/constants/styles.dart';
import 'package:furdle/provider/keyboard_notifier.dart';
import 'package:furdle/provider/settings_notifier.dart';
import 'package:furdle/state/key_state.dart';
import 'package:furdle/utils/extensions.dart';

enum KeyEventType {
  keyDown,
  keyUp,
  keyCancel,
}

class FurdleKeyboard extends ConsumerStatefulWidget {
  final Function(String key, KeyEventType event, bool physicalKey)? onKeyPressed;
  final bool? autoFocus;
  final FocusNode? focusNode;

  /// whether to enable haptic feedback for the key press
  final bool? enableFeedback;
  final double? maxWidth; // Add maxWidth parameter
  const FurdleKeyboard(
      {this.onKeyPressed,
      this.autoFocus = true,
      this.focusNode,
      this.maxWidth,
      this.enableFeedback = true,
      super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FurdleKeyboardState();
}

class _FurdleKeyboardState extends ConsumerState<FurdleKeyboard> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    final keyboardNotifier = ref.read(keyboardProvider.notifier);

    // Listen to the last key event and call the onKeyPressed callback
    ref.listen<KeyState?>(lastKeyEventProvider, (previous, next) {
      if (next != null && widget.onKeyPressed != null) {
        // Only trigger callback for actual user interactions (keyUp events from real key presses)
        // Skip if it's not a keyUp event or if there's no previous state (initial load)
        if (next.event != KeyEventType.keyUp || previous == null) {
          return;
        }

        if (widget.enableFeedback!) {
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
      focusNode: _focusNode,
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
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.width < 400 ? 8.0 : 12.0,
            vertical: 8.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              KeyBoardRow(
                characters: ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
              ),
              SizedBox(height: context.width < 400 ? 4.0 : 6.0),
              KeyBoardRow(
                characters: ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
              ),
              SizedBox(height: context.width < 400 ? 4.0 : 6.0),
              KeyBoardRow(
                characters: ['Enter', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Backspace'],
              ),
            ],
          ),
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

class KeyBoardRow extends ConsumerWidget {
  final List<String> characters;
  const KeyBoardRow({required this.characters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: characters.map((character) {
        final isSpecial =
            character == Constants.keyboardBackspaceKey || character == Constants.keyboardEnterKey;

        // Use Expanded with different flex values for special keys
        // This ensures better distribution of space
        return Expanded(
          flex: isSpecial ? 15 : 10, // Special keys get 1.5x the space
          child: KeyBoardKey(character),
        );
      }).toList(),
    );
  }
}

class KeyBoardKey extends ConsumerWidget {
  final String character;
  const KeyBoardKey(this.character);

  Widget backspaceButtonChild(BuildContext context) {
    return Icon(Icons.backspace, size: context.sp(24));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyState = ref.watch(keyStateProvider(character));
    final settingsState = ref.watch(settingsNotifierProvider);
    final isDarkMode = settingsState.isDarkMode;
    final keyboardNotifier = ref.read(keyboardProvider.notifier);
    final isPressed = keyState.event == KeyEventType.keyDown;
    final isSpecial =
        character == Constants.keyboardBackspaceKey || character == Constants.keyboardEnterKey;

    // Calculate responsive touch target size
    final screenWidth = context.width;
    final minTouchTarget = 48.0; // Minimum accessibility requirement
    final responsiveHeight = context.sp(48).clamp(minTouchTarget, 60.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 400 ? 1.5 : 2.5,
        vertical: 2.0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (details) {
            keyboardNotifier.onKeyPressed(character, KeyEventType.keyDown, false);
          },
          onTapUp: (details) {
            keyboardNotifier.onKeyPressed(character, KeyEventType.keyUp, false);
          },
          onTapCancel: () {
            keyboardNotifier.onKeyPressed(character, KeyEventType.keyCancel, false);
          },
          borderRadius: BorderRadius.circular(8),
          splashColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          highlightColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          child: Container(
            width: double.infinity, // Take full width of Flexible parent
            height: responsiveHeight,
            decoration:
                buttonDecoration(isDarkMode, isPressed, colorFromKeyState(keyState, isDarkMode)),
            alignment: Alignment.center,
            child: isSpecial && character == Constants.keyboardBackspaceKey
                ? backspaceButtonChild(context)
                : Text(
                    character,
                    style: TextStyle(
                      fontSize: context.sp(isSpecial ? 12 : 18),
                      color: textColorFromKeyState(keyState, isDarkMode),
                      fontWeight: isPressed ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
