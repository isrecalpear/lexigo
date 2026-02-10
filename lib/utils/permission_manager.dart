// Dart imports:
import 'dart:io';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
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

  static Future<void> makeSureReadExternalPermission() async {
    await _ensureExternalIOAccess();
  }

  static Future<void> makeSureWriteExternalPermission() async {
    await _ensureExternalIOAccess();
  }
}
