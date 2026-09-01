import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../models/item_record.dart';
import '../models/item_storage.dart';
import '../datasources/attachment_store.dart';
import '../datasources/item_database.dart';

/// SQLite rows + files on disk. Survives force-quit.
class SqliteItemRepository implements ItemRepository {
  SqliteItemRepository({
    required ItemDatabase database,
    required AttachmentStore attachments,
  })  : _database = database,
        _attachments = attachments;

  final ItemDatabase _database;
  final AttachmentStore _attachments;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<List<Item>> watchAll() {
    late final StreamController<List<Item>> controller;
    StreamSubscription<void>? changesSub;
    controller = StreamController<List<Item>>(
      onListen: () {
        changesSub = _changes.stream.listen((_) async {
          if (!controller.isClosed) {
            controller.add(await getAll());
          }
        });
        getAll().then((items) {
          if (!controller.isClosed) controller.add(items);
        });
      },
      onCancel: () => changesSub?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<List<Item>> getAll() async {
    try {
      final db = await _database.instance;
      final rows = await db.query(
        'items',
        orderBy: '${ItemColumns.nextDate} ASC, ${ItemColumns.vendor} COLLATE NOCASE ASC',
      );
      final paths = await _pathsByItem(db);
      return [
        for (final row in rows)
          ItemRecord.fromRow(
            row,
            attachmentPaths: paths[row[ItemColumns.id] as String] ?? const [],
          ),
      ];
    } catch (_) {
      throw CacheException('Could not read the vault.');
    }
  }

  @override
  Future<Item?> getById(String id) async {
    try {
      final db = await _database.instance;
      final rows = await db.query(
        'items',
        where: '${ItemColumns.id} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final paths = await _pathsByItem(db, itemId: id);
      return ItemRecord.fromRow(
        rows.first,
        attachmentPaths: paths[id] ?? const [],
      );
    } catch (_) {
      throw CacheException('Could not read the vault.');
    }
  }

  @override
  Future<void> save(Item item) async {
    try {
      final previous = await getById(item.id);
      final stored = await _materialize(item.id, item.attachmentPaths);
      final now = DateTime.now().toUtc().toIso8601String();
      final db = await _database.instance;

      await db.transaction((txn) async {
        final existing = await txn.query(
          'items',
          columns: [ItemColumns.createdAt],
          where: '${ItemColumns.id} = ?',
          whereArgs: [item.id],
        );
        final createdAt = existing.isEmpty
            ? now
            : existing.first[ItemColumns.createdAt]! as String;
        await txn.insert(
          'items',
          ItemRecord.toRow(
            item.copyWith(attachmentPaths: stored),
            createdAt: createdAt,
            updatedAt: now,
          ),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await txn.delete(
          'attachments',
          where: '${AttachmentColumns.itemId} = ?',
          whereArgs: [item.id],
        );
        for (var i = 0; i < stored.length; i++) {
          await txn.insert('attachments', {
            AttachmentColumns.id: '${item.id}:$i',
            AttachmentColumns.itemId: item.id,
            AttachmentColumns.relativePath: stored[i],
            AttachmentColumns.sortOrder: i,
          });
        }
      });

      final stale = (previous?.attachmentPaths ?? const <String>[])
          .where((path) => !stored.contains(path));
      for (final path in stale) {
        await _attachments.deleteRelative(path);
      }
      _changes.add(null);
    } on CacheException {
      rethrow;
    } catch (_) {
      throw const CacheException('Could not write the vault.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _database.instance;
      await db.delete(
        'items',
        where: '${ItemColumns.id} = ?',
        whereArgs: [id],
      );
      await _attachments.deleteItem(id);
      _changes.add(null);
    } catch (_) {
      throw const CacheException('Could not write the vault.');
    }
  }

  Future<void> dispose() async {
    await _changes.close();
    await _database.close();
  }

  Future<List<String>> _materialize(String itemId, List<String> paths) async {
    final stored = <String>[];
    for (final path in paths) {
      if (await _attachments.isStored(path)) {
        stored.add(await _attachments.toRelative(path));
        continue;
      }
      if (await File(path).exists()) {
        stored.add(
          await _attachments.import(itemId: itemId, sourcePath: path),
        );
      }
    }
    return stored;
  }

  Future<Map<String, List<String>>> _pathsByItem(
    Database db, {
    String? itemId,
  }) async {
    final rows = await db.query(
      'attachments',
      where: itemId == null ? null : '${AttachmentColumns.itemId} = ?',
      whereArgs: itemId == null ? null : [itemId],
      orderBy: '${AttachmentColumns.itemId}, ${AttachmentColumns.sortOrder}',
    );
    final grouped = <String, List<String>>{};
    for (final row in rows) {
      final id = row[AttachmentColumns.itemId]! as String;
      grouped.putIfAbsent(id, () => []).add(
            row[AttachmentColumns.relativePath]! as String,
          );
    }
    return grouped;
  }
}
