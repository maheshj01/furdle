import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/state/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _sharedPreferences;

  @override
  SettingsState build() {
    // Get SharedPreferences from the provider
    final sharedPrefsAsync = ref.watch(sharedPrefsServiceProvider);

    return sharedPrefsAsync.when(
      data: (sharedPrefs) {
        _sharedPreferences = sharedPrefs;
        return _loadSettingsFromPrefs(sharedPrefs);
      },
      loading: SettingsState.initial,
      error: (_, __) => SettingsState.initial(),
    );
  }

  SettingsState _loadSettingsFromPrefs(SharedPreferences prefs) {
    final settingsJson = prefs.getString('settings');
    if (settingsJson != null) {
      return SettingsState.fromJson(json.decode(settingsJson));
    }
    return SettingsState.initial();
  }

  void toggleNotifications() {
    final newValue = !state.isNotificationsEnabled;
    state = state.copyWith(isNotificationsEnabled: newValue);
    saveSettings();
  }

  void toggleSound() {
    final newValue = !state.isSoundEnabled;
    state = state.copyWith(isSoundEnabled: newValue);
    saveSettings();
  }

  void toggleDarkMode() {
    final newValue = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newValue);
    saveSettings();
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(isNotificationsEnabled: enabled);
    saveSettings();
  }

  void setSoundEnabled(bool enabled) {
    state = state.copyWith(isSoundEnabled: enabled);
    saveSettings();
  }

  void saveSettings() {
    final settingsJson = json.encode(state.toJson());
    _sharedPreferences.setString('settings', settingsJson);
  }
}

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

final sharedPrefsServiceProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});
