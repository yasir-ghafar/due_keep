import 'entities/item.dart';
import 'enums/item_category.dart';
import 'enums/item_cycle.dart';
import 'enums/item_status.dart';

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int daysUntilDue(Item item, DateTime now) =>
    dateOnly(item.nextDate).difference(dateOnly(now)).inDays;

/// True when [item.nextDate] falls in a calendar month after [now].
///
/// Mark paid applies immediately for the current month (and overdue earlier
/// months). Paying a future month needs an explicit confirm.
bool isDueInFutureMonth(Item item, DateTime now) {
  final due = dateOnly(item.nextDate);
  final today = dateOnly(now);
  return due.year > today.year ||
      (due.year == today.year && due.month > today.month);
}

DateTime advanceCycle(DateTime date, ItemCycle cycle) {
  return switch (cycle) {
    ItemCycle.weekly => date.add(const Duration(days: 7)),
    ItemCycle.monthly => DateTime(date.year, date.month + 1, date.day),
    ItemCycle.yearly => DateTime(date.year + 1, date.month, date.day),
    ItemCycle.oneTime => date,
  };
}

/// Repeating items roll forward. One-time and warranties complete.
Item markItemPaid(Item item, DateTime today) {
  final paidOn = dateOnly(today);
  if (item.cycle == ItemCycle.oneTime ||
      item.category == ItemCategory.warranty) {
    return item.copyWith(
      status: ItemStatus.completed,
      lastPaidOn: paidOn,
    );
  }
  return item.copyWith(
    lastPaidOn: paidOn,
    nextDate: advanceCycle(item.nextDate, item.cycle),
  );
}
