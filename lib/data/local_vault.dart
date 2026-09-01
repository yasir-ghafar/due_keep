import '../domain/repositories/item_repository.dart';
import 'datasources/attachment_store.dart';
import 'datasources/item_database.dart';
import 'repositories/sqlite_item_repository.dart';

/// Opens the on-device SQLite vault and attachment folder.
abstract final class LocalVault {
  static Future<ItemRepository> open() async {
    final database = ItemDatabase();
    await database.instance;
    final attachments = AttachmentStore();
    await attachments.ensureReady();
    return SqliteItemRepository(
      database: database,
      attachments: attachments,
    );
  }
}
