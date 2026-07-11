// lib/features/documents/domain/usecases/scan_document_usecase.dart

import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';
import '../../../../core/storage/storage_strategy.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';

enum DocumentQualityProfile {
  preview,
  finalSave,
}

class _PdfProcessingParams {
  final List<String> scannedImagePaths;
  final String outputPath;
  final bool debugMode;
  final DocumentQualityProfile qualityProfile;

  _PdfProcessingParams({
    required this.scannedImagePaths,
    required this.outputPath,
    required this.debugMode,
    required this.qualityProfile,
  });
}

/// Worker function executed in the background isolate to do CPU-heavy image resizing and PDF page generation.
Future<void> _processImagesToPdf(_PdfProcessingParams params) async {
  Stopwatch? totalStopwatch;
  if (params.debugMode) {
    totalStopwatch = Stopwatch()..start();
    debugPrint('[ScanTiming] Isolate PDF generation started');
  }

  final pdf = pw.Document();

  for (final path in params.scannedImagePaths) {
    Stopwatch? pageStopwatch;
    if (params.debugMode) {
      pageStopwatch = Stopwatch()..start();
    }

    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException('Scanned image file does not exist', path);
    }

    final bytes = file.readAsBytesSync();
    if (bytes.isEmpty) {
      throw FileSystemException('Scanned image file is empty (0 bytes)', path);
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode scanned image at $path');
    }

    // Preserve orientation by baking EXIF rotation.
    final orientedImage = img.bakeOrientation(decoded);

    // Apply quality profile configurations
    final maxDim = params.qualityProfile == DocumentQualityProfile.preview ? 1200 : 2560;
    final quality = params.qualityProfile == DocumentQualityProfile.preview ? 60 : 85;

    img.Image resized = orientedImage;
    if (orientedImage.width > maxDim || orientedImage.height > maxDim) {
      if (orientedImage.width > orientedImage.height) {
        resized = img.copyResize(orientedImage, width: maxDim);
      } else {
        resized = img.copyResize(orientedImage, height: maxDim);
      }
    }
    final compressedBytes = img.encodeJpg(resized, quality: quality);

    if (params.debugMode && pageStopwatch != null) {
      debugPrint('[ScanTiming] Image processing (decode/orient/resize/jpeg) for $path: ${pageStopwatch.elapsedMilliseconds} ms');
      pageStopwatch.reset();
    }

    final image = pw.MemoryImage(Uint8List.fromList(compressedBytes));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    if (params.debugMode && pageStopwatch != null) {
      debugPrint('[ScanTiming] PDF Page layout added for $path: ${pageStopwatch.elapsedMilliseconds} ms');
    }
  }

  final pdfBytes = await pdf.save();
  final outputFile = File(params.outputPath);
  outputFile.writeAsBytesSync(pdfBytes, flush: true);

  if (params.debugMode && totalStopwatch != null) {
    debugPrint('[ScanTiming] Isolate PDF generation and write completed in: ${totalStopwatch.elapsedMilliseconds} ms');
  }
}

class ScanDocumentUseCase {
  final DocumentRepository _repository;
  final StorageStrategy _storageStrategy;
  final Uuid _uuid = const Uuid();

  ScanDocumentUseCase(this._repository, this._storageStrategy);

  /// Renders all scanned images into a temporary, compressed multi-page A4 PDF file using a background isolate.
  Future<String> generateTempPdf(
    List<String> scannedImagePaths, {
    DocumentQualityProfile qualityProfile = DocumentQualityProfile.finalSave,
  }) async {
    if (scannedImagePaths.isEmpty) {
      throw const FileSystemException('Scanned images list cannot be empty');
    }

    final tempDir = await getTemporaryDirectory();
    final tempPath = p.join(tempDir.path, 'temp_scan_${_uuid.v4()}.pdf');

    // Run heavy CPU tasks in a background isolate to keep UI thread smooth
    await Isolate.run(
      () => _processImagesToPdf(
        _PdfProcessingParams(
          scannedImagePaths: scannedImagePaths,
          outputPath: tempPath,
          debugMode: kDebugMode,
          qualityProfile: qualityProfile,
        ),
      ),
    );

    final tempFile = File(tempPath);
    if (!await tempFile.exists() || await tempFile.length() == 0) {
      throw FileSystemException('Temporary PDF was not written successfully or is empty', tempPath);
    }

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

    // 5. Persist metadata record in Hive (Transactional rollback cleanup if this fails)
    try {
      await _repository.saveDocument(document);
    } catch (e) {
      try {
        final finalFile = File(targetPath);
        if (await finalFile.exists()) {
          await finalFile.delete();
        }
      } catch (_) {}
      rethrow;
    }

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
