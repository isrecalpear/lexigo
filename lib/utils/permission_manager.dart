/// File system permission management utilities.
///
/// Handles requesting storage permissions on Android.
/// iOS and macOS don't require explicit storage permissions.

// Dart imports:
import 'dart:io';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

/// Manages file system permissions for the application.
class PermissionManager {
  /// Ensures external storage access permission on required platforms.
  static Future<void> _ensureExternalIOAccess() async {
    if (Platform.isMacOS || Platform.isIOS) {
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
