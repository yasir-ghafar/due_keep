import '../entities/item.dart';

/// Contract for the vault. Implemented in the data layer.
abstract class ItemRepository {
  Stream<List<Item>> watchAll();

  Future<List<Item>> getAll();

  Future<Item?> getById(String id);

  Future<void> save(Item item);

  Future<void> delete(String id);
}
