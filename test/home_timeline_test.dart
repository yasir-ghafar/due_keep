import 'package:due_keep/domain/entities/item.dart';
import 'package:due_keep/domain/enums/item_category.dart';
import 'package:due_keep/domain/enums/item_cycle.dart';
import 'package:due_keep/domain/enums/item_status.dart';
import 'package:due_keep/domain/item_schedule.dart';
import 'package:due_keep/presentation/home/home_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

Item _item({
  required String id,
  required String vendor,
  required DateTime nextDate,
  ItemCategory category = ItemCategory.subscription,
  ItemCycle cycle = ItemCycle.monthly,
  ItemStatus status = ItemStatus.active,
  double? amount = 10,
}) {
  return Item(
    id: id,
    vendor: vendor,
    category: category,
    cycle: cycle,
    nextDate: nextDate,
    status: status,
    amount: amount,
  );
}

void main() {
  final now = DateTime(2026, 8, 27);

  test('groups active items and sums amounts due within 30 days', () {
    final timeline = HomeTimeline.from(
      [
        _item(
          id: 'late',
          vendor: 'Netflix',
          nextDate: DateTime(2026, 8, 25),
          amount: 15.99,
        ),
        _item(
          id: 'week',
          vendor: 'AT&T',
          category: ItemCategory.bill,
          nextDate: DateTime(2026, 8, 30),
          amount: 42,
        ),
        _item(
          id: 'later',
          vendor: 'Framework laptop',
          category: ItemCategory.warranty,
          cycle: ItemCycle.oneTime,
          nextDate: DateTime(2026, 10, 7),
          amount: null,
        ),
        _item(
          id: 'paused',
          vendor: 'Spotify',
          nextDate: DateTime(2026, 8, 28),
          status: ItemStatus.paused,
          amount: 10.99,
        ),
      ],
      now,
    );

    expect(timeline.overdue.map((item) => item.vendor), ['Netflix']);
    expect(timeline.thisWeek.map((item) => item.vendor), ['AT&T']);
    expect(timeline.later.map((item) => item.vendor), ['Framework laptop']);
    expect(timeline.dueThisWeekCount, 2);
    expect(timeline.dueIn30Days, 57.99);
    expect(timeline.next?.vendor, 'Netflix');
  });

  test('markItemPaid rolls a monthly item and completes a warranty', () {
    final monthly = _item(
      id: 'netflix',
      vendor: 'Netflix',
      nextDate: DateTime(2026, 8, 25),
    );
    final rolled = markItemPaid(monthly, now);
    expect(rolled.status, ItemStatus.active);
    expect(rolled.nextDate, DateTime(2026, 9, 25));
    expect(rolled.lastPaidOn, DateTime(2026, 8, 27));

    final warranty = _item(
      id: 'fw',
      vendor: 'Framework laptop',
      category: ItemCategory.warranty,
      cycle: ItemCycle.oneTime,
      nextDate: DateTime(2026, 10, 7),
      amount: null,
    );
    final done = markItemPaid(warranty, now);
    expect(done.status, ItemStatus.completed);
    expect(done.nextDate, warranty.nextDate);
  });
}
