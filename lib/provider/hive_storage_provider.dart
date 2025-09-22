import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:furdle/service/storage_service.dart';
import 'package:furdle/service/hive_storage_service.dart';

final hiveStorageServiceProvider = Provider<StorageService>((ref) {
  return HiveStorageService();
});

final hiveStorageProvider = Provider<HiveStorageService>((ref) {
  return HiveStorageService();
}); 