import 'package:flutter/material.dart';

import '../../core/constants/brand.dart';
import '../../core/extensions/build_context_x.dart';
import '../widgets/vault_mark.dart';

/// Cold-start brand screen. Paper field, vault mark, wordmark, one line.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const displayDuration = Duration(milliseconds: 1200);

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Scaffold(
      backgroundColor: ledger.paper,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VaultMark(size: 48, color: ledger.ink),
              const SizedBox(height: 16),
              Text(
                Brand.name,
                style: texts.headlineMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.96,
                  height: 1.15,
                  color: ledger.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Brand.tagline,
                style: texts.bodyLarge?.copyWith(
                  fontSize: 17,
                  color: ledger.mute,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
