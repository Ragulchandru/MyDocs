import 'dart:io';

enum ScannerStatus {
  success,
  cancelled,
  permissionDenied,
  permissionPermanentlyDenied,
  unavailable,
  failed,
}

class ScannerResult {
  final ScannerStatus status;
  final File? file;
  final String? errorMessage;
  final String? errorCode;

  ScannerResult({
    required this.status,
    this.file,
    this.errorMessage,
    this.errorCode,
  });
}

/// Abstract service to handle document scanning using camera.
/// Decouples the application code from specific scanner packages.
abstract class DocumentScannerService {
  /// Launches the document scanning flow. Returns the structured [ScannerResult].
  Future<ScannerResult> scanDocument();
}
