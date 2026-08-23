import 'package:flutter/material.dart';

import '../../core/theme/ledger_colors.dart';
import '../../domain/enums/item_category.dart';

extension ItemCategoryAccent on ItemCategory {
  /// List-dot and filter accent. Quieter than pine; does not rebrand the app.
  Color accent(LedgerColors colors) => switch (this) {
        ItemCategory.subscription => colors.subscription,
        ItemCategory.bill => colors.bill,
        ItemCategory.warranty => colors.warranty,
        ItemCategory.other => colors.other,
      };
}
