import '../enums/item_category.dart';
import '../enums/item_cycle.dart';
import '../enums/item_status.dart';

/// One tracked obligation — a bill, subscription, or warranty.
///
/// Pure domain. No Flutter, no JSON, no persistence types.
class Item {
  const Item({
    required this.id,
    required this.vendor,
    required this.category,
    required this.cycle,
    required this.nextDate,
    required this.status,
    this.amount,
    this.currency,
    this.reminderOffsets = const [7],
    this.notes,
    this.cancelUrl,
    this.attachmentPaths = const [],
    this.lastPaidOn,
  });

  final String id;
  final String vendor;
  final ItemCategory category;
  final ItemCycle cycle;
  final DateTime nextDate;
  final ItemStatus status;

  /// Null for some warranties.
  final double? amount;
  final String? currency;

  /// Days before [nextDate] to fire a reminder. Default is 7.
  final List<int> reminderOffsets;
  final String? notes;
  final String? cancelUrl;
  final List<String> attachmentPaths;
  final DateTime? lastPaidOn;

  bool get isActive => status == ItemStatus.active;

  Item copyWith({
    String? id,
    String? vendor,
    ItemCategory? category,
    ItemCycle? cycle,
    DateTime? nextDate,
    ItemStatus? status,
    double? amount,
    String? currency,
    List<int>? reminderOffsets,
    String? notes,
    String? cancelUrl,
    List<String>? attachmentPaths,
    DateTime? lastPaidOn,
    bool clearAmount = false,
    bool clearCurrency = false,
    bool clearNotes = false,
    bool clearCancelUrl = false,
    bool clearLastPaidOn = false,
  }) {
    return Item(
      id: id ?? this.id,
      vendor: vendor ?? this.vendor,
      category: category ?? this.category,
      cycle: cycle ?? this.cycle,
      nextDate: nextDate ?? this.nextDate,
      status: status ?? this.status,
      amount: clearAmount ? null : amount ?? this.amount,
      currency: clearCurrency ? null : currency ?? this.currency,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      notes: clearNotes ? null : notes ?? this.notes,
      cancelUrl: clearCancelUrl ? null : cancelUrl ?? this.cancelUrl,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      lastPaidOn: clearLastPaidOn ? null : lastPaidOn ?? this.lastPaidOn,
    );
  }
}
