import '../../domain/enums/item_category.dart';
import '../../domain/enums/item_cycle.dart';
import '../../domain/enums/item_status.dart';

abstract final class ItemColumns {
  static const id = 'id';
  static const vendor = 'vendor';
  static const category = 'category';
  static const cycle = 'cycle';
  static const nextDate = 'next_date';
  static const status = 'status';
  static const amount = 'amount';
  static const currency = 'currency';
  static const reminderOffsets = 'reminder_offsets';
  static const notes = 'notes';
  static const cancelUrl = 'cancel_url';
  static const lastPaidOn = 'last_paid_on';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

abstract final class AttachmentColumns {
  static const id = 'id';
  static const itemId = 'item_id';
  static const relativePath = 'relative_path';
  static const sortOrder = 'sort_order';
}

abstract final class StorageEnums {
  static String category(ItemCategory value) => value.name;

  static ItemCategory parseCategory(String value) {
    return ItemCategory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ItemCategory.other,
    );
  }

  static String cycle(ItemCycle value) => switch (value) {
        ItemCycle.weekly => 'weekly',
        ItemCycle.monthly => 'monthly',
        ItemCycle.yearly => 'yearly',
        ItemCycle.oneTime => 'one_time',
      };

  static ItemCycle parseCycle(String value) => switch (value) {
        'weekly' => ItemCycle.weekly,
        'monthly' => ItemCycle.monthly,
        'yearly' => ItemCycle.yearly,
        'one_time' => ItemCycle.oneTime,
        _ => ItemCycle.monthly,
      };

  static String status(ItemStatus value) => value.name;

  static ItemStatus parseStatus(String value) {
    return ItemStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ItemStatus.active,
    );
  }

  static String date(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime parseDate(String value) {
    final parts = value.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
