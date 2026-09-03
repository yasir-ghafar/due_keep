import 'package:flutter/material.dart';

import '../../core/extensions/build_context_x.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: texts.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.84,
                    color: ledger.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: texts.bodySmall?.copyWith(
                    fontSize: 13,
                    color: ledger.mute,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class BellButton extends StatelessWidget {
  const BellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return Container(
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
    );
  }
}
