import '../../domain/services/document_scanner_service.dart';

class DocumentScannerCoordinator implements DocumentScannerService {
  final DocumentScannerService _mlKitScanner;
  final DocumentScannerService _cameraScanner;

  DocumentScannerCoordinator(this._mlKitScanner, this._cameraScanner);

  @override
  Future<ScannerResult> scanDocument({Future<bool> Function()? onFallbackPrompt}) async {
    final result = await _mlKitScanner.scanDocument();

    // If successfully scanned or explicitly cancelled by the user, return immediately.
    // User cancellations do not trigger the basic camera fallback.
    if (result.status == ScannerStatus.success || result.status == ScannerStatus.cancelled) {
      return result;
    }

    // If the ML Kit scanner is unavailable or genuinely failed:
    if (onFallbackPrompt == null) {
      return result;
    }

    // Prompt user to decide whether to launch basic camera scanner fallback
    final useCamera = await onFallbackPrompt();
    if (useCamera) {
      return _cameraScanner.scanDocument();
    }

    // If the user chooses not to use the camera, exit silently
    return ScannerResult(status: ScannerStatus.cancelled);
  }
}
