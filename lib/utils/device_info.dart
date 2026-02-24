// Dart imports:
import 'dart:io';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';

/// Manages device information checks.
///
/// Provides cached access to device properties like platform type and device form factor.
/// This is a singleton that centralizes all device-related checks throughout the app.
class DeviceInfoManager {
  static final DeviceInfoManager _instance = DeviceInfoManager._internal();

  bool _cachedIsPadDevice = false;

  DeviceInfoManager._internal();

  factory DeviceInfoManager() {
    return _instance;
  }

  /// Initializes device information checks.
  ///
  /// Must be called once during app startup to populate cached values.
  Future<void> initialize() async {
    _cachedIsPadDevice = await _checkIsPadDevice();
  }

  /// Checks if device is a tablet.
  ///
  /// For iOS, checks if the model contains 'iPad'.
  /// For Android, checks if system features include tablet hardware.
  /// For other platforms, returns false.
  Future<bool> _checkIsPadDevice() async {
    if (Platform.isIOS) {
      return DeviceInfoPlugin().iosInfo.then((info) =>
          info.model.toLowerCase().contains('ipad'));
    } else if (Platform.isAndroid) {
      return DeviceInfoPlugin().androidInfo.then((info) =>
          info.systemFeatures.contains('android.hardware.type.tablet'));
    } else {
      return Future.value(false);
    }
  }

  /// Returns whether the device is a tablet using cached value.
  ///
  /// This is a synchronous method that returns the cached result from initialization.
  bool isPadDevice() {
    return _cachedIsPadDevice;
  }

  // Platform checks

  /// Returns true if running on iOS.
  bool get isIOS => Platform.isIOS;

  /// Returns true if running on Android.
  bool get isAndroid => Platform.isAndroid;

  /// Returns true if running on macOS.
  bool get isMacOS => Platform.isMacOS;

  /// Returns true if running on Linux.
  bool get isLinux => Platform.isLinux;

  /// Returns true if running on Windows.
  bool get isWindows => Platform.isWindows;

  // Platform group checks

  /// Returns true if running on iOS or macOS.
  bool get isApple => Platform.isIOS || Platform.isMacOS;

  /// Returns true if running on a desktop platform (macOS, Linux, Windows).
  bool get isDesktop => Platform.isMacOS || Platform.isLinux || Platform.isWindows;

  /// Returns true if running on a mobile platform (iOS or Android).
  bool get isMobile => Platform.isIOS || Platform.isAndroid;

  /// Returns true if dynamic color is supported.
  ///
  /// Dynamic color is not supported on iOS.
  bool get supportsDynamicColor => !isIOS;

  /// Returns true if file sharing is supported.
  ///
  /// File sharing is not supported on Linux.
  bool get supportsFileSharing => !isLinux;

  /// Returns true if external storage permissions need to be requested.
  ///
  /// Only Android requires explicit storage permission requests.
  bool get needsStoragePermission => isAndroid;
}
