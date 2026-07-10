// lib/features/documents/domain/usecases/get_documents_usecase.dart

import '../models/document.dart';
import '../repositories/document_repository.dart';

class GetDocumentsUseCase {
  final DocumentRepository _repository;

  GetDocumentsUseCase(this._repository);

  /// Subscribes to the repository's watch stream, exposing the documents list
  /// sorted by creation date in descending order (newest first).
  Stream<List<Document>> execute() {
    return _repository.watchDocuments().map((list) {
      return List<Document>.from(list)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }
}
