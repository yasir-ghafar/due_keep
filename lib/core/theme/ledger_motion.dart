import 'package:flutter/material.dart';

/// Short and structural. No bounce.
abstract final class LedgerMotion {
  static const duration = Duration(milliseconds: 150);

  /// Circular theme reveal from the Appearance control.
  static const themeDuration = Duration(milliseconds: 600);

  static const curve = Curves.easeInOut;
}
