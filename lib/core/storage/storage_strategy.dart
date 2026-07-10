// lib/core/storage/storage_strategy.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Defines the strategy for local file storage in MyDocs.
/// 
/// **Document Storage Principle (Mandatory)**:
/// All imported PDFs and images must be copied into the application's private storage. 
/// The app must never depend on the original file location after import. 
/// This ensures that if the user deletes or moves the original file (e.g., from the 
/// Downloads folder or camera gallery), the local copy remains fully accessible.
abstract class StorageStrategy {
  /// Gets the directory where private documents are copied and stored.
  Future<Directory> getDocumentStorageDirectory();

  /// Copies a file from its original location (external or temporary) to the 
  /// application's private storage directory. Returns the path of the newly copied file.
  Future<String> copyToPrivateStorage(String sourcePath, String filename);

  /// Deletes a file from the application's private storage directory.
  Future<void> deleteFromPrivateStorage(String filePath);
}

/// Concrete implementation of [StorageStrategy] using path_provider.
class LocalStorageStrategy implements StorageStrategy {
  static const String _documentFolderName = 'documents';

  @override
  Future<Directory> getDocumentStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final documentDir = Directory('${appDir.path}/$_documentFolderName');
    
    if (!await documentDir.exists()) {
      await documentDir.create(recursive: true);
    }
    
    return documentDir;
  }

  @override
  Future<String> copyToPrivateStorage(String sourcePath, String filename) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file does not exist', sourcePath);
    }

    final targetDirectory = await getDocumentStorageDirectory();
    // Use unique timestamp prefix to avoid name collisions
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetPath = '${targetDirectory.path}/${timestamp}_$filename';
    
    final copiedFile = await sourceFile.copy(targetPath);
    return copiedFile.path;
  }

  @override
  Future<void> deleteFromPrivateStorage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
