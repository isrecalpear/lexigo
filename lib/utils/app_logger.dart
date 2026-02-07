// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// 应用日志管理器
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  static Logger? _logger;
  static File? _logFile;
  static const int _maxLogFiles = 7; // 保留最近7天的日志
  static const int _maxLogSizeBytes = 5 * 1024 * 1024; // 单个日志文件最大5MB

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  static Future<Directory> _getLogBaseDirectory() async {
    return Platform.isAndroid
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();
  }

  /// 初始化日志系统
  static Future<void> initialize() async {
    try {
      // 获取应用数据目录（Android使用Documents目录，其他平台使用Support目录）
      final Directory appDir = await _getLogBaseDirectory();
      final Directory logDir = Directory('${appDir.path}/logs');

      // 创建日志目录（如果不存在）
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // 清理旧日志文件
      await _cleanOldLogs(logDir);

      // 创建今天的日志文件
      final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _logFile = File('${logDir.path}/lexigo_$dateStr.log');

      // 配置日志器
      _logger = Logger(
        filter: ProductionFilter(),
        printer: _CustomLogPrinter(),
        output: _FileOutput(_logFile!),
        level: Level.debug,
      );

      _logger!.i('日志系统初始化成功');
    } catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stackTrace,
          library: 'app_logger',
          context: ErrorDescription('初始化日志系统失败'),
        ),
      );
    }
  }

  /// 清理旧的日志文件
  static Future<void> _cleanOldLogs(Directory logDir) async {
    try {
      final List<FileSystemEntity> files = logDir.listSync();
      final List<File> logFiles = files
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();

      // 按修改时间排序
      logFiles.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      // 删除超过保留数量的文件
      if (logFiles.length > _maxLogFiles) {
        for (int i = _maxLogFiles; i < logFiles.length; i++) {
          await logFiles[i].delete();
        }
      }

      // 检查并删除过大的文件
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
          context: ErrorDescription('清理旧日志失败'),
        ),
      );
    }
  }

  /// 获取日志目录路径
  static Future<String?> getLogDirectory() async {
    try {
      final Directory appDir = await _getLogBaseDirectory();
      return '${appDir.path}/logs';
    } catch (e) {
      return null;
    }
  }

  /// 获取当天日志文件路径
  static Future<String?> getCurrentLogFilePath() async {
    try {
      if (_logFile != null) {
        return _logFile!.path;
      }
      final String? logDirPath = await getLogDirectory();
      if (logDirPath == null) return null;
      final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return '$logDirPath/lexigo_$dateStr.log';
    } catch (e) {
      return null;
    }
  }

  /// 读取当天日志内容
  static Future<String> readCurrentLog() async {
    try {
      final String? path = await getCurrentLogFilePath();
      if (path == null) return '';
      final File file = File(path);
      if (!await file.exists()) return '';
      return await file.readAsString();
    } catch (e) {
      _logger?.e('读取日志失败', error: e);
      return '';
    }
  }

  /// 清除所有日志
  static Future<void> clearAllLogs() async {
    try {
      final String? logDirPath = await getLogDirectory();
      if (logDirPath != null) {
        final Directory logDir = Directory(logDirPath);
        if (await logDir.exists()) {
          await logDir.delete(recursive: true);
          await logDir.create();
          _logger?.i('所有日志已清除');
        }
      }
    } catch (e) {
      _logger?.e('清除日志失败', error: e);
    }
  }

  /// 获取日志文件大小（MB）
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
          return totalSize / (1024 * 1024); // 转换为MB
        }
      }
    } catch (e) {
      _logger?.e('获取日志大小失败', error: e);
    }
    return 0.0;
  }

  // 日志方法
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

/// 自定义日志打印器
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

/// 文件输出
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
          context: ErrorDescription('写入日志文件失败'),
        ),
      );
    }
  }
}
