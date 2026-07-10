// lib/core/storage/storage_strategy.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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

  /// Copies a file from its original location to the application's private 
  /// documents directory using a generated UUID filename, preserving the original extension.
  Future<String> copyToPrivateStorage(String sourcePath, String filename);

  /// Deletes a file from the application's private storage directory.
  Future<void> deleteFromPrivateStorage(String filePath);
}

/// Concrete implementation of [StorageStrategy] using path_provider and absolute paths.
class LocalStorageStrategy implements StorageStrategy {
  static const String _appFolderName = 'MyDocs';
  static const String _documentsFolderName = 'documents';
  final Uuid _uuid = const Uuid();

  @override
  Future<Directory> getDocumentStorageDirectory() async {
    // Obtain absolute documents directory on the system
    final appDocDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(appDocDir.path, _appFolderName, _documentsFolderName));
    
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    
    return targetDir;
  }

  @override
  Future<String> copyToPrivateStorage(String sourcePath, String filename) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file does not exist', sourcePath);
    }

    final targetDirectory = await getDocumentStorageDirectory();
    final extension = p.extension(filename).toLowerCase();
    final uniqueId = _uuid.v4();
    final targetFilename = '$uniqueId$extension';
    final targetPath = p.join(targetDirectory.path, targetFilename);
    
    // Safety check: ensure file doesn't exist (extremely low probability of UUID clash)
    final targetFile = File(targetPath);
    if (await targetFile.exists()) {
      throw FileSystemException('Target file already exists', targetPath);
    }

    // Copy the file offline
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
