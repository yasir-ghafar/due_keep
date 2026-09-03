import 'package:flutter/material.dart';

import '../../app/vault_scope.dart';
import '../../core/extensions/build_context_x.dart';
import '../../core/extensions/date_time_x.dart';
import '../../domain/entities/item.dart';
import '../../domain/enums/item_status.dart';
import '../../domain/item_schedule.dart';
import '../extensions/item_category_x.dart';
import '../extensions/item_copy_x.dart';
import '../widgets/pine_button.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({
    super.key,
    required this.itemId,
    required this.backLabel,
  });

  final String itemId;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: VaultScope.of(context).watchAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Item>[];
        Item? match;
        for (final item in items) {
          if (item.id == itemId) {
            match = item;
            break;
          }
        }
        if (match == null) {
          return Scaffold(
            backgroundColor: context.ledger.paper,
            body: const Center(child: Text('That item is not in the vault.')),
          );
        }
        return _DetailBody(item: match, backLabel: backLabel);
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item, required this.backLabel});

  final Item item;
  final String backLabel;

  /// Never marked paid, or already cancelled — safe to clear from the vault.
  bool get _canDelete =>
      item.lastPaidOn == null || item.status == ItemStatus.cancelled;

  String get _deleteCopy {
    if (item.status == ItemStatus.cancelled) {
      return 'This permanently removes the cancelled item from the vault.';
    }
    return 'This removes it from the vault. You can only delete items that have never been marked paid.';
  }

  Future<void> _save(BuildContext context, Item next) {
    return VaultScope.of(context).save(next);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.ledger.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final ledger = ctx.ledger;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ledger.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delete ${item.vendor}?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: ledger.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _deleteCopy,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: ledger.mute,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: ledger.clay,
                      foregroundColor: ledger.paper,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Delete item'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'Keep it',
                      style: TextStyle(color: ledger.mute),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await VaultScope.of(context).delete(item.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;
    final now = DateTime.now();
    final overdue = daysUntilDue(item, now) < 0;
    final money = item.moneyLabel;
    final active = item.status == ItemStatus.active;
    final paused = item.status == ItemStatus.paused;

    return Scaffold(
      backgroundColor: ledger.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, size: 18, color: ledger.pine),
                    const SizedBox(width: 6),
                    Text(
                      backLabel,
                      style: texts.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ledger.pine,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.category.accent(ledger),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(item.category.label),
                    ],
                  ),
                ),
                if (overdue && active)
                  _Chip(
                    background: ledger.clay.withValues(alpha: 0.16),
                    foreground: ledger.clay,
                    child: const Text('Overdue'),
                  ),
                if (!active) _Chip(child: Text(item.status.label)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.vendor,
              style: texts.headlineMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.84,
                color: ledger.ink,
              ),
            ),
            if (money != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  money,
                  style: texts.headlineMedium?.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.84,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: ledger.ink,
                  ),
                ),
              ),
            Text(
              '${item.cycle.label} · due ${item.nextDate.dayMonthYear}',
              style: texts.bodyLarge?.copyWith(
                fontSize: 15,
                color: ledger.mute,
              ),
            ),
            const SizedBox(height: 20),
            _InfoCard(
              label: 'Next date',
              value: item.nextDate.dayMonthYear,
              trailing: item.relativeDue(now),
              trailingColor: overdue && active ? ledger.clay : ledger.mute,
            ),
            const SizedBox(height: 8),
            const _InfoCard(
              label: 'Remind',
              value: '7 days before, 9:00',
            ),
            if (active) ...[
              const SizedBox(height: 24),
              PineButton(
                label: 'Mark paid',
                onPressed: () async {
                  final previous = item;
                  await _save(context, markItemPaid(item, DateTime.now()));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Marked ${item.vendor} paid.'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => _save(context, previous),
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _save(
                        context,
                        item.copyWith(status: ItemStatus.paused),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Pause'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _save(
                        context,
                        item.copyWith(status: ItemStatus.cancelled),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
            if (paused) ...[
              const SizedBox(height: 24),
              PineButton(
                label: 'Resume',
                onPressed: () => _save(
                  context,
                  item.copyWith(status: ItemStatus.active),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _save(
                  context,
                  item.copyWith(status: ItemStatus.cancelled),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Cancel this item'),
              ),
            ],
            if (_canDelete) ...[
              SizedBox(height: active || paused ? 8 : 24),
              TextButton(
                onPressed: () => _delete(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: ledger.mute,
                ),
                child: const Text('Delete this item'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.child,
    this.background,
    this.foreground,
  });

  final Widget child;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? ledger.pineSoft,
        borderRadius: BorderRadius.circular(40),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground ?? ledger.ink,
        ),
        child: child,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    this.trailing,
    this.trailingColor,
  });

  final String label;
  final String value;
  final String? trailing;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ledger.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ledger.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: ledger.mute),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ledger.ink,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: trailingColor ?? ledger.mute,
              ),
            ),
        ],
      ),
    );
  }
}
