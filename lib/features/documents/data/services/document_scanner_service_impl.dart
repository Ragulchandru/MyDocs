import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../../domain/services/document_scanner_service.dart';

/// Concrete implementation of [DocumentScannerService] using Google's official
/// `google_mlkit_document_scanner` package.
class DocumentScannerServiceImpl implements DocumentScannerService {
  @override
  Future<ScannerResult> scanDocument() async {
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
          debugPrint('[Scanner] Scanner returned successfully but images list was empty');
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
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[Scanner] PlatformException code: ${e.code}');
        debugPrint('[Scanner] PlatformException message: ${e.message}');
        debugPrint('[Scanner] PlatformException details: ${e.details}');
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
        );
      }

      return ScannerResult(
        status: ScannerStatus.failed,
        errorMessage: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Scanner] Unexpected error: $e');
      }
      return ScannerResult(
        status: ScannerStatus.failed,
        errorMessage: e.toString(),
      );
    } finally {
      // Clean up native resources immediately to prevent memory leaks
      scanner.close();
    }
  }
}
