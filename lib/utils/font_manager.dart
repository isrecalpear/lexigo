/// Downloads, caches and applies the optional user-selected UI fonts.
///
/// Fonts are deliberately **not** bundled with the application. When the user
/// selects MiSans or HarmonyOS Sans, the official font archive is downloaded
/// from the vendor's website, the required weights are extracted into the
/// application support directory, and the files are registered with Flutter's
/// font engine at runtime through [FontLoader].
library;

// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:lexigo/utils/app_font.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/font_archive.dart';

/// Reports how many bytes of a font archive have been downloaded.
///
/// [total] is `null` when the server does not send a `Content-Length` header, in
/// which case the UI should show an indeterminate progress indicator.
typedef FontDownloadProgress = void Function(int received, int? total);

/// Raised when a font package cannot be downloaded, validated or unpacked.
class FontInstallException implements Exception {
  const FontInstallException(this.message);

  /// Human readable description, already suitable for a snack bar.
  final String message;

  @override
  String toString() => message;
}

/// Manages the optional user fonts (MiSans and HarmonyOS Sans).
///
/// The class is a singleton because both the root application widget (theme)
/// and the settings page (download UI) use the same cached font state.
class FontManager {
  FontManager._();

  /// Shared instance.
  static final FontManager instance = FontManager._();

  static const Duration _connectTimeout = Duration(seconds: 30);
  static const int _progressReportStep = 256 * 1024;

  /// File written after a successful extraction, used as the cache marker.
  static const String _markerFileName = '.lexigo-font.json';

  AppFont _activeFont = AppFont.system;

  /// Font currently registered with the engine (or [AppFont.system]).
  AppFont get activeFont => _activeFont;

  /// Font family that should be passed to `ThemeData.fontFamily`, if any.
  String? get activeFamily => _activeFont.familyName;

  /// Whether [font] has a completed download in the local cache.
  Future<bool> isInstalled(AppFont font) async {
    if (font.isSystem) {
      return true;
    }

    final List<File> files = await _installedFontFiles(font);
    if (files.isEmpty) {
      return false;
    }

    final Directory directory = await _fontDirectory(font);
    return File('${directory.path}/$_markerFileName').exists();
  }

  /// Registers the cached files of [font] with Flutter's font engine.
  ///
  /// Returns `false` when the font is not installed yet, in which case the
  /// caller should keep using the system font.
  Future<bool> loadFont(AppFont font) async {
    if (font.isSystem) {
      _activeFont = AppFont.system;
      return true;
    }

    final String? family = font.familyName;
    if (family == null) {
      return false;
    }

    final List<File> files = await _installedFontFiles(font);
    if (files.isEmpty) {
      AppLogger.warning('Font ${font.name} is selected but not downloaded');
      return false;
    }

    final FontLoader loader = FontLoader(family);
    try {
      for (final File file in files) {
        final Uint8List bytes = await file.readAsBytes();
        loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to register font ${font.name}',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }

    _activeFont = font;
    AppLogger.info('Loaded font ${font.name} (${files.length} weights)');
    return true;
  }

  /// Downloads and installs [font] from its official vendor URL.
  ///
  /// The archive is downloaded to a temporary file, unpacked into a staging
  /// directory and only then moved into the cache, so an interrupted download
  /// never leaves a half-installed font behind.
  Future<void> installFont(
    AppFont font, {
    FontDownloadProgress? onProgress,
  }) async {
    final String? downloadUrl = font.downloadUrl;
    if (downloadUrl == null || font.isSystem) {
      throw const FontInstallException('This font does not require a download');
    }

    final Directory root = await _fontRootDirectory();
    final Directory downloadDirectory = Directory('${root.path}/downloads');
    await downloadDirectory.create(recursive: true);

    final File archiveFile = File(
      '${downloadDirectory.path}/${font.storageId}.zip',
    );
    final Directory stagingDirectory = Directory(
      '${root.path}/${font.storageId}.staging',
    );
    final Directory targetDirectory = Directory(
      '${root.path}/${font.storageId}',
    );

    try {
      await _downloadArchive(font, archiveFile, onProgress);
      await _verifyArchiveFile(archiveFile);

      if (await stagingDirectory.exists()) {
        await stagingDirectory.delete(recursive: true);
      }
      await stagingDirectory.create(recursive: true);

      final int extracted = await _extractFonts(archiveFile, stagingDirectory);
      if (extracted == 0) {
        throw const FontInstallException(
          'The downloaded archive does not contain usable font files',
        );
      }

      await _writeMarker(stagingDirectory, font);

      if (await targetDirectory.exists()) {
        await targetDirectory.delete(recursive: true);
      }
      await stagingDirectory.rename(targetDirectory.path);

      AppLogger.info(
        'Installed font ${font.name} from official source ($extracted files)',
      );
    } on FontInstallException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to install font ${font.name}',
        error: error,
        stackTrace: stackTrace,
      );
      throw FontInstallException('$error');
    } finally {
      if (await archiveFile.exists()) {
        await archiveFile.delete();
      }
      if (await stagingDirectory.exists()) {
        await stagingDirectory.delete(recursive: true);
      }
    }
  }

