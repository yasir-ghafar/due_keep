import 'package:due_keep/app/app.dart';
import 'package:due_keep/app/theme_controller.dart';
import 'package:due_keep/core/constants/brand.dart';
import 'package:due_keep/core/theme/ledger_colors.dart';
import 'package:due_keep/core/theme/ledger_palette.dart';
import 'package:due_keep/data/datasources/onboarding_store.dart';
import 'package:due_keep/presentation/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  bool showSplash = false,
  bool onboarded = true,
  ThemeController? themeController,
}) {
  return DueKeepApp(
    themeController: themeController,
    onboardingStore: MemoryOnboardingStore(complete: onboarded),
    showSplash: showSplash,
  );
}

void main() {
  testWidgets('splash shows wordmark and tagline then onboarding', (tester) async {
    await tester.pumpWidget(_app(showSplash: true, onboarded: false));

    expect(find.text(Brand.name), findsOneWidget);
    expect(find.text(Brand.tagline), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(
      find.text(OnboardingPage.slides.first.headline),
      findsOneWidget,
    );
  });

  testWidgets('onboarding walks three screens then opens empty home', (
    tester,
  ) async {
    await tester.pumpWidget(_app(onboarded: false));
    await tester.pumpAndSettle();

    expect(
      find.text(OnboardingPage.slides.first.headline),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.text(OnboardingPage.slides[1].headline),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.text(OnboardingPage.slides[2].headline),
      findsOneWidget,
    );
    expect(find.text('Allow notifications'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.text('Upcoming'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Add your first renewal'),
      findsOneWidget,
    );
  });

  testWidgets('empty home shows first-add copy', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Upcoming'), findsOneWidget);
    expect(
      find.text('Nothing due this week. That’s the point.'),
      findsOneWidget,
    );
    expect(
      find.text('Add a bill, subscription, or warranty. We’ll keep the date.'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FilledButton, 'Add your first renewal'),
      findsOneWidget,
    );
  });

  testWidgets('first add opens method sheet then manual editor', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add your first renewal'));
    await tester.pumpAndSettle();

    expect(find.text('Add a renewal'), findsOneWidget);
    expect(find.text('Scan document'), findsOneWidget);
    expect(find.text('Choose screenshot'), findsOneWidget);
    expect(find.text('Enter manually'), findsOneWidget);

    await tester.tap(find.text('Enter manually'));
    await tester.pumpAndSettle();

    expect(find.text('New item'), findsOneWidget);
    expect(find.text('Vendor'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('light theme uses paper and pine', (tester) async {
    final controller = ThemeController(initial: ThemeMode.light);
    addTearDown(controller.dispose);

    await tester.pumpWidget(_app(themeController: controller));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme!.scaffoldBackgroundColor, LedgerPalette.paper);

    final colors = materialApp.theme!.extension<LedgerColors>()!;
    expect(colors.pine, LedgerPalette.pine);
    expect(colors.onPine, LedgerPalette.white);
    expect(colors.text, LedgerPalette.text);
    expect(colors.tabBar, LedgerPalette.ink);
    expect(colors.tabOn, LedgerPalette.paper);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, LedgerPalette.paper);

    final style = materialApp.theme!.filledButtonTheme.style;
    expect(
      style?.backgroundColor?.resolve({}),
      LedgerPalette.pine,
    );
  });

  testWidgets('dark theme uses night and pine-light', (tester) async {
    final controller = ThemeController(initial: ThemeMode.dark);
    addTearDown(controller.dispose);

    await tester.pumpWidget(_app(themeController: controller));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.darkTheme!.scaffoldBackgroundColor, LedgerPalette.night);

    final colors = materialApp.darkTheme!.extension<LedgerColors>()!;
    expect(colors.paper, LedgerPalette.night);
    expect(colors.pine, LedgerPalette.pineLight);
    expect(colors.onPine, LedgerPalette.night);
    expect(colors.text, LedgerPalette.foam);
    expect(colors.clay, LedgerPalette.clayDark);
    expect(colors.tabBar, LedgerPalette.pineLight);
    expect(colors.tabOn, LedgerPalette.night);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, LedgerPalette.night);
  });

  testWidgets('theme mode labels switch light and dark', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

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
