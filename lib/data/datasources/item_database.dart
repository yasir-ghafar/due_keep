import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item_storage.dart';

/// On-device SQLite vault. Schema lives here; queries live on the datasource.
class ItemDatabase {
  ItemDatabase({this.path});

  /// Override for tests. Production uses the app documents directory.
  final String? path;

  Database? _db;

  Future<Database> get instance async => _db ??= await _open();

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> _open() async {
    final dbPath = path ?? await _defaultPath();
    return openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE items (
  ${ItemColumns.id} TEXT PRIMARY KEY NOT NULL,
  ${ItemColumns.vendor} TEXT NOT NULL,
  ${ItemColumns.category} TEXT NOT NULL,
  ${ItemColumns.cycle} TEXT NOT NULL,
  ${ItemColumns.nextDate} TEXT NOT NULL,
  ${ItemColumns.status} TEXT NOT NULL,
  ${ItemColumns.amount} REAL,
  ${ItemColumns.currency} TEXT,
  ${ItemColumns.reminderOffsets} TEXT NOT NULL,
  ${ItemColumns.notes} TEXT,
  ${ItemColumns.cancelUrl} TEXT,
  ${ItemColumns.lastPaidOn} TEXT,
  ${ItemColumns.createdAt} TEXT NOT NULL,
  ${ItemColumns.updatedAt} TEXT NOT NULL
)
''');
        await db.execute('''
CREATE TABLE attachments (
  ${AttachmentColumns.id} TEXT PRIMARY KEY NOT NULL,
  ${AttachmentColumns.itemId} TEXT NOT NULL,
  ${AttachmentColumns.relativePath} TEXT NOT NULL,
  ${AttachmentColumns.sortOrder} INTEGER NOT NULL,
  FOREIGN KEY (${AttachmentColumns.itemId}) REFERENCES items(${ItemColumns.id}) ON DELETE CASCADE
)
''');
        await db.execute(
          'CREATE INDEX attachments_item_id ON attachments (${AttachmentColumns.itemId})',
        );
      },
    );
  }

  static Future<String> _defaultPath() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'duekeep'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return p.join(dir.path, 'duekeep.db');
  }
}
