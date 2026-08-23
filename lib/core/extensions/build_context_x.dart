import 'package:flutter/material.dart';

import '../theme/ledger_colors.dart';

extension LedgerBuildContext on BuildContext {
  LedgerColors get ledger => Theme.of(this).extension<LedgerColors>()!;

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get texts => Theme.of(this).textTheme;
}
