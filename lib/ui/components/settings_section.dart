import 'package:flutter/material.dart';

/// A single settings card, shared by every toggle on the settings page so the
/// screen reads as one system.
///
/// Layout, top to bottom:
///   • a tracked monospace [eyebrow] with a leading [icon] (the "board" label)
///   • the control [title] and its [subtitle]
///   • a [Switch] wired to [value] / [onChanged]
///   • an optional [hint] strip in the game's voice
///
/// [accent] tints the eyebrow icon, the active switch, and the hint strip so
/// each card carries its own meaning while sharing one structure.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.eyebrow,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.accent,
    this.hint,
    this.hintIcon,
  });

  final String eyebrow;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;
  final String? hint;
  final IconData? hintIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 8),
                Text(
                  eyebrow.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 2,
                  ).copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return accent;
                    // Off: a solid thumb that reads against the outlined track.
                    return theme.colorScheme.outline;
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return accent.withValues(alpha: 0.35);
                    }
                    // Off: a light fill so the thumb and border stay legible.
                    return theme.colorScheme.surfaceContainerHighest;
                  }),
                  trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.transparent;
                    }
                    return theme.colorScheme.outline;
                  }),
                ),
              ],
            ),
            if (hint != null) ...[
              const SizedBox(height: 16),
              _HintStrip(text: hint!, icon: hintIcon, accent: accent),
            ],
          ],
        ),
      ),
    );
  }
}

/// A quiet, accent-bordered note beneath a setting — the game explaining what
/// the toggle does, in its own voice.
class _HintStrip extends StatelessWidget {
  const _HintStrip({required this.text, required this.accent, this.icon});

  final String text;
  final Color accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(2),
          right: Radius.circular(8),
        ),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, height: 1.35, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
