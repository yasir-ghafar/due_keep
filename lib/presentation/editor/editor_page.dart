import 'package:flutter/material.dart';

import '../../core/extensions/build_context_x.dart';
import '../../core/extensions/date_time_x.dart';
import '../../core/theme/ledger_motion.dart';
import '../../domain/enums/item_category.dart';
import '../../domain/enums/item_cycle.dart';
import '../widgets/pine_button.dart';

/// Manual create. Vendor and next date are required to save.
class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _vendor = TextEditingController();
  final _amount = TextEditingController();
  ItemCategory _category = ItemCategory.subscription;
  ItemCycle _cycle = ItemCycle.monthly;
  DateTime? _nextDue;

  bool get _canSave =>
      _vendor.text.trim().isNotEmpty && _nextDue != null;

  @override
  void dispose() {
    _vendor.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDue ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 15),
    );
    if (picked == null) return;
    setState(() => _nextDue = picked);
  }

  Future<void> _pickCycle() async {
    final picked = await showModalBottomSheet<ItemCycle>(
      context: context,
      backgroundColor: context.ledger.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final cycle in ItemCycle.values)
                ListTile(
                  title: Text(_cycleLabel(cycle)),
                  onTap: () => Navigator.pop(ctx, cycle),
                ),
            ],
          ),
        );
      },
    );
    if (picked == null) return;
    setState(() => _cycle = picked);
  }

  void _save() {
    if (!_canSave) return;
    Navigator.of(context).pop();
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
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chevron_left,
                            size: 18,
                            color: ledger.pine,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Cancel',
                            style: texts.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: ledger.pine,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'New item',
                    style: texts.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.84,
                      color: ledger.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Vendor',
                    child: TextField(
                      controller: _vendor,
                      onChanged: (_) => setState(() {}),
                      style: texts.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ledger.text,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Netflix, AT&T, landlord…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: texts.bodySmall?.copyWith(
                            fontSize: 12,
                            color: ledger.mute,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            for (final category in const [
                              ItemCategory.subscription,
                              ItemCategory.bill,
                              ItemCategory.warranty,
                            ]) ...[
                              if (category != ItemCategory.subscription)
                                const SizedBox(width: 8),
                              Expanded(
                                child: _SegPill(
                                  label: _categoryLabel(category),
                                  selected: _category == category,
                                  onTap: () =>
                                      setState(() => _category = category),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _Field(
                    label: 'Amount',
                    child: TextField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: texts.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ledger.text,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Optional · USD',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  _Field(
                    label: 'Cycle',
                    onTap: _pickCycle,
                    child: Text(
                      _cycleLabel(_cycle),
                      style: texts.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ledger.text,
                      ),
                    ),
                  ),
                  _Field(
                    label: 'Next due',
                    onTap: _pickDue,
                    child: Text(
                      _nextDue?.dayMonthYear ?? 'Choose a date',
                      style: texts.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _nextDue == null ? ledger.mute : ledger.text,
                      ),
                    ),
                  ),
                  const _Field(
                    label: 'Remind me',
                    child: Text('7 days before, and on the day'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: PineButton(
                label: 'Save',
                onPressed: _canSave ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _categoryLabel(ItemCategory category) => switch (category) {
        ItemCategory.subscription => 'Subscription',
        ItemCategory.bill => 'Bill',
        ItemCategory.warranty => 'Warranty',
        ItemCategory.other => 'Other',
      };

  static String _cycleLabel(ItemCycle cycle) => switch (cycle) {
        ItemCycle.weekly => 'Weekly',
        ItemCycle.monthly => 'Monthly',
        ItemCycle.yearly => 'Yearly',
        ItemCycle.oneTime => 'One-time',
      };
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.child,
    this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    final body = Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ledger.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ledger.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: texts.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ledger.mute,
            ),
          ),
          const SizedBox(height: 2),
          DefaultTextStyle(
            style: texts.bodyLarge!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ledger.text,
            ),
            child: child,
          ),
        ],
      ),
    );

    if (onTap == null) return body;
    return GestureDetector(onTap: onTap, child: body);
  }
}

class _SegPill extends StatelessWidget {
  const _SegPill({
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
      child: AnimatedContainer(
        duration: LedgerMotion.duration,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ledger.pineSoft : ledger.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.transparent : ledger.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? ledger.ink : ledger.mute,
          ),
        ),
      ),
    );
  }
}
