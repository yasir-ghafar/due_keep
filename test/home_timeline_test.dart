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
      displayCurrency: 'USD',
    );

    expect(timeline.overdue.map((item) => item.vendor), ['Netflix']);
    expect(timeline.thisWeek.map((item) => item.vendor), ['AT&T']);
    expect(timeline.later.map((item) => item.vendor), ['Framework laptop']);
    expect(timeline.dueThisWeekCount, 2);
    expect(timeline.dueIn30Days, 57.99);
    expect(timeline.next?.vendor, 'Netflix');
  });

  test('30-day total only includes the display currency', () {
    final timeline = HomeTimeline.from(
      [
        Item(
          id: 'usd',
          vendor: 'Netflix',
          category: ItemCategory.subscription,
          cycle: ItemCycle.monthly,
          nextDate: DateTime(2026, 9, 10),
          status: ItemStatus.active,
          amount: 15.99,
          currency: 'USD',
        ),
        Item(
          id: 'eur',
          vendor: 'EU Gym',
          category: ItemCategory.subscription,
          cycle: ItemCycle.monthly,
          nextDate: DateTime(2026, 9, 12),
          status: ItemStatus.active,
          amount: 40,
          currency: 'EUR',
        ),
      ],
      now,
      displayCurrency: 'USD',
    );

    expect(timeline.dueIn30Days, 15.99);
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

  test('isDueInFutureMonth is false for current and past months', () {
    expect(
      isDueInFutureMonth(
        _item(id: 'a', vendor: 'A', nextDate: DateTime(2026, 8, 30)),
        now,
      ),
      isFalse,
    );
    expect(
      isDueInFutureMonth(
        _item(id: 'b', vendor: 'B', nextDate: DateTime(2026, 7, 15)),
        now,
      ),
      isFalse,
    );
    expect(
      isDueInFutureMonth(
        _item(id: 'c', vendor: 'C', nextDate: DateTime(2026, 9, 1)),
        now,
      ),
      isTrue,
    );
  });
}
