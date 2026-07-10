// lib/features/documents/domain/services/document_scanner_service.dart

import 'dart:io';

/// Abstract service to handle document scanning using camera.
/// Decouples the application code from specific scanner packages.
abstract class DocumentScannerService {
  /// Launches the document scanning flow. Returns the cropped, enhanced image [File]
  /// if successful, or null if cancelled.
  Future<File?> scanDocument();
}
