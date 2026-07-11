import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../../domain/services/document_scanner_service.dart';

class GoogleMlKitDocumentScanner implements DocumentScannerService {
  @override
  Future<ScannerResult> scanDocument({Future<bool> Function()? onFallbackPrompt}) async {
    // Instantiate document scanner options matching the exact API of version 0.4.1
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.base, // Raw crop only, without forced ML auto-enhancements
        isGalleryImport: false, // Disallows gallery import for standard camera scanning
        pageLimit: 1, // Enforces single page scan
      ),
    );

    if (kDebugMode) {
      debugPrint('[Scanner] Launching Google ML Kit scanner');
    }

    try {
      final DocumentScanningResult result = await scanner.scanDocument();
      
      final images = result.images;
      if (images == null || images.isEmpty) {
        if (kDebugMode) {
          debugPrint('[Scanner] status: ScannerStatus.failed');
          debugPrint('[Scanner] exception runtimeType: NullOrEmptyImagesException');
          debugPrint('[Scanner] PlatformException code: empty');
          debugPrint('[Scanner] PlatformException message: No scanned pages were returned.');
          debugPrint('[Scanner] PlatformException details: null');
          debugPrint('[Scanner] stackTrace: null');
        }
        return ScannerResult(
          status: ScannerStatus.failed,
          errorMessage: 'No scanned pages were returned.',
        );
      }

      if (kDebugMode) {
        debugPrint('[Scanner] Scanner returned successfully with ${images.length} images');
      }

      return ScannerResult(
        status: ScannerStatus.success,
        file: File(images.first),
      );
    } on PlatformException catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[Scanner] status: ScannerStatus.failed');
        debugPrint('[Scanner] exception runtimeType: ${e.runtimeType}');
        debugPrint('[Scanner] PlatformException code: ${e.code}');
        debugPrint('[Scanner] PlatformException message: ${e.message}');
        debugPrint('[Scanner] PlatformException details: ${e.details}');
        debugPrint('[Scanner] stackTrace: $stack');
      }

      final String code = e.code;
      final String msg = e.message?.toLowerCase() ?? '';

      // Check if user cancelled
      if (code == '2' || code == '2002' || msg.contains('cancel') || msg.contains('user cancelled')) {
        return ScannerResult(status: ScannerStatus.cancelled);
      }

      // Check if it is a Google Play Services/ML Kit download or availability failure
      if (msg.contains('play services') || msg.contains('unavailable') || msg.contains('waiting for') || msg.contains('download')) {
        return ScannerResult(
          status: ScannerStatus.unavailable,
          errorMessage: e.message,
          errorCode: e.code,
          details: e.details,
        );
      }

      return ScannerResult(
        status: ScannerStatus.failed,
        errorMessage: e.message,
        errorCode: e.code,
        details: e.details,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[Scanner] status: ScannerStatus.failed');
        debugPrint('[Scanner] exception runtimeType: ${e.runtimeType}');
        debugPrint('[Scanner] stackTrace: $stack');
      }
      return ScannerResult(
        status: ScannerStatus.failed,
        errorMessage: e.toString(),
        details: e,
      );
    } finally {
      // Clean up native resources immediately to prevent memory leaks
      scanner.close();
    }
  }
}
