import 'package:flutter/material.dart';

import 'ledger_palette.dart';

/// Semantic Ledger Pine colors that [ColorScheme] does not cover
/// (soon, overdue, success, category dots, chip washes).
@immutable
class LedgerColors extends ThemeExtension<LedgerColors> {
  const LedgerColors({
    required this.paper,
    required this.card,
    required this.line,
    required this.ink,
    required this.pine,
    required this.pineSoft,
    required this.text,
    required this.mute,
    required this.amber,
    required this.amberSoft,
    required this.clay,
    required this.sage,
    required this.onPine,
    required this.subscription,
    required this.bill,
    required this.warranty,
    required this.other,
  });

  final Color paper;
  final Color card;
  final Color line;
  final Color ink;
  final Color pine;
  final Color pineSoft;
  final Color text;
  final Color mute;
  final Color amber;
  final Color amberSoft;
  final Color clay;
  final Color sage;
  final Color onPine;
  final Color subscription;
  final Color bill;
  final Color warranty;
  final Color other;

  static const light = LedgerColors(
    paper: LedgerPalette.paper,
    card: LedgerPalette.card,
    line: LedgerPalette.line,
    ink: LedgerPalette.ink,
    pine: LedgerPalette.pine,
    pineSoft: LedgerPalette.pineSoft,
    text: LedgerPalette.text,
    mute: LedgerPalette.mute,
    amber: LedgerPalette.amber,
    amberSoft: LedgerPalette.amberSoft,
    clay: LedgerPalette.clay,
    sage: LedgerPalette.sage,
    onPine: LedgerPalette.white,
    subscription: LedgerPalette.pine,
    bill: LedgerPalette.bill,
    warranty: LedgerPalette.amber,
    other: LedgerPalette.mute,
  );

  static const dark = LedgerColors(
    paper: LedgerPalette.night,
    card: LedgerPalette.panel,
    line: LedgerPalette.lineDark,
    ink: LedgerPalette.foam,
    pine: LedgerPalette.pineLight,
    pineSoft: LedgerPalette.pineDim,
    text: LedgerPalette.foam,
    mute: LedgerPalette.muteDark,
    amber: LedgerPalette.amberDark,
    amberSoft: Color(0xFF2C2618),
    clay: LedgerPalette.clayDark,
    sage: LedgerPalette.sageDark,
    onPine: LedgerPalette.night,
    subscription: LedgerPalette.pineLight,
    bill: LedgerPalette.billDark,
    warranty: LedgerPalette.amberDark,
    other: LedgerPalette.muteDark,
  );

  @override
  LedgerColors copyWith({
    Color? paper,
    Color? card,
    Color? line,
    Color? ink,
    Color? pine,
    Color? pineSoft,
    Color? text,
    Color? mute,
    Color? amber,
    Color? amberSoft,
    Color? clay,
    Color? sage,
    Color? onPine,
    Color? subscription,
    Color? bill,
    Color? warranty,
    Color? other,
  }) {
    return LedgerColors(
      paper: paper ?? this.paper,
      card: card ?? this.card,
      line: line ?? this.line,
      ink: ink ?? this.ink,
      pine: pine ?? this.pine,
      pineSoft: pineSoft ?? this.pineSoft,
      text: text ?? this.text,
      mute: mute ?? this.mute,
      amber: amber ?? this.amber,
      amberSoft: amberSoft ?? this.amberSoft,
      clay: clay ?? this.clay,
      sage: sage ?? this.sage,
      onPine: onPine ?? this.onPine,
      subscription: subscription ?? this.subscription,
      bill: bill ?? this.bill,
      warranty: warranty ?? this.warranty,
      other: other ?? this.other,
    );
  }

  @override
  LedgerColors lerp(ThemeExtension<LedgerColors>? other, double t) {
    if (other is! LedgerColors) return this;
    return LedgerColors(
      paper: Color.lerp(paper, other.paper, t)!,
      card: Color.lerp(card, other.card, t)!,
      line: Color.lerp(line, other.line, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      pine: Color.lerp(pine, other.pine, t)!,
      pineSoft: Color.lerp(pineSoft, other.pineSoft, t)!,
      text: Color.lerp(text, other.text, t)!,
      mute: Color.lerp(mute, other.mute, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      clay: Color.lerp(clay, other.clay, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
      onPine: Color.lerp(onPine, other.onPine, t)!,
      subscription: Color.lerp(subscription, other.subscription, t)!,
      bill: Color.lerp(bill, other.bill, t)!,
      warranty: Color.lerp(warranty, other.warranty, t)!,
      other: Color.lerp(this.other, other.other, t)!,
    );
  }
}
