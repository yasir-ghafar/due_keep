import 'package:flutter/material.dart';

import '../../app/theme_controller.dart';
import '../../core/extensions/build_context_x.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.themeController});

  final ThemeController themeController;

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
            'Settings',
            style: texts.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.84,
              color: ledger.ink,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Preferences',
            style: texts.labelSmall?.copyWith(
              fontSize: 12,
              letterSpacing: 0.96,
              fontWeight: FontWeight.w600,
              color: ledger.mute,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: ledger.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ledger.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: texts.bodyLarge?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                _ThemeModeRow(controller: themeController),
              ],
            ),
          ),
        ],
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
