/// SQLite database initialization and schema management.
///
/// This file handles database setup, singleton instance management,
/// and ensures the schema with proper indexes for word storage by language.

// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

// Project imports:
import 'package:lexigo/utils/app_logger.dart';
import 'package:lexigo/utils/device_info.dart';

/// Database singleton that manages SQLite connection and schema.
class Database {
  /// Singleton database instance.
  static sqlite.Database? _db;

  /// Gets or initializes the SQLite database.
  ///
  /// Creates database file if needed and ensures base schema exists.
  /// Returns the same instance on subsequent calls (singleton pattern).
  static Future<sqlite.Database> getInstance() async {
    if (_db != null) {
      return _db!;
    }

    final File dbFile = await _getDatabaseFile();
    if (!await dbFile.exists()) {
      await dbFile.create(recursive: true);
    }

    final db = sqlite.sqlite3.open(dbFile.path);
    db.execute('PRAGMA foreign_keys = ON;');
    _ensureBaseSchema(db);
    _db = db;
    AppLogger.info('Database initialized: ${dbFile.path}');
    return db;
  }

  /// Closes the database connection.
  static Future<void> close() async {
    _db?.close();
    _db = null;
    AppLogger.info('Database connection closed');
  }

  /// Generates the table name for a given language code.
  ///
  /// Example: 'en' -> 'words_en'
  static String tableNameForLanguage(String languageCode) {
    return 'words_$languageCode';
  }

  /// Ensures a language-specific word table exists with proper schema and indexes.
  ///
  /// Each language has its own table to organize words by source language.
  /// Indexes are created on card_due for efficient scheduling queries.
  static void ensureLanguageTable(
    sqlite.Database db,
    String languageCode, {
    String? displayName,
  }) {
    final tableName = tableNameForLanguage(languageCode);
    db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_word TEXT NOT NULL,
        translation TEXT NOT NULL,
        original_example TEXT NOT NULL,
        example_translation TEXT NOT NULL,
        unit_id TEXT NOT NULL DEFAULT 'DefaultUnit',
        book_id TEXT NOT NULL DEFAULT 'DefaultBook',
        card_id INTEGER NOT NULL UNIQUE,
        card_state INTEGER NOT NULL,
        card_step INTEGER,
        card_stability REAL,
        card_difficulty REAL,
        card_due INTEGER NOT NULL,
        card_last_review INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(original_word, book_id, unit_id)
      );
    ''');
    AppLogger.debug('Language table ensured: $tableName');

    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_due
      ON $tableName (card_due);
    ''');

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    db.execute(
      '''
      INSERT INTO language_tables (
        language_code, table_name, display_name, word_count, created_at, updated_at
      )
      VALUES (?, ?, ?, 0, ?, ?)
      ON CONFLICT(language_code) DO UPDATE SET
        table_name = excluded.table_name,
        display_name = excluded.display_name,
        updated_at = excluded.updated_at;
      ''',
      [languageCode, tableName, displayName, now, now],
    );
    AppLogger.info('Updated language table info: $languageCode -> $tableName');
  }

  /// Gets the database file path.
  ///
  /// On Android, uses application documents directory.
  /// On other platforms, uses application support directory.
  static Future<File> _getDatabaseFile() async {
    final deviceInfo = DeviceInfoManager();
    final Directory appDocDir = deviceInfo.isAndroid
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();
    final String dbPath = '${appDocDir.path}/database.db';
    return File(dbPath);
  }

  /// Ensures the base schema exists (language_tables metadata table).
  static void _ensureBaseSchema(sqlite.Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS language_tables (
        language_code TEXT PRIMARY KEY,
        table_name TEXT NOT NULL UNIQUE,
        display_name TEXT,
        word_count INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
    AppLogger.debug('Language summary table ensured');
  }
}
