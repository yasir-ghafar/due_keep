import '../../domain/entities/item.dart';
import '../../domain/enums/item_status.dart';
import '../../domain/item_schedule.dart';

class HomeTimeline {
  const HomeTimeline({
    required this.overdue,
    required this.thisWeek,
    required this.later,
    required this.dueIn30Days,
  });

  factory HomeTimeline.from(List<Item> items, DateTime now) {
    final active = items.where((item) => item.status == ItemStatus.active).toList()
      ..sort((a, b) {
        final byDate = a.nextDate.compareTo(b.nextDate);
        if (byDate != 0) return byDate;
        return a.vendor.toLowerCase().compareTo(b.vendor.toLowerCase());
      });

    final overdue = <Item>[];
    final thisWeek = <Item>[];
    final later = <Item>[];
    var dueIn30Days = 0.0;

    for (final item in active) {
      final days = daysUntilDue(item, now);
      if (days < 0) {
        overdue.add(item);
      } else if (days <= 6) {
        thisWeek.add(item);
      } else {
        later.add(item);
      }
      if (days <= 30 && item.amount != null) {
        dueIn30Days += item.amount!;
      }
    }

    return HomeTimeline(
      overdue: overdue,
      thisWeek: thisWeek,
      later: later,
      dueIn30Days: dueIn30Days,
    );
  }

  final List<Item> overdue;
  final List<Item> thisWeek;
  final List<Item> later;
  final double dueIn30Days;

  bool get isEmpty =>
      overdue.isEmpty && thisWeek.isEmpty && later.isEmpty;

  int get dueThisWeekCount => overdue.length + thisWeek.length;

  Item? get next {
    if (overdue.isNotEmpty) return overdue.first;
    if (thisWeek.isNotEmpty) return thisWeek.first;
    if (later.isNotEmpty) return later.first;
    return null;
  }
}
