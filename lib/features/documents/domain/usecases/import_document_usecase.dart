// lib/features/documents/domain/usecases/import_document_usecase.dart

import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../../../core/storage/storage_strategy.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';

class ImportDocumentUseCase {
  final DocumentRepository _repository;
  final StorageStrategy _storageStrategy;
  final Uuid _uuid = const Uuid();

  ImportDocumentUseCase(this._repository, this._storageStrategy);

  /// Imports a document from the local device storage into MyDocs private storage.
  /// 
  /// Performs strict validation on file extensions and MIME types, copies the file
  /// to private sandbox storage, derives a clean user-friendly title, and registers
  /// the metadata inside the database.
  Future<Document> execute(String sourcePath, String originalFilename) async {
    final file = File(sourcePath);
    if (!await file.exists()) {
      throw const FileSystemException('Source file does not exist');
    }

    final ext = p.extension(originalFilename).toLowerCase();
    final mimeType = lookupMimeType(sourcePath);

    DocumentType docType;

    // Validate extension & MIME type consistency
    if (ext == '.pdf') {
      if (mimeType != 'application/pdf') {
        throw const MimeTypeMismatchException();
      }
      docType = DocumentType.pdf;
    } else if (ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.webp') {
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw const MimeTypeMismatchException();
      }
      // Re-verify that image extensions map to supported image MIME types
      final validMimes = {'image/jpeg', 'image/png', 'image/webp'};
      if (!validMimes.contains(mimeType)) {
        throw const MimeTypeMismatchException();
      }
      docType = DocumentType.image;
    } else {
      throw const UnsupportedFileTypeException();
    }

    // Derive a clean, capitalized title for the document
    final friendlyName = _deriveCleanTitle(originalFilename);

    // Copy file locally using our UUID storage strategy (ensures absolute isolation)
    final copiedPath = await _storageStrategy.copyToPrivateStorage(sourcePath, originalFilename);
    final size = await file.length();
    final now = DateTime.now();

    final document = Document(
      id: _uuid.v4(),
      name: friendlyName,
      fileName: originalFilename,
      extension: ext,
      filePath: copiedPath,
      fileType: docType,
      fileSize: size,
      createdAt: now,
      updatedAt: now,
      lastViewedPage: 1,
    );

    // Persist document metadata in database
    await _repository.saveDocument(document);
    return document;
  }

  /// Helper to convert raw filename configurations like 'DrivingLicense2023.pdf' to 'Driving License 2023'
  String _deriveCleanTitle(String filename) {
    // Remove the extension
    final nameWithoutExt = filename.contains('.') 
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;

    // Replace underscores, hyphens, and dots with spaces
    var formatted = nameWithoutExt.replaceAll(RegExp(r'[-_\.]'), ' ');

    // Separate camelCase words
    formatted = formatted.replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])'), 
      (Match m) => ' ',
    );

    // Capitalize each word
    final capitalized = formatted.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).where((element) => element.isNotEmpty).join(' ');

    return capitalized.trim();
  }
}

// Exception declarations

class UnsupportedFileTypeException implements Exception {
  const UnsupportedFileTypeException();
}

class MimeTypeMismatchException implements Exception {
  const MimeTypeMismatchException();
}
