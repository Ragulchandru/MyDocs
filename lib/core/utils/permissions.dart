import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionResult {
  granted,
  denied,
  permanentlyDenied,
}

class CameraPermissionHelper {
  /// Checks and requests camera permissions.
  /// Decoupled from BuildContext and UI presentation to avoid lifecycle issues.
  static Future<CameraPermissionResult> checkAndRequestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return CameraPermissionResult.granted;
    }

    if (status.isPermanentlyDenied) {
      return CameraPermissionResult.permanentlyDenied;
    }

    final result = await Permission.camera.request();
    if (result.isGranted) {
      return CameraPermissionResult.granted;
    }

    if (result.isPermanentlyDenied) {
      return CameraPermissionResult.permanentlyDenied;
    }

    return CameraPermissionResult.denied;
  }
}
