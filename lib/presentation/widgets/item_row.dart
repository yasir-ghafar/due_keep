import 'package:flutter/material.dart';

import '../../core/extensions/build_context_x.dart';
import '../../domain/entities/item.dart';
import '../extensions/item_category_x.dart';
import '../extensions/item_copy_x.dart';

class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.item,
    required this.meta,
    this.shortOverdue = false,
    this.onTap,
  });

  final Item item;
  final String meta;
  final bool shortOverdue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;
    final now = DateTime.now();
    final tone = item.dueTone(now);
    final whenColor = switch (tone) {
      DueTone.late => ledger.clay,
      DueTone.soon => ledger.amber,
      DueTone.ok => ledger.mute,
    };
    final money = item.moneyLabel;

    return Material(
      color: ledger.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: ledger.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.category.accent(ledger),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.vendor,
                      style: texts.titleMedium?.copyWith(
                        fontSize: 16,
                        letterSpacing: -0.16,
                        color: ledger.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      style: texts.bodySmall?.copyWith(
                        fontSize: 13,
                        color: ledger.mute,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (money != null)
                    Text(
                      money,
                      style: texts.titleMedium?.copyWith(
                        fontSize: 16,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: ledger.ink,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: money == null ? 0 : 3),
                    child: Text(
                      item.relativeDue(now, shortOverdue: shortOverdue),
                      style: texts.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight:
                            tone == DueTone.ok ? FontWeight.w500 : FontWeight.w600,
                        color: whenColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
