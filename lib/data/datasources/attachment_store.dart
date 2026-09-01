import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies bill/receipt photos into the app documents folder.
/// SQLite stores relative paths only.
class AttachmentStore {
  AttachmentStore({Directory? root}) : _rootOverride = root;

  final Directory? _rootOverride;

  Future<Directory> ensureReady() async => root();

  Future<Directory> root() async {
    final override = _rootOverride;
    if (override != null) {
      if (!await override.exists()) {
        await override.create(recursive: true);
      }
      return override;
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'duekeep', 'attachments'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// True when [path] is already a file inside the attachments root.
  Future<bool> isStored(String path) async {
    if (p.isAbsolute(path)) {
      final rootDir = await root();
      return p.isWithin(rootDir.path, path) && await File(path).exists();
    }
    final file = await resolve(path);
    return file.exists();
  }

  Future<String> toRelative(String path) async {
    if (!p.isAbsolute(path)) return path.replaceAll(r'\', '/');
    final rootDir = await root();
    return p.relative(path, from: rootDir.path).replaceAll(r'\', '/');
  }

  /// Copies [sourcePath] next to this item. Returns a relative path.
  Future<String> import({
    required String itemId,
    required String sourcePath,
  }) async {
    final rootDir = await root();
    final ext = p.extension(sourcePath);
    final name = '${DateTime.now().toUtc().microsecondsSinceEpoch}$ext';
    final relative = '$itemId/$name';
    final dest = File(p.join(rootDir.path, itemId, name));
    await dest.parent.create(recursive: true);
    await File(sourcePath).copy(dest.path);
    return relative;
  }

  Future<File> resolve(String relativePath) async {
    final rootDir = await root();
    return File(p.join(rootDir.path, relativePath));
  }

  Future<void> deleteRelative(String relativePath) async {
    final file = await resolve(relativePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteItem(String itemId) async {
    final rootDir = await root();
    final dir = Directory(p.join(rootDir.path, itemId));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
