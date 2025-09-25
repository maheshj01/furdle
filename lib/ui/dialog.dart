import 'dart:async';

import 'package:flutter/material.dart';

class ResponsiveGameOverDialog extends StatefulWidget {
  final String title;
  final String targetWord;
  final DateTime? nextGameDate;
  final VoidCallback onPlayAgain;
  final VoidCallback onClose;
  final VoidCallback onTimerComplete;

  const ResponsiveGameOverDialog({
    super.key,
    required this.title,
    required this.targetWord,
    required this.nextGameDate,
    required this.onPlayAgain,
    required this.onClose,
    required this.onTimerComplete,
  });

  @override
  State<ResponsiveGameOverDialog> createState() => _ResponsiveGameOverDialogState();
}

class _ResponsiveGameOverDialogState extends State<ResponsiveGameOverDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  Duration? _timeRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Scale animation for dialog entrance
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _scaleController.forward();
    _initializeTimer();
  }

  void _initializeTimer() {
    if (widget.nextGameDate != null) {
      final now = DateTime.now();
      if (widget.nextGameDate!.isAfter(now)) {
        _timeRemaining = widget.nextGameDate!.difference(now);
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining != null) {
        setState(() {
          _timeRemaining = _timeRemaining! - const Duration(seconds: 1);
        });

        if (_timeRemaining!.inSeconds <= 0) {
          timer.cancel();
          widget.onTimerComplete();
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 600;
    final dialogWidth = isDesktop ? 600.0 : screenWidth * 0.9;
    final dialogMaxHeight = screenHeight * 0.8;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: dialogMaxHeight),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Target word
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.targetWord.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                ),
              ),
              const SizedBox(height: 20),

              // Timer section
              if (_timeRemaining != null) ...[
                Text(
                  'Next game in:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Text(
                    _formatDuration(_timeRemaining!),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Game will start automatically',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],

              // Action buttons
              if (isDesktop)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildActionButtons(context),
                )
              else
                Column(
                  children: _buildActionButtons(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[
      _buildButton(
        context,
        'Play Again',
        Icons.play_arrow,
        widget.onPlayAgain,
        isPrimary: true,
      ),
      const SizedBox(height: 12),
      _buildButton(
        context,
        'Close',
        Icons.close,
        widget.onClose,
      ),
    ];

    return buttons;
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final button = ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        backgroundColor:
            isPrimary ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: isDesktop ? const Size(100, 48) : Size(double.infinity, 48),
      ),
    );

    return button;
  }
}
