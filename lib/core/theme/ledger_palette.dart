import 'package:flutter/material.dart';

/// Ledger Pine tokens from the brand doc. Do not invent extra brand colors.
abstract final class LedgerPalette {
  // Light
  static const paper = Color(0xFFF6F3EC);
  static const card = Color(0xFFFFFDF8);
  static const line = Color(0xFFE6DFD4);
  static const ink = Color(0xFF143D3A);
  static const pine = Color(0xFF1F6F6A);
  static const pineSoft = Color(0xFFE4F0EE);
  static const text = Color(0xFF1A1814);
  static const mute = Color(0xFF6B645B);
  static const amber = Color(0xFFC4841D);
  static const amberSoft = Color(0xFFF8EED8);
  static const clay = Color(0xFFB42318);
  static const sage = Color(0xFF2F6B4F);
  static const white = Color(0xFFFFFFFF);

  // Dark
  static const night = Color(0xFF0C1110);
  static const panel = Color(0xFF151C1B);
  static const lineDark = Color(0xFF2A3331);
  static const foam = Color(0xFFEDE8DF);
  static const muteDark = Color(0xFF9A9388);
  static const pineLight = Color(0xFF7AB8B2);
  static const pineDim = Color(0xFF1A3331);
  static const amberDark = Color(0xFFE0A84A);
  static const clayDark = Color(0xFFF97066);
  static const sageDark = Color(0xFF6BBF8A);

  // Category accents (list dots and filters only)
  static const bill = Color(0xFF3D4C7A);
  static const billDark = Color(0xFF9AA6D4);
}
