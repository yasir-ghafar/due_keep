import 'package:flutter/material.dart';

import '../../app/vault_scope.dart';
import '../../core/extensions/build_context_x.dart';
import '../../core/extensions/date_time_x.dart';
import '../../domain/entities/item.dart';
import '../../domain/item_schedule.dart';
import '../widgets/pine_button.dart';

/// Marks [item] paid. Current-month (and overdue) dues apply immediately.
/// A due date in a later month opens a confirm sheet first.
Future<bool> markItemPaidFlow(
  BuildContext context,
  Item item, {
  bool popAfter = false,
}) async {
  final now = DateTime.now();
  final repo = VaultScope.of(context);

  if (isDueInFutureMonth(item, now)) {
    final confirmed = await MarkPaidConfirmSheet.show(context, item: item);
    if (confirmed != true) return false;
    if (!context.mounted) return false;
  }

  await repo.save(markItemPaid(item, now));
  if (!context.mounted) return true;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Marked ${item.vendor} paid.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => repo.save(item),
      ),
      duration: const Duration(seconds: 5),
    ),
  );

  if (popAfter && context.mounted) {
    Navigator.of(context).pop();
  }
  return true;
}

/// Confirm paying a period that falls after the current calendar month.
class MarkPaidConfirmSheet extends StatelessWidget {
  const MarkPaidConfirmSheet({super.key, required this.item});

  final Item item;

  static Future<bool?> show(
    BuildContext context, {
    required Item item,
  }) {
    final ledger = context.ledger;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: ledger.ink.withValues(alpha: 0.36),
      builder: (_) => MarkPaidConfirmSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;
    final period = item.nextDate.monthYear;
    final rolled = markItemPaid(item, DateTime.now());

    return Material(
      color: ledger.card,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mark paid for $period?',
                style: texts.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: ledger.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.vendor} is due ${item.nextDate.dayMonthYear} — '
                'after this month. Confirm to mark that period paid'
                '${rolled.status == item.status ? ' and move next due to ${rolled.nextDate.dayMonthYear}' : ''}.',
                style: texts.bodySmall?.copyWith(
                  fontSize: 14,
                  height: 1.45,
                  color: ledger.mute,
                ),
              ),
              const SizedBox(height: 24),
              PineButton(
                label: 'Mark paid',
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Not now',
                    style: TextStyle(color: ledger.mute),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
