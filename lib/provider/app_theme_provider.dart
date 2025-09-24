import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/colors.dart';
import 'package:furdle/provider/settings_notifier.dart';

/// Provider that derives ThemeMode from settings
final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
});

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      useMaterial3: true, // Enable Material Design 3
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryVariantDark,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.infoDark,
        onSecondary: Colors.black,
        tertiary: AppColors.successDark,
        onTertiary: Colors.black,
        error: AppColors.errorDark,
        onError: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        surfaceContainer: AppColors.surfaceContainerDark,
        outline: AppColors.outlineDark,
        outlineVariant: AppColors.outlineVariantDark,
        shadow: Colors.black,
        scrim: AppColors.overlayDark,
        inverseSurface: Colors.white,
        onInverseSurface: Colors.black,
        inversePrimary: AppColors.primaryDark,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surfaceVariantDark,
        foregroundColor: AppColors.onSurfaceDark,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.dialogSurfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardColorDark,
        elevation: 1,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.outlineVariantDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDark.withValues(alpha: 0.3);
          }
          return AppColors.outlineVariantDark;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariantDark,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Light theme data of the app - Updated for Material Design 3
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      useMaterial3: true, // Enable Material Design 3
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE3F2FD),
        onPrimaryContainer: Color(0xFF0D47A1),
        secondary: Color(0xFF2196F3),
        onSecondary: Colors.white,
        tertiary: Color(0xFF4CAF50),
        onTertiary: Colors.white,
        error: Color(0xFFE53935),
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
        onSurfaceVariant: Color(0xFF424242),
        surfaceContainer: Color(0xFFEEEEEE),
        outline: Color(0xFF757575),
        outlineVariant: Color(0xFFBDBDBD),
        shadow: Colors.black26,
        scrim: Color(0x66000000),
        inverseSurface: Colors.black87,
        onInverseSurface: Colors.white,
        inversePrimary: Color(0xFF90CAF9),
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return const Color(0xFFBDBDBD);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.3);
          }
          return const Color(0xFFBDBDBD);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFBDBDBD),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
