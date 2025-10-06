import 'package:flutter_test/flutter_test.dart';
import 'package:furdle/state/settings_state.dart';

void main() {
  group('SettingsState Twitter functionality', () {
    test('should include twitterUsername in initial state', () {
      final settings = SettingsState.initial();
      expect(settings.twitterUsername, equals(''));
      expect(settings.isNotificationsEnabled, equals(true));
      expect(settings.isDarkMode, equals(false));
    });

    test('should update twitterUsername with copyWith', () {
      final settings = SettingsState.initial();
      final updatedSettings = settings.copyWith(twitterUsername: 'testuser');
      
      expect(updatedSettings.twitterUsername, equals('testuser'));
      expect(updatedSettings.isNotificationsEnabled, equals(true)); // Other fields unchanged
    });

    test('should serialize and deserialize twitterUsername correctly', () {
      final settings = SettingsState(
        isNotificationsEnabled: false,
        isSoundEnabled: false,
        isDarkMode: true,
        twitterUsername: 'johndoe',
      );

      final json = settings.toJson();
      expect(json['twitterUsername'], equals('johndoe'));

      final restored = SettingsState.fromJson(json);
      expect(restored.twitterUsername, equals('johndoe'));
      expect(restored.isDarkMode, equals(true));
    });

    test('should handle missing twitterUsername in fromJson', () {
      final json = {
        'isNotificationsEnabled': true,
        'isSoundEnabled': true,
        'isDarkMode': false,
        // twitterUsername missing
      };

      final settings = SettingsState.fromJson(json);
      expect(settings.twitterUsername, equals(''));
    });
  });
}