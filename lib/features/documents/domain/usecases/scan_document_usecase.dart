// lib/features/documents/domain/usecases/scan_document_usecase.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';
import '../../../../core/storage/storage_strategy.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';

class ScanDocumentUseCase {
  final DocumentRepository _repository;
  final StorageStrategy _storageStrategy;
  final Uuid _uuid = const Uuid();

  ScanDocumentUseCase(this._repository, this._storageStrategy);

  /// Converts a scanned image [File] into a high-quality A4 PDF document,
  /// saves it inside MyDocs private storage using a unique UUID filename,
  /// sanitizes the document name, handles title duplicates automatically,
  /// and persists metadata.
  Future<Document> execute(String scannedImagePath, String documentName) async {
    final imageFile = File(scannedImagePath);
    if (!await imageFile.exists()) {
      throw const FileSystemException('Scanned image file does not exist');
    }

    // 1. Sanitization: remove invalid characters / \ : * ? " < > |
    var sanitized = documentName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');

    // 2. Whitespace Normalization: replace multiple consecutive spaces with a single space
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (sanitized.isEmpty) {
      throw const InvalidDocumentNameException();
    }

    // 3. De-duplication: check existing files and suffix with sequential numbering if needed
    final existingDocuments = await _repository.getDocuments();
    final finalTitle = _getDeduplicatedTitle(existingDocuments, sanitized);

    // 4. PDF Generation: render standard A4 PDF document
    final pdf = pw.Document();
    final imageBytes = await imageFile.readAsBytes();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero, // Maximizes document visibility
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    // 5. Storage: generate target destination under MyDocs/documents/UUID.pdf
    final targetDirectory = await _storageStrategy.getDocumentStorageDirectory();
    final docId = _uuid.v4();
    final targetFilename = '$docId.pdf';
    final targetPath = p.join(targetDirectory.path, targetFilename);

    final targetFile = File(targetPath);
    if (await targetFile.exists()) {
      throw const FileSystemException('Target PDF already exists');
    }

    // Write PDF bytes asynchronously
    await targetFile.writeAsBytes(await pdf.save());

    final size = await targetFile.length();
    final now = DateTime.now();

    final document = Document(
      id: docId,
      name: finalTitle,
      fileName: '$finalTitle.pdf', // Displayed filename
      extension: '.pdf',
      filePath: targetPath,
      fileType: DocumentType.pdf,
      fileSize: size,
      createdAt: now,
      updatedAt: now,
    );

    // Persist metadata record in Hive
    await _repository.saveDocument(document);

    return document;
  }

  /// Automatically appends sequential numbering (e.g. `(2)`, `(3)`) to prevent title duplicates
  String _getDeduplicatedTitle(List<Document> documents, String baseTitle) {
    final existingNames = documents.map((d) => d.name).toSet();
    if (!existingNames.contains(baseTitle)) {
      return baseTitle;
    }
    
    int count = 2;
    while (existingNames.contains('$baseTitle ($count)')) {
      count++;
    }
    return '$baseTitle ($count)';
  }
}

class InvalidDocumentNameException implements Exception {
  const InvalidDocumentNameException();
}
