import 'dart:math';

abstract final class ItemIds {
  static final _random = Random.secure();

  /// Local unique id. Not a network identifier.
  static String create() {
    final time = DateTime.now().toUtc().microsecondsSinceEpoch.toRadixString(16);
    final salt = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return '$time$salt';
  }
}
