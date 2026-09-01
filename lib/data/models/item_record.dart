import 'dart:convert';

import '../../domain/entities/item.dart';
import 'item_storage.dart';

abstract final class ItemRecord {
  static Map<String, Object?> toRow(
    Item item, {
    required String createdAt,
    required String updatedAt,
  }) {
    return {
      ItemColumns.id: item.id,
      ItemColumns.vendor: item.vendor,
      ItemColumns.category: StorageEnums.category(item.category),
      ItemColumns.cycle: StorageEnums.cycle(item.cycle),
      ItemColumns.nextDate: StorageEnums.date(item.nextDate),
      ItemColumns.status: StorageEnums.status(item.status),
      ItemColumns.amount: item.amount,
      ItemColumns.currency: item.currency,
      ItemColumns.reminderOffsets: jsonEncode(item.reminderOffsets),
      ItemColumns.notes: item.notes,
      ItemColumns.cancelUrl: item.cancelUrl,
      ItemColumns.lastPaidOn:
          item.lastPaidOn == null ? null : StorageEnums.date(item.lastPaidOn!),
      ItemColumns.createdAt: createdAt,
      ItemColumns.updatedAt: updatedAt,
    };
  }

  static Item fromRow(
    Map<String, Object?> row, {
    List<String> attachmentPaths = const [],
  }) {
    final offsetsRaw = row[ItemColumns.reminderOffsets] as String? ?? '[7]';
    final decoded = jsonDecode(offsetsRaw);
    final offsets = decoded is List
        ? decoded.map((value) => (value as num).toInt()).toList()
        : const [7];

    final lastPaid = row[ItemColumns.lastPaidOn] as String?;

    return Item(
      id: row[ItemColumns.id]! as String,
      vendor: row[ItemColumns.vendor]! as String,
      category: StorageEnums.parseCategory(row[ItemColumns.category]! as String),
      cycle: StorageEnums.parseCycle(row[ItemColumns.cycle]! as String),
      nextDate: StorageEnums.parseDate(row[ItemColumns.nextDate]! as String),
      status: StorageEnums.parseStatus(row[ItemColumns.status]! as String),
      amount: (row[ItemColumns.amount] as num?)?.toDouble(),
      currency: row[ItemColumns.currency] as String?,
      reminderOffsets: offsets,
      notes: row[ItemColumns.notes] as String?,
      cancelUrl: row[ItemColumns.cancelUrl] as String?,
      attachmentPaths: attachmentPaths,
      lastPaidOn: lastPaid == null ? null : StorageEnums.parseDate(lastPaid),
    );
  }
}
