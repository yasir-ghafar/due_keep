import '../../domain/entities/item.dart';
import '../../domain/enums/item_category.dart';
import '../../domain/enums/item_cycle.dart';
import '../../domain/enums/item_status.dart';
import '../../domain/item_schedule.dart';

extension ItemCategoryLabel on ItemCategory {
  String get label => switch (this) {
        ItemCategory.subscription => 'Subscription',
        ItemCategory.bill => 'Bill',
        ItemCategory.warranty => 'Warranty',
        ItemCategory.other => 'Other',
      };
}

extension ItemCycleLabel on ItemCycle {
  String get label => switch (this) {
        ItemCycle.weekly => 'Weekly',
        ItemCycle.monthly => 'Monthly',
        ItemCycle.yearly => 'Yearly',
        ItemCycle.oneTime => 'One-time',
      };
}

extension ItemStatusLabel on ItemStatus {
  String get label => switch (this) {
        ItemStatus.active => 'Active',
        ItemStatus.paused => 'Paused',
        ItemStatus.cancelled => 'Cancelled',
        ItemStatus.completed => 'Completed',
      };
}

enum DueTone { late, soon, ok }

extension ItemDueCopy on Item {
  String get homeMeta {
    if (category == ItemCategory.warranty) {
      return 'Warranty · coverage ends';
    }
    return '${category.label} · ${cycle.label.toLowerCase()}';
  }

  String get vaultMeta {
    if (status == ItemStatus.active && category == ItemCategory.warranty) {
      return 'Active · warranty';
    }
    return status.label;
  }

  String? get moneyLabel {
    if (amount == null) return null;
    final value = amount!.toStringAsFixed(2);
    if (currency == null || currency == 'USD') return '\$$value';
    return '$value $currency';
  }

  DueTone dueTone(DateTime now) {
    final days = daysUntilDue(this, now);
    if (days < 0) return DueTone.late;
    if (days <= 6) return DueTone.soon;
    return DueTone.ok;
  }

  String relativeDue(DateTime now, {bool shortOverdue = false}) {
    final days = daysUntilDue(this, now);
    if (days < 0) {
      if (shortOverdue) return 'overdue';
      final n = -days;
      return n == 1 ? 'overdue 1 day' : 'overdue $n days';
    }
    if (days == 0) return 'due today';
    if (days == 1) return 'in 1 day';
    return 'in $days days';
  }
}
