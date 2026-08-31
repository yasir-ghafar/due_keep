import 'package:flutter/material.dart';

import '../../core/extensions/build_context_x.dart';
import '../../core/extensions/date_time_x.dart';
import '../widgets/pine_button.dart';
import '../widgets/vault_mark.dart';

/// Home with zero items. CTA opens the add-method sheet.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming',
                      style: texts.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.84,
                        color: ledger.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      today.weekdayDayMonth,
                      style: texts.bodySmall?.copyWith(
                        fontSize: 13,
                        color: ledger.mute,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ledger.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: ledger.line),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 18,
                  color: ledger.ink,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 72, 16, 0),
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
