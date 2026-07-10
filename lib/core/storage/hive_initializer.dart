// lib/core/storage/hive_initializer.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:mydocs/core/storage/storage_constants.dart';

class HiveInitializer {
  /// Initializes Hive and opens all required boxes for the application.
  static Future<void> init() async {
    await Hive.initFlutter();

    // Open the required application boxes
    await Hive.openBox(StorageConstants.documentsBox);
    await Hive.openBox(StorageConstants.foldersBox);
    await Hive.openBox(StorageConstants.settingsBox);
    await Hive.openBox(StorageConstants.recycleBinBox);
  }

  // Private constructor to prevent instantiation
  HiveInitializer._();
}
