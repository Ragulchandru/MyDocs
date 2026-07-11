// lib/features/documents/data/repositories/document_repository_impl.dart

import 'dart:io';
import 'package:hive/hive.dart';
import '../../domain/models/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../services/thumbnail_service.dart';

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

  @override
  Future<void> deleteDocument(String id) async {
    await permanentlyDelete(id);
  }

  @override
  Future<void> moveToRecycleBin(String id) async {
    final doc = await getDocumentById(id);
    if (doc != null) {
      final updatedDoc = doc.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await saveDocument(updatedDoc);
    }
  }

  @override
  Future<void> moveManyToRecycleBin(Iterable<String> ids) async {
    for (final id in ids) {
      await moveToRecycleBin(id);
    }
  }

  @override
  Future<void> restoreDocument(String id) async {
    final doc = await getDocumentById(id);
    if (doc != null) {
      final updatedDoc = doc.copyWith(
        isDeleted: false,
        deletedAt: null,
        updatedAt: DateTime.now(),
      );
      await saveDocument(updatedDoc);
    }
  }

  @override
  Future<void> restoreMany(Iterable<String> ids) async {
    for (final id in ids) {
      await restoreDocument(id);
    }
  }

  @override
  Future<void> permanentlyDelete(String id) async {
    final doc = await getDocumentById(id);
    if (doc != null) {
      // 1. Delete physical document file
      try {
        final file = File(doc.filePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}

      // 2. Delete cached thumbnail
      await ThumbnailService.deleteThumbnail(id);

      // 3. Delete Hive record
      await _box.delete(id);
    }
  }

  @override
  Future<void> permanentlyDeleteMany(Iterable<String> ids) async {
    for (final id in ids) {
      await permanentlyDelete(id);
    }
  }
}
