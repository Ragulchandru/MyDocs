// lib/features/documents/domain/models/document.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

/// Supported document types in MyDocs.
enum DocumentType {
  pdf,
  image,
}

@freezed
class Document with _$Document {
  const factory Document({
    required String id,
    required String name,
    required String fileName,
    required String extension,
    required String filePath,
    required DocumentType fileType,
    required int fileSize,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}
