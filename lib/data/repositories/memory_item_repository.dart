import 'dart:async';

import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';

/// In-memory vault for widget tests.
class MemoryItemRepository implements ItemRepository {
  MemoryItemRepository({Iterable<Item> seed = const []})
      : _items = {for (final item in seed) item.id: item};

  final Map<String, Item> _items;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<List<Item>> watchAll() {
    late final StreamController<List<Item>> controller;
    StreamSubscription<void>? changesSub;
    controller = StreamController<List<Item>>(
      onListen: () {
        changesSub = _changes.stream.listen((_) {
          if (!controller.isClosed) controller.add(_sorted());
        });
        controller.add(_sorted());
      },
      onCancel: () => changesSub?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<List<Item>> getAll() async => _sorted();

  @override
  Future<Item?> getById(String id) async => _items[id];

  @override
  Future<void> save(Item item) async {
    _items[item.id] = item;
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    _items.remove(id);
    _changes.add(null);
  }

  List<Item> _sorted() {
    final list = _items.values.toList();
    list.sort((a, b) {
      final byDate = a.nextDate.compareTo(b.nextDate);
      if (byDate != 0) return byDate;
      return a.vendor.toLowerCase().compareTo(b.vendor.toLowerCase());
    });
    return list;
  }
}
