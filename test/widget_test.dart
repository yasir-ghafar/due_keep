import 'package:due_keep/app/app.dart';
import 'package:due_keep/app/theme_controller.dart';
import 'package:due_keep/core/constants/brand.dart';
import 'package:due_keep/core/theme/ledger_colors.dart';
import 'package:due_keep/core/theme/ledger_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shell shows wordmark, tagline, and pine button', (tester) async {
    await tester.pumpWidget(const DueKeepApp());

    expect(find.text(Brand.name), findsOneWidget);
    expect(find.text(Brand.tagline), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add a renewal'), findsOneWidget);
  });

  testWidgets('light theme uses paper and pine', (tester) async {
    final controller = ThemeController(initial: ThemeMode.light);
    addTearDown(controller.dispose);

    await tester.pumpWidget(DueKeepApp(themeController: controller));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme!.scaffoldBackgroundColor, LedgerPalette.paper);

    final colors = materialApp.theme!.extension<LedgerColors>()!;
    expect(colors.pine, LedgerPalette.pine);
    expect(colors.onPine, LedgerPalette.white);
    expect(colors.text, LedgerPalette.text);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, LedgerPalette.paper);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    final style = button.style ?? materialApp.theme!.filledButtonTheme.style;
    expect(
      style?.backgroundColor?.resolve({}),
      LedgerPalette.pine,
    );
  });

  testWidgets('dark theme uses night and pine-light', (tester) async {
    final controller = ThemeController(initial: ThemeMode.dark);
    addTearDown(controller.dispose);

    await tester.pumpWidget(DueKeepApp(themeController: controller));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.darkTheme!.scaffoldBackgroundColor, LedgerPalette.night);

    final colors = materialApp.darkTheme!.extension<LedgerColors>()!;
    expect(colors.paper, LedgerPalette.night);
    expect(colors.pine, LedgerPalette.pineLight);
    expect(colors.onPine, LedgerPalette.night);
    expect(colors.text, LedgerPalette.foam);
    expect(colors.clay, LedgerPalette.clayDark);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, LedgerPalette.night);
  });

  testWidgets('theme mode labels switch light and dark', (tester) async {
    await tester.pumpWidget(const DueKeepApp());

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      LedgerPalette.night,
    );

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      LedgerPalette.paper,
    );
  });
}
