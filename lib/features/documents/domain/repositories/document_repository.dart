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
}
