import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/service/shared_pref_service.dart';

final storageServiceProvider = Provider((ref) {
  final SharedPrefsService prefsService = SharedPrefsService();
  prefsService.init();
  return prefsService;
});
