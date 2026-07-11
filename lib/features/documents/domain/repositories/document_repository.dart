// lib/features/documents/domain/repositories/document_repository.dart

import '../models/document.dart';

abstract class DocumentRepository {
  /// Retrieves all imported documents.
  Future<List<Document>> getDocuments();

  /// Retrieves a document by its unique ID.
  Future<Document?> getDocumentById(String id);

  /// Saves or updates a document metadata record in storage.
  Future<void> saveDocument(Document document);

  /// Watches document metadata changes dynamically.
  Stream<List<Document>> watchDocuments();

  /// Deletes a document record and its physical file.
  Future<void> deleteDocument(String id);

  /// Moves a document to the Recycle Bin (soft delete).
  Future<void> moveToRecycleBin(String id);

  /// Moves multiple documents to the Recycle Bin (soft delete).
  Future<void> moveManyToRecycleBin(Iterable<String> ids);

  /// Restores a document from the Recycle Bin.
  Future<void> restoreDocument(String id);

  /// Restores multiple documents from the Recycle Bin.
  Future<void> restoreMany(Iterable<String> ids);

  /// Permanently deletes a document (physical file + thumbnail + Hive record).
  Future<void> permanentlyDelete(String id);

  /// Permanently deletes multiple documents.
  Future<void> permanentlyDeleteMany(Iterable<String> ids);
}
