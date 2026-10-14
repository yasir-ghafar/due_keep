import 'package:flutter/material.dart';

import '../../app/settings_controller.dart';
import '../../app/theme_controller.dart';
import '../../app/theme_reveal_scope.dart';
import '../../app/vault_scope.dart';
import '../../core/constants/brand.dart';
import '../../core/constants/free_limits.dart';
import '../../core/currency/currency_format.dart';
import '../../core/extensions/build_context_x.dart';
import '../../core/theme/ledger_motion.dart';
import '../../domain/entities/item.dart';
import '../../domain/enums/item_status.dart';
import 'paywall_page.dart';
import 'privacy_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.themeController,
    required this.settingsController,
  });

  final ThemeController themeController;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
        const SizedBox(height: 18),
        const _ProRow(),
        const SizedBox(height: 18),
        const _SectionLabel('Preferences'),
        const SizedBox(height: 8),
        _SettingsGroup(
          children: [
            ListenableBuilder(
              listenable: themeController,
              builder: (context, _) {
                return _AppearanceBlock(controller: themeController);
              },
            ),
            ListenableBuilder(
              listenable: settingsController,
              builder: (context, _) {
                return _SettingsRow(
                  label: 'Default reminder',
                  value: settingsController.reminderTime.hhmm,
                  onTap: () => _pickReminder(context, settingsController),
                );
              },
            ),
            ListenableBuilder(
              listenable: settingsController,
              builder: (context, _) {
                final code = settingsController.currency;
                return _SettingsRow(
                  label: 'Currency',
                  value: '$code · ${CurrencyFormat.symbol(code)}',
                  onTap: () => _pickCurrency(context, settingsController),
                  showDivider: false,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionLabel('Data'),
        const SizedBox(height: 8),
        _SettingsGroup(
          children: [
            _SettingsRow(
              label: 'Export CSV',
              value: 'Pro',
              onTap: () => PaywallPage.open(
                context,
                headline: 'Export your vault',
                body:
                    'CSV export is a Pro feature — take every vendor, amount, and due date with you.',
              ),
            ),
            _SettingsRow(
              label: 'Home screen widget',
              value: 'Pro',
              onTap: () => PaywallPage.open(
                context,
                headline: 'See what’s due on your Home Screen',
                body:
                    'The widget shows your next three renewals. Pro unlocks it along with unlimited items and scan.',
              ),
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionLabel('About'),
        const SizedBox(height: 8),
        _SettingsGroup(
          children: [
            _SettingsRow(
              label: 'Privacy',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PrivacyPage()),
                );
              },
            ),
            _SettingsRow(
              label: 'This stays on your phone',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const OnDevicePage()),
                );
              },
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> _pickReminder(
    BuildContext context,
    SettingsController controller,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.reminderTime,
    );
    if (picked == null) return;
    await controller.setReminderTime(picked);
  }

  static Future<void> _pickCurrency(
    BuildContext context,
    SettingsController controller,
  ) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.ledger.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final code in SettingsController.currencies)
                ListTile(
                  title: Text('$code · ${CurrencyFormat.symbol(code)}'),
                  trailing: controller.currency == code
                      ? Icon(Icons.check, color: ctx.ledger.pine, size: 20)
                      : null,
                  onTap: () => Navigator.pop(ctx, code),
                ),
            ],
          ),
        );
      },
    );
    if (picked == null) return;
    await controller.setCurrency(picked);
  }
}

class _ProRow extends StatelessWidget {
  const _ProRow();

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return StreamBuilder<List<Item>>(
      stream: VaultScope.of(context).watchAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Item>[];
        final active =
            items.where((item) => item.status == ItemStatus.active).length;
        final subtitle =
            'Free · $active of ${FreeLimits.activeItems} active items';

        return Material(
          color: ledger.pineSoft,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => PaywallPage.open(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Brand.name} Pro',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ledger.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: ledger.mute,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Upgrade',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ledger.pine,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppearanceBlock extends StatelessWidget {
  const _AppearanceBlock({required this.controller});

  final ThemeController controller;

  static String _label(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final modes = ThemeMode.values;
    final selected = modes.indexOf(controller.mode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ledger.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: TextStyle(fontSize: 16, color: ledger.ink),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth / modes.length;
              return Container(
                height: 40,
                decoration: BoxDecoration(
                  color: ledger.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ledger.line),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: LedgerMotion.duration,
                      curve: LedgerMotion.curve,
                      left: width * selected,
                      top: 3,
                      bottom: 3,
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: ledger.pineSoft,
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final mode in modes)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (details) {
                                ThemeRevealScope.of(context).setMode(
                                  mode,
                                  origin: details.globalPosition,
                                );
                              },
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: LedgerMotion.duration,
                                  curve: LedgerMotion.curve,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: controller.mode == mode
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: controller.mode == mode
                                        ? ledger.ink
                                        : ledger.mute,
                                  ),
                                  child: Text(_label(mode)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: context.texts.bodySmall?.copyWith(
        fontSize: 12,
        letterSpacing: 0.96,
        fontWeight: FontWeight.w600,
        color: context.ledger.mute,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ledger.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ledger.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.value,
    required this.onTap,
    this.showDivider = true,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(bottom: BorderSide(color: ledger.line))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: ledger.ink,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: 15,
                    color: ledger.mute,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
