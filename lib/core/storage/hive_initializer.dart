// lib/core/storage/hive_initializer.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../../features/documents/domain/models/document.dart';
import '../../features/documents/data/models/document_adapter.dart';
import 'storage_constants.dart';

class HiveInitializer {
  /// Initializes Hive and opens all required boxes for the application.
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register manual TypeAdapters
    Hive.registerAdapter(DocumentAdapter());

    // Open the required application boxes with proper typing and schema mismatch resilience
    try {
      await Hive.openBox<Document>(StorageConstants.documentsBox);
    } catch (_) {
      await Hive.deleteBoxFromDisk(StorageConstants.documentsBox);
      await Hive.openBox<Document>(StorageConstants.documentsBox);
    }

    try {
      await Hive.openBox(StorageConstants.foldersBox);
    } catch (_) {
      await Hive.deleteBoxFromDisk(StorageConstants.foldersBox);
      await Hive.openBox(StorageConstants.foldersBox);
    }

    try {
      await Hive.openBox(StorageConstants.settingsBox);
    } catch (_) {
      await Hive.deleteBoxFromDisk(StorageConstants.settingsBox);
      await Hive.openBox(StorageConstants.settingsBox);
    }

    try {
      await Hive.openBox(StorageConstants.recycleBinBox);
    } catch (_) {
      await Hive.deleteBoxFromDisk(StorageConstants.recycleBinBox);
      await Hive.openBox(StorageConstants.recycleBinBox);
    }
  }

  // Private constructor to prevent instantiation
  HiveInitializer._();
}
