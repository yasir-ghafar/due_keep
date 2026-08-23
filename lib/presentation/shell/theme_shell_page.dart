import 'package:flutter/material.dart';

import '../../app/theme_controller.dart';
import '../../core/constants/brand.dart';
import '../../core/extensions/build_context_x.dart';
import '../widgets/vault_mark.dart';

/// Phase 0 shell: paper field, wordmark, one pine button, theme switch.
/// Real screens replace this in phase 1.
class ThemeShellPage extends StatelessWidget {
  const ThemeShellPage({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Scaffold(
      backgroundColor: ledger.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),
              VaultMark(size: 28, color: ledger.ink),
              const SizedBox(height: 20),
              Text(
                Brand.name,
                style: texts.headlineMedium?.copyWith(
                  letterSpacing: -0.6,
                  color: ledger.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Brand.tagline,
                style: texts.bodyLarge?.copyWith(color: ledger.mute),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Nothing due this week. That's the point."),
                      ),
                    );
                  },
                  child: const Text('Add a renewal'),
                ),
              ),
              const Spacer(flex: 4),
              _ThemeModeRow(controller: controller),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeRow extends StatelessWidget {
  const _ThemeModeRow({required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final option in ThemeMode.values) ...[
              if (option != ThemeMode.values.first)
                Text('·', style: TextStyle(color: ledger.mute)),
              _ModeLabel(
                label: _label(option),
                selected: controller.mode == option,
                onTap: () => controller.setMode(option),
              ),
            ],
          ],
        );
      },
    );
  }

  static String _label(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };
}

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          label,
          style: context.texts.bodySmall?.copyWith(
            color: selected ? ledger.ink : ledger.mute,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
