// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  static Logger? _logger;
  static File? _logFile;
  static const int _maxLogFiles = 7;
  static const int _maxLogSizeBytes = 5 * 1024 * 1024;

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  static Future<Directory> _getLogBaseDirectory() async {
    /* 
    return Platform.isAndroid
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();
    */
    return await getApplicationSupportDirectory();
  }

  static Future<void> initialize() async {
    try {
      final Directory appDir = await _getLogBaseDirectory();
      final Directory logDir = Directory('${appDir.path}/logs');

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      await _cleanOldLogs(logDir);

      final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _logFile = File('${logDir.path}/$dateStr.log');

      _logger = Logger(
        filter: ProductionFilter(),
        printer: _CustomLogPrinter(),
        output: _FileOutput(_logFile!),
        level: Level.debug,
      );

      _logger!.i('Logger initialized');
    } catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stackTrace,
          library: 'app_logger',
          context: ErrorDescription('Failed to initialize logger'),
        ),
      );
    }
  }

  static Future<void> _cleanOldLogs(Directory logDir) async {
    try {
      final List<FileSystemEntity> files = logDir.listSync();
      final List<File> logFiles = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();

      logFiles.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      if (logFiles.length > _maxLogFiles) {
        for (int i = _maxLogFiles; i < logFiles.length; i++) {
          await logFiles[i].delete();
        }
      }

      for (final file in logFiles) {
        final int fileSize = await file.length();
        if (fileSize > _maxLogSizeBytes) {
          await file.delete();
        }
      }
    } catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stackTrace,
          library: 'app_logger',
          context: ErrorDescription('Failed to clean old logs'),
        ),
      );
    }
  }

  static Future<String?> getLogDirectory() async {
    try {
      final Directory appDir = await _getLogBaseDirectory();
      return '${appDir.path}/logs';
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getCurrentLogFilePath() async {
    try {
      if (_logFile != null) {
        return _logFile!.path;
      }
      final String? logDirPath = await getLogDirectory();
      if (logDirPath == null) return null;
      final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return '$logDirPath/$dateStr.log';
    } catch (e) {
      return null;
    }
  }

  /// Read today's log content.
  static Future<String> readCurrentLog() async {
    try {
      final String? path = await getCurrentLogFilePath();
      if (path == null) return '';
      final File file = File(path);
      if (!await file.exists()) return '';
      return await file.readAsString();
    } catch (e) {
      _logger?.e('Failed to read log file', error: e);
      return '';
    }
  }

  static Future<void> clearAllLogs() async {
    try {
      final String? logDirPath = await getLogDirectory();
      if (logDirPath != null) {
        final Directory logDir = Directory(logDirPath);
        if (await logDir.exists()) {
          await logDir.delete(recursive: true);
          await logDir.create();
          _logger?.i('All logs have been cleared');
        }
      }
    } catch (e) {
      _logger?.e('Failed to clear logs', error: e);
    }
  }

  static Future<double> getLogSize() async {
    try {
      final String? logDirPath = await getLogDirectory();
      if (logDirPath != null) {
        final Directory logDir = Directory(logDirPath);
        if (await logDir.exists()) {
          int totalSize = 0;
          final List<FileSystemEntity> files = logDir.listSync();
          for (final file in files) {
            if (file is File) {
              totalSize += await file.length();
            }
          }
          return totalSize / (1024 * 1024);
        }
      }
    } catch (e) {
      _logger?.e('Failed to get log size', error: e);
    }
    return 0.0;
  }

  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger?.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger?.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger?.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger?.f(message, error: error, stackTrace: stackTrace);
  }
}

class _CustomLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final String timestamp = DateFormat(
      'yyyy-MM-dd HH:mm:ss.SSS',
    ).format(DateTime.now());
    final String level = event.level.name.toUpperCase();
    final String message = event.message.toString();

    final List<String> lines = ['[$timestamp] [$level] $message'];

    if (event.error != null) {
      lines.add('Error: ${event.error}');
    }

    if (event.stackTrace != null) {
      lines.add('StackTrace:\n${event.stackTrace}');
    }

    return lines;
  }
}

class _FileOutput extends LogOutput {
  final File file;

  _FileOutput(this.file);

  @override
  void output(OutputEvent event) {
    try {
      final String content = '${event.lines.join('\n')}\n';
      file.writeAsStringSync(content, mode: FileMode.append);
    } catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stackTrace,
          library: 'app_logger',
          context: ErrorDescription('Failed to write log to file'),
        ),
      );
    }
  }
}
