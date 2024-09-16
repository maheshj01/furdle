import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/service/storage_service.dart';
import 'package:furdle/shared/providers/storage_service_provider.dart';
import 'package:furdle/shared/theme/colors.dart';

final appThemeProvider = StateNotifierProvider<AppThemeModeNotifier, ThemeMode>(
  (ref) {
    final storage = ref.watch(storageServiceProvider);
    return AppThemeModeNotifier(storage);
  },
);

class AppThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService storageService;

  ThemeMode currentTheme = ThemeMode.light;

  AppThemeModeNotifier(this.storageService) : super(ThemeMode.light) {
    getCurrentTheme();
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    storageService.set(AppConstants.APP_THEME_STORAGE_KEY, state.name);
  }

  Future<void> getCurrentTheme() async {
    final theme = await storageService.get(AppConstants.APP_THEME_STORAGE_KEY);
    final value = ThemeMode.values.byName('${theme ?? 'light'}');
    state = value;
  }

  void setTheme(ThemeMode theme) {
    state = theme;
    storageService.set(AppConstants.APP_THEME_STORAGE_KEY, state.name);
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
      ),
      // backgroundColor: AppColors.black,
      scaffoldBackgroundColor: AppColors.black,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.black,
      ),
    );
  }

  /// Light theme data of the app
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
