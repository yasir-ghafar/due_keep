import 'dart:async';
import 'dart:io';

import 'package:due_keep/data/datasources/attachment_store.dart';
import 'package:due_keep/data/datasources/item_database.dart';
import 'package:due_keep/data/repositories/sqlite_item_repository.dart';
import 'package:due_keep/domain/entities/item.dart';
import 'package:due_keep/domain/enums/item_category.dart';
import 'package:due_keep/domain/enums/item_cycle.dart';
import 'package:due_keep/domain/enums/item_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Item _item({
  required String id,
  String vendor = 'Netflix',
  List<String> attachments = const [],
  DateTime? nextDate,
}) {
  return Item(
    id: id,
    vendor: vendor,
    category: ItemCategory.subscription,
    cycle: ItemCycle.monthly,
    nextDate: nextDate ?? DateTime(2026, 8, 25),
    status: ItemStatus.active,
    amount: 15.99,
    currency: 'USD',
    reminderOffsets: const [7, 0],
    attachmentPaths: attachments,
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory temp;
  late SqliteItemRepository repo;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('duekeep_vault_');
    repo = SqliteItemRepository(
      database: ItemDatabase(path: p.join(temp.path, 'duekeep.db')),
      attachments: AttachmentStore(root: Directory(p.join(temp.path, 'attachments'))),
    );
  });

  tearDown(() async {
    await repo.dispose();
    if (await temp.exists()) {
      await temp.delete(recursive: true);
    }
  });

  test('save and getAll survive reopening the database', () async {
    await repo.save(_item(id: 'one', vendor: 'AT&T'));
    await repo.dispose();

    repo = SqliteItemRepository(
      database: ItemDatabase(path: p.join(temp.path, 'duekeep.db')),
      attachments: AttachmentStore(root: Directory(p.join(temp.path, 'attachments'))),
    );

    final items = await repo.getAll();
    expect(items, hasLength(1));
    expect(items.single.vendor, 'AT&T');
    expect(items.single.amount, 15.99);
    expect(items.single.cycle, ItemCycle.monthly);
    expect(items.single.reminderOffsets, [7, 0]);
  });

  test('save copies attachment files into the vault folder', () async {
    final source = File(p.join(temp.path, 'bill.jpg'));
    await source.writeAsBytes(const [1, 2, 3, 9]);

    await repo.save(_item(id: 'netflix', attachments: [source.path]));
    await source.delete();

    final stored = await repo.getById('netflix');
    expect(stored, isNotNull);
    expect(stored!.attachmentPaths, hasLength(1));

    final copy = File(
      p.join(temp.path, 'attachments', stored.attachmentPaths.single),
    );
    expect(await copy.exists(), isTrue);
    expect(await copy.readAsBytes(), [1, 2, 3, 9]);
  });

  test('delete removes the row and its files', () async {
    final source = File(p.join(temp.path, 'shot.png'));
    await source.writeAsBytes(const [7, 7]);
    await repo.save(_item(id: 'gone', attachments: [source.path]));

    final stored = await repo.getById('gone');
    final relative = stored!.attachmentPaths.single;
    await repo.delete('gone');

    expect(await repo.getById('gone'), isNull);
    expect(await File(p.join(temp.path, 'attachments', relative)).exists(), isFalse);
    expect(
      await Directory(p.join(temp.path, 'attachments', 'gone')).exists(),
      isFalse,
    );
  });

  test('watchAll emits after save', () async {
    final incoming = StreamIterator(repo.watchAll());
    expect(await incoming.moveNext(), isTrue);
    expect(incoming.current, isEmpty);

    await repo.save(_item(id: 'icloud', vendor: 'iCloud+'));
    expect(await incoming.moveNext(), isTrue);
    expect(incoming.current.single.vendor, 'iCloud+');
    await incoming.cancel();
  });
}
