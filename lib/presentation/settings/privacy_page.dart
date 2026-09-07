import 'package:flutter/material.dart';

import '../../core/constants/brand.dart';
import '../../core/extensions/build_context_x.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Scaffold(
      backgroundColor: ledger.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
                child: const Text('Settings'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Privacy',
              style: texts.headlineMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.84,
                color: ledger.ink,
              ),
            ),
            const SizedBox(height: 16),
            for (final block in const [
              (
                'No account',
                'DueKeep does not ask for email or a login. There is nothing to sync to a cloud profile.',
              ),
              (
                'On your device',
                'Bills, subscriptions, and warranties live in a local vault on this phone. Attachments stay in the app folder.',
              ),
              (
                'No bank login',
                'We never connect to your bank, Gmail, or SMS. You type a renewal in — or scan a bill you already have.',
              ),
              (
                'Notifications',
                'Reminders are local. If you allow them, the OS delivers them; we do not send them through a server.',
              ),
            ]) ...[
              Text(
                block.$1,
                style: texts.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ledger.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                block.$2,
                style: texts.bodyLarge?.copyWith(
                  fontSize: 15,
                  height: 1.45,
                  color: ledger.mute,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              Brand.longerLine,
              style: texts.bodySmall?.copyWith(
                fontSize: 13,
                height: 1.45,
                color: ledger.mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnDevicePage extends StatelessWidget {
  const OnDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Scaffold(
      backgroundColor: ledger.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
                child: const Text('Settings'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This stays on your phone',
              style: texts.headlineMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.84,
                color: ledger.ink,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your vault is private by design. Due dates, amounts, and receipts are stored on this device — not on our servers, because we do not run a cloud vault in v1.',
              style: texts.bodyLarge?.copyWith(
                fontSize: 15,
                height: 1.45,
                color: ledger.mute,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'If you uninstall the app, that local data goes with it. Export (Pro) is how you take a CSV copy with you.',
              style: texts.bodyLarge?.copyWith(
                fontSize: 15,
                height: 1.45,
                color: ledger.mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
