import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/service/hive_storage_service.dart';

final hiveStorageServiceProvider = Provider<HiveStorageService>((ref) {
  final hiveStorageService = HiveStorageService();
  hiveStorageService.initializeHive();
  return hiveStorageService;
});
