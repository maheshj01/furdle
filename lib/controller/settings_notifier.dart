import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/constants/const.dart';
import 'package:furdle/models/models.dart';
import 'package:furdle/service/storage_service.dart';
import 'package:furdle/shared/providers/storage_service_provider.dart';

final appSettingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(
  (ref) {
    final storage = ref.watch(storageServiceProvider);
    return SettingsNotifier(storage);
  },
);

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsNotifier extends StateNotifier<Settings> {
  // Make SettingsService a private variable so it is not used directly.
  final StorageService storageService;

  SettingsNotifier(this.storageService)
      : super(Settings(
          difficulty: Difficulty.medium,
          stats: Stats.initialStats(),
        )) {
    getCurrentSettings();
  }

  Future<void> getCurrentSettings() async {
    final settingsJson =
        await storageService.get(AppConstants.APP_SETTINGS_STORAGE_KEY);
    if (settingsJson != null) {
      state = Settings.fromJson(json.decode(settingsJson as String) as Map);
    } else {
      state = Settings(
        difficulty: Difficulty.medium,
        stats: Stats.initialStats(),
      );
    }
  }

  void updateStats(Stats stats) {
    state = state.copyWith(
      stats: stats,
    );
    storageService.set(
        AppConstants.APP_SETTINGS_STORAGE_KEY, json.encode(state.toJson()));
  }

  void toggleSound() {
    state = state.copyWith(sound: !state.sound);
    storageService.set(
        AppConstants.APP_SETTINGS_STORAGE_KEY, json.encode(state.toJson()));
  }

  void updateDifficulty(Difficulty difficulty) {
    state = state.copyWith(sound: state.sound, difficulty: difficulty);
    storageService.set(
        AppConstants.APP_SETTINGS_STORAGE_KEY, json.encode(state.toJson()));
  }
}
