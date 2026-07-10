// lib/features/documents/domain/usecases/scan_document_usecase.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

  /// Renders all scanned images into a temporary, compressed multi-page A4 PDF file.
  /// Downscales images to target ~150-250 DPI (width 1200px max) and quality 75% for size efficiency.
  Future<String> generateTempPdf(List<String> scannedImagePaths) async {
    if (scannedImagePaths.isEmpty) {
      throw const FileSystemException('Scanned images list cannot be empty');
    }

    final pdf = pw.Document();

    for (final path in scannedImagePaths) {
      final compressedBytes = await _compressImage(path);
      final image = pw.MemoryImage(Uint8List.fromList(compressedBytes));

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
    }

    // Save PDF in temporary application directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = p.join(tempDir.path, 'temp_scan_${_uuid.v4()}.pdf');
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(await pdf.save());

    return tempPath;
  }

  /// Finalizes the document save: copies the temporary PDF to final secure documents storage,
  /// saves metadata in Hive, and deletes all original scanned image temporary files.
  Future<Document> saveFinalDocument(
    String tempPdfPath,
    String documentName,
    List<String> originalTempImagePaths,
  ) async {
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

    // 4. Move temp PDF to secure private documents storage
    final targetDirectory = await _storageStrategy.getDocumentStorageDirectory();
    final docId = _uuid.v4();
    final targetFilename = '$docId.pdf';
    final targetPath = p.join(targetDirectory.path, targetFilename);

    final tempFile = File(tempPdfPath);
    if (!await tempFile.exists()) {
      throw const FileSystemException('Temporary PDF file does not exist');
    }

    // Copy to secure private directory
    await tempFile.copy(targetPath);

    // Clean up temporary PDF file on disk
    try {
      await tempFile.delete();
    } catch (_) {}

    final size = await File(targetPath).length();
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
      lastViewedPage: 1,
    );

    // 5. Persist metadata record in Hive
    await _repository.saveDocument(document);

    // 6. Cleanup: delete original temporary scanned images from storage to prevent leaks
    for (final path in originalTempImagePaths) {
      try {
        final f = File(path);
        if (await f.exists()) {
          await f.delete();
        }
      } catch (_) {}
    }

    return document;
  }

  /// Compresses a photo to target ~150-250 DPI. Downscales width to 1200px max and Jpeg quality 75%.
  Future<List<int>> _compressImage(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;

      img.Image resized = decoded;
      // Downscale if image is high resolution (wider than 1200 pixels)
      if (decoded.width > 1200) {
        resized = img.copyResize(decoded, width: 1200);
      }

      // Encode back to JPEG with quality parameter set to 75%
      return img.encodeJpg(resized, quality: 75);
    } catch (_) {
      return bytes; // Safe fallback to original bytes if decoding fails
    }
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
