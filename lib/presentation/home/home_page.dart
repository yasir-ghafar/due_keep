import 'package:flutter/material.dart';

import '../../app/vault_scope.dart';
import '../../core/extensions/build_context_x.dart';
import '../../core/extensions/date_time_x.dart';
import '../../domain/entities/item.dart';
import '../../domain/item_schedule.dart';
import '../extensions/item_copy_x.dart';
import '../item/item_detail_page.dart';
import '../widgets/item_row.dart';
import '../widgets/page_header.dart';
import '../widgets/pine_button.dart';
import '../widgets/vault_mark.dart';
import 'home_timeline.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onAdd,
    required this.onScan,
  });

  final VoidCallback onAdd;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: VaultScope.of(context).watchAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Item>[];
        final timeline = HomeTimeline.from(items, DateTime.now());
        if (timeline.isEmpty) {
          return _EmptyHome(onAdd: onAdd);
        }
        return _PopulatedHome(
          timeline: timeline,
          onAdd: onAdd,
          onScan: onScan,
        );
      },
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          PageHeader(
            title: 'Upcoming',
            subtitle: DateTime.now().weekdayDayMonth,
            trailing: const BellButton(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
              child: Column(
                children: [
                  Opacity(
                    opacity: 0.55,
                    child: VaultMark(size: 48, color: ledger.ink),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nothing due this week. That’s the point.',
                    style: texts.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ledger.ink,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a bill, subscription, or warranty. We’ll keep the date.',
                    style: texts.bodySmall?.copyWith(
                      fontSize: 13,
                      height: 1.45,
                      color: ledger.mute,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PineButton(
                    label: 'Add your first renewal',
                    onPressed: onAdd,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopulatedHome extends StatelessWidget {
  const _PopulatedHome({
    required this.timeline,
    required this.onAdd,
    required this.onScan,
  });

  final HomeTimeline timeline;
  final VoidCallback onAdd;
  final VoidCallback onScan;

  Future<void> _openItem(BuildContext context, Item item) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemDetailPage(itemId: item.id, backLabel: 'Upcoming'),
      ),
    );
  }

  Future<void> _markNextPaid(BuildContext context) async {
    final next = timeline.next;
    if (next == null) return;
    final repo = VaultScope.of(context);
    await repo.save(markItemPaid(next, DateTime.now()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked ${next.vendor} paid.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repo.save(next),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final next = timeline.next!;
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      children: [
        PageHeader(
          title: 'Upcoming',
          subtitle: now.weekdayDayMonth,
          trailing: const BellButton(),
        ),
        _HeroCard(timeline: timeline, next: next, now: now),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.add,
                label: 'Add',
                onTap: onAdd,
              ),
            ),
            Expanded(
              child: _QuickAction(
                icon: Icons.photo_camera_outlined,
                label: 'Scan',
                onTap: onScan,
              ),
            ),
            Expanded(
              child: _QuickAction(
                icon: Icons.check,
                label: 'Mark paid',
                onTap: () => _markNextPaid(context),
              ),
            ),
          ],
        ),
        if (timeline.overdue.isNotEmpty) ...[
          const _SectionLabel('Overdue'),
          for (final item in timeline.overdue)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ItemRow(
                item: item,
                meta: item.homeMeta,
                onTap: () => _openItem(context, item),
              ),
            ),
        ],
        if (timeline.thisWeek.isNotEmpty) ...[
          const _SectionLabel('This week'),
          for (final item in timeline.thisWeek)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ItemRow(
                item: item,
                meta: item.homeMeta,
                onTap: () => _openItem(context, item),
              ),
            ),
        ],
        if (timeline.later.isNotEmpty) ...[
          const _SectionLabel('Later'),
          for (final item in timeline.later)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ItemRow(
                item: item,
                meta: item.homeMeta,
                onTap: () => _openItem(context, item),
              ),
            ),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.timeline,
    required this.next,
    required this.now,
  });

  final HomeTimeline timeline;
  final Item next;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final count = timeline.dueThisWeekCount;
    final soonEmpty = count == 0 && timeline.dueIn30Days == 0;
    final kicker = soonEmpty
        ? 'Nothing due soon'
        : count == 0
            ? 'Nothing due this week'
            : count == 1
                ? '1 due this week'
                : '$count due this week';
    final headline = soonEmpty
        ? 'Next is ${next.vendor}'
        : '\$${timeline.dueIn30Days.toStringAsFixed(0)} due in 30 days';
    final sub = soonEmpty
        ? next.relativeDue(now)
        : 'Next is ${next.vendor} — ${next.relativeDue(now)}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            color: ledger.pine,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ledger.onPine.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  headline,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.84,
                    color: ledger.onPine,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 15,
                    color: ledger.onPine.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -12,
            top: -18,
            child: Transform.rotate(
              angle: 0.314,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: ledger.onPine.withValues(alpha: 0.08),
                    width: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ledger.pineSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: ledger.ink),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ledger.mute,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: context.texts.bodySmall?.copyWith(
          fontSize: 12,
          letterSpacing: 0.96,
          fontWeight: FontWeight.w600,
          color: context.ledger.mute,
        ),
      ),
    );
  }
}