  /// Removes the cached files for [font].
  ///
  /// The in-memory font cannot be unregistered from the engine, so callers
  /// should switch back to the system font before deleting the cache.
  Future<void> removeFont(AppFont font) async {
    if (font.isSystem) {
      return;
    }

    final Directory directory = await _fontDirectory(font);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    if (_activeFont == font) {
      _activeFont = AppFont.system;
    }
  }

  Future<Directory> _fontRootDirectory() async {
    final Directory supportDirectory = await getApplicationSupportDirectory();
    return Directory('${supportDirectory.path}/fonts');
  }

  Future<Directory> _fontDirectory(AppFont font) async {
    final Directory root = await _fontRootDirectory();
    return Directory('${root.path}/${font.storageId}');
  }

  Future<List<File>> _installedFontFiles(AppFont font) async {
    final Directory directory = await _fontDirectory(font);
    if (!await directory.exists()) {
      return <File>[];
    }

    final List<File> files = await directory
        .list()
        .where((FileSystemEntity entity) => entity is File)
        .cast<File>()
        .where((File file) {
          final String path = file.path.toLowerCase();
          return path.endsWith('.ttf') || path.endsWith('.otf');
        })
        .toList();

    // Files are named with their numeric weight prefix, so lexical sorting
    // gives a stable registration order.
    files.sort((File a, File b) => a.path.compareTo(b.path));
    return files;
  }

  Future<void> _downloadArchive(
    AppFont font,
    File destination,
    FontDownloadProgress? onProgress,
  ) async {
    final String? downloadUrl = font.downloadUrl;
    if (downloadUrl == null) {
      throw const FontInstallException('Missing font download URL');
    }

    final HttpClient client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final HttpClientRequest request = await client.getUrl(
        Uri.parse(downloadUrl),
      );
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'Mozilla/5.0 (compatible; LexiGo/1.0; +FontDownloader)',
      );
      final String? referer = font.officialPageUrl;
      if (referer != null) {
        request.headers.set(HttpHeaders.refererHeader, referer);
      }
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');

      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw FontInstallException(
          'Official font server returned HTTP ${response.statusCode}',
        );
      }

      final int? total = response.contentLength > 0
          ? response.contentLength
          : null;
      final IOSink sink = destination.openWrite();
      int received = 0;
      int lastReported = 0;
      try {
        await for (final List<int> chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          if (received - lastReported >= _progressReportStep) {
            lastReported = received;
            onProgress?.call(received, total);
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      onProgress?.call(received, total);
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _verifyArchiveFile(File archiveFile) async {
    if (!await archiveFile.exists() || await archiveFile.length() == 0) {
      throw const FontInstallException('The downloaded font archive is empty');
    }

    final RandomAccessFile handle = await archiveFile.open();
    try {
      final Uint8List magic = await handle.read(2);
      if (magic.length < 2 || magic[0] != 0x50 || magic[1] != 0x4B) {
        throw const FontInstallException(
          'The downloaded file is not a valid ZIP archive',
        );
      }
    } finally {
      await handle.close();
    }
  }

  /// Extracts the wanted weights from [archiveFile] into [directory].
  Future<int> _extractFonts(File archiveFile, Directory directory) async {
    final FontArchiveResult result = await FontArchiveExtractor.extract(
      archiveFile,
      directory,
    );
    return result.fonts.length;
  }

  Future<void> _writeMarker(Directory directory, AppFont font) async {
    final File marker = File('${directory.path}/$_markerFileName');
    await marker.writeAsString(
      jsonEncode(<String, Object?>{
        'font': font.storageId,
        'source': font.downloadUrl,
        'installedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }
}
