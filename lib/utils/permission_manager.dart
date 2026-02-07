// Package imports:
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static Future<void> _ensureExternalIOAccess() async {
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
