import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/models/settings.dart';

final settingsProvider = ChangeNotifierProvider<Settings>((ref) {
  return Settings.initialize();
});
