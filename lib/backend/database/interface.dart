library;

import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:lexigo/backend/database/tables.dart';
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/device_info.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fsrs/fsrs.dart';
part 'interface.g.dart';

@DriftDatabase(tables: [WordTable, WordLearningHistoryTable])
class Database extends _$Database {
  Database._([QueryExecutor? executor]) : super(executor ?? _initConnection());

  static Database? _instance;

  factory Database([QueryExecutor? executor]) {
    _instance ??= Database._(executor ?? _initConnection());
    return _instance!;
  }

  Database.external(QueryExecutor executor) : this._(executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _initConnection() {
    final deviceInfo = DeviceInfoManager();
    final Future<Directory> Function() databaseDirectory = deviceInfo.isAndroid
        ? getApplicationDocumentsDirectory
        : getApplicationSupportDirectory;
    final db = driftDatabase(
      name: "database",
      native: DriftNativeOptions(databaseDirectory: databaseDirectory),
    );
    AppLogger.info('Database initialized.');
    return db;
  }
}
