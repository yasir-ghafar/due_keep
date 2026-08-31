import 'package:flutter/material.dart';

import '../../core/extensions/build_context_x.dart';

class ShellTab {
  const ShellTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Floating pill. Ink on paper in light; pine (button fill) in dark.
class PillTabBar extends StatelessWidget {
  const PillTabBar({
    super.key,
    required this.index,
    required this.tabs,
    required this.onSelect,
  });

  final int index;
  final List<ShellTab> tabs;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final idle = ledger.tabOn.withValues(alpha: 0.42);

    return Material(
      color: ledger.tabBar,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _Tab(
                  tab: tabs[i],
                  selected: i == index,
                  selectedColor: ledger.tabOn,
                  idleColor: idle,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.selected,
    required this.selectedColor,
    required this.idleColor,
    required this.onTap,
  });

  final ShellTab tab;
  final bool selected;
  final Color selectedColor;
  final Color idleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : idleColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tab.icon, size: 22, color: color),
          const SizedBox(height: 3),
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
