import 'package:flutter/material.dart';

import '../../core/extensions/build_context_x.dart';

enum AddMethod { scan, screenshot, manual }

/// Scan · Screenshot · Manual. First-add and FAB both open this.
class AddMethodSheet extends StatelessWidget {
  const AddMethodSheet({super.key, required this.onSelect});

  final ValueChanged<AddMethod> onSelect;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<AddMethod> onSelect,
  }) {
    final ledger = context.ledger;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: ledger.ink.withValues(alpha: 0.36),
      builder: (sheetContext) {
        return AddMethodSheet(
          onSelect: (method) {
            Navigator.of(sheetContext).pop();
            onSelect(method);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return Material(
      color: ledger.card,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ledger.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add a renewal',
                style: texts.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: ledger.ink,
                ),
              ),
              const SizedBox(height: 8),
              _SheetRow(
                icon: Icons.photo_camera_outlined,
                title: 'Scan document',
                detail: 'Photo of a bill or receipt',
                showDivider: true,
                onTap: () => onSelect(AddMethod.scan),
              ),
              _SheetRow(
                icon: Icons.image_outlined,
                title: 'Choose screenshot',
                detail: 'From your photo library',
                showDivider: true,
                onTap: () => onSelect(AddMethod.screenshot),
              ),
              _SheetRow(
                icon: Icons.edit_outlined,
                title: 'Enter manually',
                detail: 'Always free within the cap',
                showDivider: false,
                onTap: () => onSelect(AddMethod.manual),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.showDivider,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ledger = context.ledger;
    final texts = context.texts;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: ledger.line))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ledger.pineSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: ledger.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: texts.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ledger.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: texts.bodySmall?.copyWith(
                      fontSize: 13,
                      color: ledger.mute,
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
