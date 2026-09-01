import 'package:flutter/material.dart';

import '../domain/repositories/item_repository.dart';

class VaultScope extends InheritedWidget {
  const VaultScope({
    super.key,
    required this.items,
    required super.child,
  });

  final ItemRepository items;

  static ItemRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VaultScope>();
    assert(scope != null, 'VaultScope is missing.');
    return scope!.items;
  }

  @override
  bool updateShouldNotify(VaultScope oldWidget) => items != oldWidget.items;
}
