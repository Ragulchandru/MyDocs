import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/permissions.dart';
import '../../domain/services/document_scanner_service.dart';

class ScannerErrorHandler {
  /// Presents appropriate UI outcomes for camera permission decisions (SnackBars or Settings Dialogs).
  static Future<void> handlePermissionResult(
    BuildContext context,
    CameraPermissionResult result,
    AppLocalizations localizations,
  ) async {
    if (!context.mounted) return;

    if (result == CameraPermissionResult.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.cameraPermissionDenied),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result == CameraPermissionResult.permanentlyDenied) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.cameraPermissionTitle),
          content: Text(localizations.cameraPermissionPermanentlyDenied),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text(localizations.openSettings),
            ),
          ],
        ),
      );
    }
  }

  /// Presents appropriate SnackBar descriptions for native scanner failure states.
  static void handleScannerResult(
    BuildContext context,
    ScannerResult result,
    AppLocalizations localizations,
  ) {
    if (!context.mounted) return;

    // Cancellations or successful results exit cleanly with no notification
    if (result.status == ScannerStatus.success ||
        result.status == ScannerStatus.cancelled) {
      return;
    }

    String message;
    if (result.status == ScannerStatus.unavailable) {
      message = localizations.scannerUnavailable;
    } else if (result.status == ScannerStatus.failed) {
      if (result.errorCode != null && result.errorCode!.isNotEmpty) {
        final msg = result.errorMessage?.toLowerCase() ?? '';
        if (msg.contains('play services') ||
            msg.contains('waiting') ||
            msg.contains('download')) {
          message = localizations.scannerGooglePlayServicesError;
        } else {
          message = localizations.scannerUnexpectedError(result.errorMessage ?? 'Unknown error');
        }
      } else {
        message = result.errorMessage ?? localizations.errorScanFailed;
      }
    } else {
      message = localizations.errorScanFailed;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Displays a dialog prompting the user to decide whether to fall back to the basic camera scanner
  /// when the advanced Google ML Kit document scanner fails or is unavailable.
  static Future<bool> showFallbackPrompt(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations.scannerUnavailableTitle),
        content: Text(localizations.scannerUnavailableMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.useCamera),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
