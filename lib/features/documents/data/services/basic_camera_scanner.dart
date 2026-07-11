import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/services/document_scanner_service.dart';

class BasicCameraScanner implements DocumentScannerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<ScannerResult> scanDocument({Future<bool> Function()? onFallbackPrompt}) async {
    if (kDebugMode) {
      debugPrint('[Scanner] Launching basic camera scanner');
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        requestFullMetadata: true,
      );

      if (photo == null) {
        if (kDebugMode) {
          debugPrint('[Scanner] Basic camera image picker returned null (user cancelled)');
        }
        return ScannerResult(status: ScannerStatus.cancelled);
      }

      final file = File(photo.path);
      final fileExists = await file.exists();
      final fileLength = fileExists ? await file.length() : 0;

      if (kDebugMode) {
        debugPrint('[Scanner] Basic camera capture returned successfully: ${photo.path} (size: $fileLength bytes)');
      }

      if (fileExists && fileLength > 0) {
        return ScannerResult(
          status: ScannerStatus.success,
          file: file,
        );
      } else {
        return ScannerResult(
          status: ScannerStatus.failed,
          errorMessage: 'Unable to capture the document photo.',
        );
      }
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
      if (code == 'camera_access_denied' || msg.contains('permission')) {
        return ScannerResult(
          status: ScannerStatus.permissionDenied,
          errorMessage: e.message,
          errorCode: e.code,
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
    }
  }
}
