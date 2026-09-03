import 'package:flutter/material.dart';

import '../../app/theme_controller.dart';
import '../../core/extensions/build_context_x.dart';
import '../add/add_method_sheet.dart';
import '../editor/editor_page.dart';
import '../home/home_page.dart';
import '../settings/settings_page.dart';
import '../vault/vault_page.dart';
import '../widgets/pill_tab_bar.dart';

/// Home · Vault · Settings with a floating pill tab bar and add FAB.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.themeController});

  final ThemeController themeController;

  static const tabs = [
    ShellTab(label: 'Home', icon: Icons.calendar_month_outlined),
    ShellTab(label: 'Vault', icon: Icons.inventory_2_outlined),
    ShellTab(label: 'Settings', icon: Icons.settings_outlined),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  bool get _showFab => _tab != 2;

  Future<void> _scanLater() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scan comes later. Enter it by hand for now.'),
      ),
    );
  }

  Future<void> _openAdd() async {
    await AddMethodSheet.show(
      context,
      onSelect: (method) {
        switch (method) {
          case AddMethod.manual:
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EditorPage(),
              ),
            );
          case AddMethod.scan:
          case AddMethod.screenshot:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Scan comes later. Enter it by hand for now.'),
              ),
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final safe = MediaQuery.paddingOf(context).bottom;
    final tabBottom = safe > 0 ? safe : 28.0;

    return Scaffold(
      backgroundColor: ledger.paper,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: tabBottom + 64),
                child: IndexedStack(
                  index: _tab,
                  children: [
                    HomePage(onAdd: _openAdd, onScan: _scanLater),
                    VaultPage(onAdd: _openAdd),
                    SettingsPage(themeController: widget.themeController),
                  ],
                ),
              ),
            ),
          ),
          if (_showFab)
            Positioned(
              right: 22,
              bottom: tabBottom + 64 + 16,
              child: _AddFab(onPressed: _openAdd),
            ),
          Positioned(
            left: 20,
            right: 20,
            bottom: tabBottom,
            child: PillTabBar(
              index: _tab,
              tabs: AppShell.tabs,
              onSelect: (index) => setState(() => _tab = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ledger.pine.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: ledger.pine,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.add, color: ledger.onPine, size: 24),
          ),
        ),
      ),
    );
  }
}
