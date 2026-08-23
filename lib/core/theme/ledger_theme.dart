import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ledger_colors.dart';
import 'ledger_palette.dart';

/// Light and dark [ThemeData] for Ledger Pine.
///
/// Body text uses [LedgerColors.text], never mute. Primary buttons are pine
/// with a white (light) or night (dark) label. Clay is for overdue and
/// destructive confirm only.
abstract final class LedgerTheme {
  static ThemeData light() => _build(
        brightness: Brightness.light,
        colors: LedgerColors.light,
        overlay: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: LedgerPalette.paper,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        colors: LedgerColors.dark,
        overlay: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: LedgerPalette.night,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required LedgerColors colors,
    required SystemUiOverlayStyle overlay,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.pine,
      onPrimary: colors.onPine,
      primaryContainer: colors.pineSoft,
      onPrimaryContainer: colors.ink,
      secondary: colors.ink,
      onSecondary: isDark ? LedgerPalette.night : LedgerPalette.paper,
      secondaryContainer: colors.pineSoft,
      onSecondaryContainer: colors.ink,
      tertiary: colors.sage,
      onTertiary: isDark ? LedgerPalette.night : LedgerPalette.white,
      error: colors.clay,
      onError: isDark ? LedgerPalette.night : LedgerPalette.white,
      surface: colors.card,
      onSurface: colors.text,
      onSurfaceVariant: colors.mute,
      outline: colors.line,
      outlineVariant: colors.line,
      inverseSurface: colors.ink,
      onInverseSurface: colors.paper,
      inversePrimary: isDark ? LedgerPalette.pine : LedgerPalette.pineLight,
      surfaceTint: Colors.transparent,
      shadow: Colors.transparent,
      scrim: colors.ink.withValues(alpha: 0.32),
    );

    final textTheme = _textTheme(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.paper,
      canvasColor: colors.paper,
      cardColor: colors.card,
      dividerColor: colors.line,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.paper,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: overlay,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.line),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.line,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.pine,
          foregroundColor: colors.onPine,
          elevation: 0,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          side: BorderSide(color: colors.ink),
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.pine,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.pine,
        foregroundColor: colors.onPine,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.pineSoft,
        selectedColor: colors.pineSoft,
        disabledColor: colors.line,
        labelStyle: textTheme.bodySmall?.copyWith(color: colors.ink),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.paper,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.mute),
        labelStyle: textTheme.bodySmall,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.pine, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.clay),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? LedgerPalette.night : LedgerPalette.paper,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.paper,
        indicatorColor: colors.pineSoft,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.bodySmall?.copyWith(
            color: selected ? colors.ink : colors.mute,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.ink : colors.mute,
            size: 22,
          );
        }),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static TextTheme _textTheme(LedgerColors colors) {
    const tabular = [FontFeature.tabularFigures()];
    // Platform default: SF Pro on iOS, Roboto on Android. No display font.
    const family = null;

    TextStyle base({
      required double size,
      FontWeight weight = FontWeight.w400,
      Color? color,
      double letterSpacing = 0,
      double height = 1.25,
      List<FontFeature>? features,
    }) {
      return TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        color: color ?? colors.text,
        letterSpacing: letterSpacing,
        height: height,
        fontFeatures: features,
      );
    }

    return TextTheme(
      displaySmall: base(
        size: 28,
        weight: FontWeight.w600,
        color: colors.ink,
        letterSpacing: -0.5,
        features: tabular,
      ),
      headlineMedium: base(
        size: 26,
        weight: FontWeight.w600,
        color: colors.ink,
        letterSpacing: -0.4,
      ),
      titleLarge: base(
        size: 22,
        weight: FontWeight.w600,
        color: colors.ink,
        letterSpacing: -0.3,
      ),
      titleMedium: base(
        size: 17,
        weight: FontWeight.w600,
        color: colors.ink,
      ),
      titleSmall: base(
        size: 15,
        weight: FontWeight.w600,
        color: colors.ink,
      ),
      bodyLarge: base(size: 16, color: colors.text, height: 1.4),
      bodyMedium: base(size: 16, color: colors.text, height: 1.4),
      bodySmall: base(size: 13, color: colors.mute, height: 1.35),
      labelLarge: base(size: 15, weight: FontWeight.w600, color: colors.ink),
      labelMedium: base(size: 13, weight: FontWeight.w600, color: colors.mute),
      labelSmall: base(
        size: 11,
        weight: FontWeight.w600,
        color: colors.mute,
        letterSpacing: 0.2,
      ),
    );
  }
}