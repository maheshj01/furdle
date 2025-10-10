import 'package:flutter/material.dart';
import 'package:furdle/constants/const.dart';
import 'package:intl/intl.dart';

class _DeviceSize {
  final double maxWidth;
  final double maxHeight;
  const _DeviceSize({
    required this.maxWidth,
    required this.maxHeight,
  });
}

const double kDesignWidth = 375.0;
const double kDesignHeight = 812.0;

/// Extension to handle responsive font sizing
extension ResponsiveSize on BuildContext {
  // Get device pixel ratio
  double get _devicePixelRatio => MediaQuery.of(this).devicePixelRatio;
  // Get screen size
  Size get _screenSize => MediaQuery.of(this).size;
  // Base dimensions for scaling calculation (Figma)
  static const double _baseWidth = kDesignWidth;
  static const double _baseHeight = kDesignHeight;
  // Mobile device size ranges

  double get width => _screenSize.width;

  double get height => _screenSize.height;

  static const _DeviceSize _compactPhone = _DeviceSize(
    maxWidth: 375.0, // Common Android (Samsung A series, Pixel)
    maxHeight: 740.0, // Typical height for 16:9 compact phones
  );
  static const _DeviceSize _mediumPhone = _DeviceSize(
    maxWidth: 415.0, // iPhone 12/13/14/16
    maxHeight: 900.0, // iPhone 12/13/14/16 height
  );
  static const _DeviceSize _largePhone = _DeviceSize(
    maxWidth: 440.0, // iPhone Pro Max models
    maxHeight: 960.0, // iPhone Pro Max height
  );

  static const _DeviceSize _tablet = _DeviceSize(
    maxWidth: 768.0,
    maxHeight: 1024.0,
  );

  static const _DeviceSize _desktop = _DeviceSize(
    maxWidth: 1440.0,
    maxHeight: 900.0,
  );

  double get _scaleFactor {
    final width = _screenSize.width;
    final height = _screenSize.height;
    final scale = width / _baseWidth;
    final dprAdjustment = (_devicePixelRatio <= 2) ? 1.0 : 1.15;
    // Determine device size category based on both dimensions
    if (width <= _compactPhone.maxWidth && height <= _compactPhone.maxHeight) {
      return (scale * dprAdjustment).clamp(0.8, 1);
    } else if (width <= _mediumPhone.maxWidth && height <= _mediumPhone.maxHeight) {
      return (scale * dprAdjustment).clamp(0.85, 1);
    } else if (width <= _largePhone.maxWidth && height <= _largePhone.maxHeight) {
      return (scale * dprAdjustment).clamp(0.9, 1.1);
    } else if (width <= _tablet.maxWidth && height <= _tablet.maxHeight) {
      return (scale * dprAdjustment).clamp(1.1, 1.2);
    } else if (width <= _desktop.maxWidth && height <= _desktop.maxHeight) {
      return (scale * dprAdjustment).clamp(1.4, 1.5);
    }
    // Fallback for any other device size
    return (scale * dprAdjustment).clamp(1.4, 1.5);
  }

  // Scale fonts and spaces based on device
  double sp(double size) => size * _scaleFactor;

  double wp(double size) => size * _screenSize.width / _baseWidth;

  double hp(double size) => size * _screenSize.height / _baseHeight;
  // Calculate max width based on screen size

  /// max width of the keyboard
  double maxKeyboardWidth() {
    // For small screens, use full width
    if (_screenSize.width < 600) {
      return _screenSize.width;
    }

    return 600;
  }
}

extension StringExtension on String {
  /// check ascii value of the string is between 65 and 90 or 97 and 122
  bool get isLetter {
    return this.length == 1 &&
            this.isNotEmpty &&
            this.codeUnitAt(0) >= 65 &&
            this.codeUnitAt(0) <= 90 ||
        this.codeUnitAt(0) >= 97 && this.codeUnitAt(0) <= 122;
  }
}

extension DurationExtension on Duration {
  /// format the duration like this:
  /// 1h 30m 0s
  String formatDuration() {
    if (this == Duration.zero) return 'N/A';

    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

extension DateHelper on DateTime {
  /// format the date in this format:
  /// October 09, 2025
  String formatDate() {
    final now = DateTime.now();
    final differenceInDays = getDifferenceInDaysWithNow();

    if (isSameDate(now)) {
      return 'Today';
    } else if (differenceInDays == 1) {
      return 'Yesterday';
    } else {
      final formatter = DateFormat(Constants.dateFormatter);
      return formatter.format(this);
    }
  }

  /// format the date time like this:
  /// October 09, 2025 12:00 PM
  String formatDateTime() {
    final formatter = DateFormat(Constants.dateTimeFormatter2);
    return formatter.format(this);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }

  String standardTime() {
    final formatter = DateFormat(Constants.timeFormatter);
    return formatter.format(this);
  }

  String standardDate() {
    final formatter = DateFormat(Constants.dateFormatter);
    return formatter.format(this);
  }

  String standardDateTime() {
    final formatter = DateFormat(Constants.dateTimeFormatter);
    return formatter.format(this);
  }

  int daysInAMonth() {
    return DateUtils.getDaysInMonth(year, month);
  }
}
