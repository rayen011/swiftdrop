import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/restaurant.dart';
import 'package:swiftdrop/core/models/store_vertical.dart';
import 'package:swiftdrop/core/l10n/l10n.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';
import 'package:swiftdrop/data/repositories/restaurant_repository.dart';
import 'package:swiftdrop/features/search/presentation/search_screen.dart';

/// Minimal fake: SearchScreen only calls watchRestaurants.
class _FakeRepo implements RestaurantRepository {
  _FakeRepo(this.stores);
  final List<Restaurant> stores;

  @override
  Stream<List<Restaurant>> watchRestaurants({String? category}) =>
      Stream.value(stores);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

const _stores = [
  Restaurant(
    id: 'dar_el_pizza',
    name: 'Dar El Pizza',
    category: 'food',
    neighborhood: 'lac2',
    menuCategories: ['Pizza', 'Sides'],
  ),
  Restaurant(
    id: 'burger_marsa',
    name: 'Burger Marsa',
    category: 'food',
    neighborhood: 'la_marsa',
    menuCategories: ['Burgers'],
  ),
];

Future<void> _pump(WidgetTester tester,
    {Size size = const Size(360, 720)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SearchScreen(
        vertical: StoreVertical.fastFood,
        repo: _FakeRepo(_stores),
      ),
    ),
  );
  await tester.pump(); // resolve the stream
}

void main() {
  testWidgets('shows all stores before typing', (tester) async {
    await _pump(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Dar El Pizza'), findsOneWidget);
    expect(find.text('Burger Marsa'), findsOneWidget);
  });

  testWidgets('filters live as the user types', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'burger');
    await tester.pump();

    expect(find.text('Burger Marsa'), findsOneWidget);
    expect(find.text('Dar El Pizza'), findsNothing);
  });

  testWidgets('matches on what a store sells', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'pizza');
    await tester.pump();

    expect(find.text('Dar El Pizza'), findsOneWidget);
    expect(find.text('Burger Marsa'), findsNothing);
  });

  testWidgets('shows a friendly empty state for no results', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'sushi');
    await tester.pump();

    expect(find.textContaining('No results'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clear button resets to all stores', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'burger');
    await tester.pump();
    expect(find.text('Dar El Pizza'), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(find.text('Dar El Pizza'), findsOneWidget);
    expect(find.text('Burger Marsa'), findsOneWidget);
  });
}
