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
  Database._(super.executor);

  /// Shared application database.
  ///
  /// Previously every `WordManager` opened its own connection to the same file,
  /// leaving several sqlite handles open concurrently. All application code now
  /// uses this singleton; passing an explicit [QueryExecutor] opens a separate
  /// connection instead (import/export tooling, tests).
  static final Database _instance = Database._(_initConnection());

  /// Returns the shared database, or a dedicated one for [executor].
  factory Database([QueryExecutor? executor]) {
    if (executor == null) {
      return _instance;
    }
    return Database._(executor);
  }

  /// Opens a dedicated connection for a database file outside the app.
  ///
  /// Used by the word import/export tooling, which reads and writes temporary
  /// SQLite files instead of the application database.
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
