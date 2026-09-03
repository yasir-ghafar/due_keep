import 'package:flutter/material.dart';

import '../../app/vault_scope.dart';
import '../../core/extensions/build_context_x.dart';
import '../../domain/entities/item.dart';
import '../../domain/enums/item_category.dart';
import '../../domain/enums/item_status.dart';
import '../extensions/item_category_x.dart';
import '../extensions/item_copy_x.dart';
import '../item/item_detail_page.dart';
import '../widgets/item_row.dart';
import '../widgets/page_header.dart';
import '../widgets/pine_button.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  String _query = '';
  ItemCategory? _filter;

  List<Item> _visible(List<Item> items) {
    final q = _query.trim().toLowerCase();
    return items.where((item) {
      if (_filter != null && item.category != _filter) return false;
      if (q.isNotEmpty && !item.vendor.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return StreamBuilder<List<Item>>(
      stream: VaultScope.of(context).watchAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <Item>[];
        final visible = _visible(items);
        final active = items.where((item) => item.status == ItemStatus.active).length;
        final subtitle = items.isEmpty
            ? '0 items'
            : '${items.length} items · $active active';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Vault',
                subtitle: subtitle,
              ),
              if (items.isEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nothing stored yet.',
                          style: context.texts.titleMedium?.copyWith(
                            color: ledger.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a renewal from Home. It will live here.',
                          style: context.texts.bodySmall?.copyWith(
                            fontSize: 13,
                            height: 1.45,
                            color: ledger.mute,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PineButton(
                          label: 'Add your first renewal',
                          onPressed: widget.onAdd,
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                _SearchField(
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 12),
                _Filters(
                  selected: _filter,
                  onSelect: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: visible.isEmpty
                      ? Text(
                          'No items match. Try the vendor name.',
                          style: context.texts.bodySmall?.copyWith(
                            color: ledger.mute,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: visible.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = visible[index];
                            return ItemRow(
                              item: item,
                              meta: item.vaultMeta,
                              shortOverdue: true,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ItemDetailPage(
                                      itemId: item.id,
                                      backLabel: 'Vault',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return TextField(
      onChanged: onChanged,
      style: context.texts.bodyLarge?.copyWith(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Search vendor',
        prefixIcon: Icon(Icons.search, size: 18, color: ledger.mute),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        filled: true,
        fillColor: ledger.card,
        hintStyle: TextStyle(fontSize: 15, color: ledger.mute),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ledger.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ledger.pine, width: 1.5),
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onSelect});

  final ItemCategory? selected;
  final ValueChanged<ItemCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          label: 'All',
          selected: selected == null,
          onTap: () => onSelect(null),
        ),
        for (final category in const [
          ItemCategory.subscription,
          ItemCategory.bill,
          ItemCategory.warranty,
        ])
          _FilterChip(
            label: category.label,
            selected: selected == category,
            dot: category.accent(context.ledger),
            onTap: () => onSelect(category),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dot,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? ledger.pineSoft : ledger.card,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: selected ? Colors.transparent : ledger.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? ledger.ink : ledger.mute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
