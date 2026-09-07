import 'package:flutter/material.dart';

import '../../core/constants/brand.dart';
import '../../core/extensions/build_context_x.dart';
import '../widgets/pine_button.dart';

/// Free-cap / Pro gate. Purchases are stubbed until StoreKit / Play Billing.
class PaywallPage extends StatelessWidget {
  const PaywallPage({
    super.key,
    this.headline = 'Keep every due date — without a cap',
    this.body =
        'You’ve reached the free limit of 5 active items. Pro unlocks unlimited items, scan, the home widget, and export.',
  });

  final String headline;
  final String body;

  static Future<void> open(
    BuildContext context, {
    String? headline,
    String? body,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaywallPage(
          headline: headline ?? 'Keep every due date — without a cap',
          body: body ??
              'You’ve reached the free limit of 5 active items. Pro unlocks unlimited items, scan, the home widget, and export.',
        ),
      ),
    );
  }

  void _stub(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Scaffold(
      backgroundColor: ledger.paper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: ledger.pine,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Not now'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    headline,
                    style: texts.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.84,
                      height: 1.2,
                      color: ledger.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    body,
                    style: texts.bodySmall?.copyWith(
                      fontSize: 13,
                      height: 1.45,
                      color: ledger.mute,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PlanCard(
                    name: 'Yearly · featured',
                    price: '\$24.99 / year',
                    hint: '7 days of Pro, then \$24.99/year. Cancel anytime.',
                    featured: true,
                  ),
                  const SizedBox(height: 10),
                  _PlanCard(
                    name: 'Monthly',
                    price: '\$3.99 / month',
                    hint: 'Same features, billed monthly',
                    featured: false,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final line in const [
                          'Unlimited items',
                          'Scan documents',
                          'Home-screen widget',
                          'Export CSV',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '·  $line',
                              style: texts.bodySmall?.copyWith(
                                fontSize: 13,
                                height: 1.5,
                                color: ledger.mute,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  PineButton(
                    label: 'Start 7-day trial',
                    onPressed: () => _stub(
                      context,
                      'Purchases come later. ${Brand.name} Pro isn’t wired yet.',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _stub(
                      context,
                      'Nothing to restore yet.',
                    ),
                    child: Text(
                      'Restore purchases',
                      style: TextStyle(color: ledger.mute),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.hint,
    required this.featured,
  });

  final String name;
  final String price;
  final String hint;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final on = featured ? ledger.onPine : ledger.ink;
    final mute = featured
        ? ledger.onPine.withValues(alpha: 0.8)
        : ledger.mute;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: featured ? ledger.pine : ledger.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: featured ? Colors.transparent : ledger.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: mute,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.44,
              color: on,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: TextStyle(fontSize: 13, color: mute),
          ),
        ],
      ),
    );
  }
}
