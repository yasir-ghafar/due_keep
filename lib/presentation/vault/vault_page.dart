import 'package:flutter/material.dart';

import '../../core/extensions/build_context_x.dart';

/// Vault tab placeholder until items exist.
class VaultPage extends StatelessWidget {
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vault',
            style: texts.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.84,
              color: ledger.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '0 items',
            style: texts.bodySmall?.copyWith(
              fontSize: 13,
              color: ledger.mute,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Nothing stored yet.',
            style: texts.titleMedium?.copyWith(color: ledger.ink),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a renewal from Home. It will live here.',
            style: texts.bodySmall?.copyWith(
              fontSize: 13,
              height: 1.45,
              color: ledger.mute,
            ),
          ),
        ],
      ),
    );
  }
}
