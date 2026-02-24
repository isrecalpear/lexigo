/// File system permission management utilities.
///
/// Handles requesting storage permissions on Android.
/// iOS and macOS don't require explicit storage permissions.

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'device_info.dart';

/// Manages file system permissions for the application.
class PermissionManager {
  /// Ensures external storage access permission on required platforms.
  static Future<void> _ensureExternalIOAccess() async {
    final deviceInfo = DeviceInfoManager();
    if (deviceInfo.isApple) {
      // On iOS and macOS, we don't need to request storage permissions
      return;
    }

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  /// Requests read external storage permission if needed.
  static Future<void> makeSureReadExternalPermission() async {
    await _ensureExternalIOAccess();
  }

  /// Requests write external storage permission if needed.
  static Future<void> makeSureWriteExternalPermission() async {
    await _ensureExternalIOAccess();
  }
}
