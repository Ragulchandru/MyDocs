// lib/features/documents/data/repositories/document_repository_impl.dart

import 'package:hive/hive.dart';
import '../../domain/models/document.dart';
import '../../domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final Box<Document> _box;

  DocumentRepositoryImpl(this._box);

  @override
  Future<List<Document>> getDocuments() async {
    return _box.values.toList();
  }

  @override
  Future<Document?> getDocumentById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> saveDocument(Document document) async {
    await _box.put(document.id, document);
  }

  @override
  Stream<List<Document>> watchDocuments() async* {
    // Yield the initial list immediately
    yield _box.values.toList();
    // Yield a new list whenever the box is modified
    await for (final _ in _box.watch()) {
      yield _box.values.toList();
    }
  }
}
