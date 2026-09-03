import 'package:due_keep/app/app.dart';
import 'package:due_keep/app/theme_controller.dart';
import 'package:due_keep/core/constants/brand.dart';
import 'package:due_keep/core/theme/ledger_colors.dart';
import 'package:due_keep/core/theme/ledger_palette.dart';
import 'package:due_keep/data/datasources/onboarding_store.dart';
import 'package:due_keep/data/repositories/memory_item_repository.dart';
import 'package:due_keep/domain/entities/item.dart';
import 'package:due_keep/domain/enums/item_category.dart';
import 'package:due_keep/domain/enums/item_cycle.dart';
import 'package:due_keep/domain/enums/item_status.dart';
import 'package:due_keep/domain/repositories/item_repository.dart';
import 'package:due_keep/presentation/onboarding/onboarding_page.dart';
import 'package:due_keep/presentation/widgets/pill_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

Item _item({
  required String id,
  required String vendor,
  required ItemCategory category,
  required DateTime nextDate,
  ItemCycle cycle = ItemCycle.monthly,
  ItemStatus status = ItemStatus.active,
  double? amount,
  DateTime? lastPaidOn,
}) {
  return Item(
    id: id,
    vendor: vendor,
    category: category,
    cycle: cycle,
    nextDate: nextDate,
    status: status,
    amount: amount,
    currency: amount == null ? null : 'USD',
    lastPaidOn: lastPaidOn,
  );
}

