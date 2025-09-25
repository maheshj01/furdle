import 'package:flutter/material.dart';

class AppColors {
  /// Light Mode
  static const Color primary = Color(0xff086ce7);
  static const Color surface = Colors.white;

  // Letter status colors
  static const Color green = Colors.green;
  static const Color black = Colors.black87;
  static const Color grey = Colors.grey;
  static Color yellow = Colors.yellow[800]!;

  /// Dark Mode - Modern Design Standards 2024
  // Based on Material Design 3 and modern accessibility guidelines

  // Primary colors - Modern blue with slight purple tint
  static const Color primaryDark = Color(0xFF6750A4); // Modern purple-blue
  static const Color primaryVariantDark = Color(0xFF7C67D6); // Lighter variant

  // Surface colors - Avoid pure black, use dark grays
  static const Color surfaceDark = Color(0xFF121212); // Material 3 surface
  static const Color surfaceVariantDark = Color(0xFF1E1E1E); // Elevated surfaces
  static const Color surfaceContainerDark = Color(0xFF2D2D2D); // Container surfaces
  static const Color surfaceContainerHighDark = Color(0xFF3A3A3A); // High elevation

  // Background and foreground
  static const Color backgroundDark = Color(0xFF0F0F0F); // True background
  static const Color foregroundDark = Color(0xFFE6E1E5); // High contrast text

  // Dialog and overlay surfaces
  static const Color dialogSurfaceDark = Color(0xFF1C1C1C); // Dialog background
  static const Color overlayDark = Color(0x66000000); // Semi-transparent overlay

  // Card and container colors
  static const Color cardColorDark = Color(0xFF1E1E1E);
  static const Color cardColorElevatedDark = Color(0xFF2A2A2A);

  // State colors - Adjusted for dark mode
  static const Color errorDark = Color(0xFFCF6679); // Soft red for errors
  static const Color warningDark = Color(0xFFFFB74D); // Soft orange for warnings
  static const Color successDark = Color(0xFF81C784); // Soft green for success
  static const Color infoDark = Color(0xFF64B5F6); // Soft blue for info

  // Neutral colors for text and borders
  static const Color onSurfaceDark = Color(0xFFE6E1E5); // Primary text
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0); // Secondary text
  static const Color outlineDark = Color(0xFF938F99); // Borders and dividers
  static const Color outlineVariantDark = Color(0xFF49454F); // Subtle borders
}
