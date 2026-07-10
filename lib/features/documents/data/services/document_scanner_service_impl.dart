// lib/features/documents/data/services/document_scanner_service_impl.dart

import 'dart:io';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../../domain/services/document_scanner_service.dart';

/// Concrete implementation of [DocumentScannerService] using Google's official
/// `google_mlkit_document_scanner` package.
class DocumentScannerServiceImpl implements DocumentScannerService {
  @override
  Future<File?> scanDocument() async {
    // Instantiate document scanner options matching the exact API of version 0.4.1
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.full, // Autocrops and enhances the image
        isGalleryImport: false, // Disallows gallery import for standard camera scanning
        pageLimit: 1, // Enforces single page scan
      ),
    );

    try {
      final DocumentScanningResult result = await scanner.scanDocument();
      
      final images = result.images;
      if (images == null || images.isEmpty) {
        return null; // Cancelled, empty or failed
      }

      return File(images.first);
    } catch (_) {
      return null;
    } finally {
      // Clean up native resources immediately to prevent memory leaks
      scanner.close();
    }
  }
}