List<Item> _populatedItems() {
  final today = _today();
  return [
    _item(
      id: 'netflix',
      vendor: 'Netflix',
      category: ItemCategory.subscription,
      nextDate: today.subtract(const Duration(days: 2)),
      amount: 15.99,
    ),
    _item(
      id: 'att',
      vendor: 'AT&T',
      category: ItemCategory.bill,
      nextDate: today.add(const Duration(days: 3)),
      amount: 42,
    ),
    _item(
      id: 'icloud',
      vendor: 'iCloud+',
      category: ItemCategory.subscription,
      nextDate: today.add(const Duration(days: 5)),
      amount: 2.99,
    ),
    _item(
      id: 'framework',
      vendor: 'Framework laptop',
      category: ItemCategory.warranty,
      cycle: ItemCycle.oneTime,
      nextDate: today.add(const Duration(days: 41)),
    ),
    _item(
      id: 'spotify',
      vendor: 'Spotify',
      category: ItemCategory.subscription,
      nextDate: today.add(const Duration(days: 10)),
      amount: 10.99,
      status: ItemStatus.paused,
    ),
  ];
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(PillTabBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Widget _app({
  bool showSplash = false,
  bool onboarded = true,
  ThemeController? themeController,
  ItemRepository? itemRepository,
}) {
  return DueKeepApp(
    themeController: themeController,
    onboardingStore: MemoryOnboardingStore(complete: onboarded),
    itemRepository: itemRepository,
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

    await _openTab(tester, 'Settings');

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

  testWidgets('populated home shows hero, sections, and hides paused items', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(itemRepository: MemoryItemRepository(seed: _populatedItems())),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 due this week'), findsOneWidget);
    expect(find.text('\$61 due in 30 days'), findsOneWidget);
    expect(find.text('Next is Netflix — overdue 2 days'), findsOneWidget);
    expect(find.text('OVERDUE'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('LATER'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('AT&T'), findsOneWidget);
    expect(find.text('iCloud+'), findsOneWidget);
    expect(find.text('Framework laptop'), findsOneWidget);
    expect(find.text('Spotify'), findsNothing);
    expect(find.text('Warranty · coverage ends'), findsOneWidget);
  });

  testWidgets('home row opens item detail', (tester) async {
    await tester.pumpWidget(
      _app(itemRepository: MemoryItemRepository(seed: _populatedItems())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Netflix'));
    await tester.pumpAndSettle();

    expect(find.text('Upcoming'), findsWidgets);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Mark paid'), findsOneWidget);
  });

  testWidgets('vault searches and filters the library', (tester) async {
    await tester.pumpWidget(
      _app(itemRepository: MemoryItemRepository(seed: _populatedItems())),
    );
    await tester.pumpAndSettle();

    await _openTab(tester, 'Vault');

    expect(find.text('5 items · 4 active'), findsOneWidget);
    expect(find.text('Search vendor'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);
    expect(find.text('overdue'), findsOneWidget);
    expect(find.text('Active · warranty'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'net');
    await tester.pumpAndSettle();
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('AT&T'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bill'));
    await tester.pumpAndSettle();
    expect(find.text('AT&T'), findsOneWidget);
    expect(find.text('Netflix'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No items match. Try the vendor name.'), findsOneWidget);
  });

  testWidgets('empty vault shows the first-add CTA', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await _openTab(tester, 'Vault');

    expect(find.text('0 items'), findsOneWidget);
    expect(find.text('Nothing stored yet.'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Add your first renewal'),
      findsOneWidget,
    );
  });

  testWidgets('paused item can resume and return to home', (tester) async {
    final today = _today();
    final repo = MemoryItemRepository(
      seed: [
        _item(
          id: 'spotify',
          vendor: 'Spotify',
          category: ItemCategory.subscription,
          nextDate: today.add(const Duration(days: 10)),
          amount: 10.99,
          status: ItemStatus.paused,
        ),
      ],
    );

    await tester.pumpWidget(_app(itemRepository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Spotify'), findsNothing);

    await _openTab(tester, 'Vault');
    await tester.tap(find.text('Spotify'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Resume'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Mark paid'), findsNothing);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Mark paid'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Resume'), findsNothing);

    await tester.tap(find.text('Vault').first);
    await tester.pumpAndSettle();
    await _openTab(tester, 'Home');

    expect(find.text('Spotify'), findsOneWidget);
  });

  testWidgets('delete is offered only when never marked paid', (tester) async {
    final today = _today();
    final repo = MemoryItemRepository(
      seed: [
        _item(
          id: 'fresh',
          vendor: 'Fresh Co',
          category: ItemCategory.bill,
          nextDate: today.add(const Duration(days: 2)),
          amount: 20,
        ),
        _item(
          id: 'paid',
          vendor: 'Paid Co',
          category: ItemCategory.subscription,
          nextDate: today.add(const Duration(days: 4)),
          amount: 9.99,
          lastPaidOn: today.subtract(const Duration(days: 26)),
        ),
      ],
    );

    await tester.pumpWidget(_app(itemRepository: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fresh Co'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this item'), findsOneWidget);

    await tester.tap(find.text('Delete this item'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Fresh Co?'), findsOneWidget);
    await tester.tap(find.text('Delete item'));
    await tester.pumpAndSettle();

    expect(find.text('Fresh Co'), findsNothing);
    expect(await repo.getById('fresh'), isNull);

    await tester.tap(find.text('Paid Co'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this item'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Mark paid'), findsOneWidget);
  });

  testWidgets('vault cancelled item can be deleted even if marked paid', (
    tester,
  ) async {
    final today = _today();
    final repo = MemoryItemRepository(
      seed: [
        _item(
          id: 'old',
          vendor: 'Old Co',
          category: ItemCategory.subscription,
          nextDate: today.add(const Duration(days: 12)),
          amount: 12,
          status: ItemStatus.cancelled,
          lastPaidOn: today.subtract(const Duration(days: 40)),
        ),
      ],
    );

    await tester.pumpWidget(_app(itemRepository: repo));
    await tester.pumpAndSettle();

    await _openTab(tester, 'Vault');
    expect(find.text('Old Co'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);

    await tester.tap(find.text('Old Co'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this item'), findsOneWidget);
    await tester.tap(find.text('Delete this item'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'This permanently removes the cancelled item from the vault.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Delete item'));
    await tester.pumpAndSettle();

    expect(find.text('Old Co'), findsNothing);
    expect(await repo.getById('old'), isNull);
  });
}
