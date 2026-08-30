// Layout tests for the store switcher + grocery UI, at a small (320pt) phone
// and a large (1.3x) system text size — the two conditions that expose the
// overflow the picker had. `flutter analyze` can't see a RenderFlex overflow;
// these can.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/menu_item.dart';
import 'package:swiftdrop/core/models/restaurant.dart';
import 'package:swiftdrop/core/models/store_vertical.dart';
import 'package:swiftdrop/core/l10n/l10n.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';
import 'package:swiftdrop/data/repositories/auth_repository.dart';
import 'package:swiftdrop/l10n/gen/app_localizations_en.dart';
import 'package:swiftdrop/features/cart/cubit/cart_cubit.dart';
import 'package:swiftdrop/features/favorites/cubit/favorites_cubit.dart';
import 'package:swiftdrop/features/grocery/presentation/grocery_product_screen.dart';
import 'package:swiftdrop/features/grocery/presentation/widgets/grocery_filters.dart';
import 'package:swiftdrop/features/grocery/presentation/widgets/grocery_product_card.dart';
import 'package:swiftdrop/features/home/presentation/widgets/store_picker.dart';

const _restaurant = Restaurant(
  id: 'monoprix',
  name: 'Monoprix Express',
  category: 'grocery',
  neighborhood: 'ariana',
  rating: 4.3,
  deliveryFeeTND: 1.0,
  estimatedMinutes: 35,
);

const _saleItem = MenuItem(
  id: 'mp_oranges',
  restaurantId: 'monoprix',
  category: 'Fresh',
  name: 'Sweet Oranges',
  priceTND: 3.0,
  mrpTND: 4.0,
);

/// An unbound FavoritesCubit never calls its repository, so a throwing stub is
/// enough for screens that merely render the heart.
class _StubAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget withCubits(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(create: (_) => FavoritesCubit(_StubAuthRepo())),
      ],
      child: child,
    );

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('StorePickerSheet', () {
    testWidgets('shows every vertical without overflow (small screen)',
        (tester) async {
      await _pump(
        tester,
        StorePickerSheet(current: StoreVertical.fastFood, onSelect: (_) {}),
        size: const Size(320, 480),
      );

      expect(tester.takeException(), isNull);
      final l10n = AppLocalizationsEn();
      for (final v in StoreVertical.menu) {
        expect(find.text(v.label(l10n)), findsOneWidget);
      }
    });

    testWidgets('survives a large text scale', (tester) async {
      await _pump(
        tester,
        StorePickerSheet(current: StoreVertical.coffee, onSelect: (_) {}),
        size: const Size(320, 560),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('reports the tapped vertical', (tester) async {
      StoreVertical? picked;
      await _pump(
        tester,
        StorePickerSheet(
            current: StoreVertical.fastFood, onSelect: (v) => picked = v),
      );
      await tester.tap(find.text('Groceries'));
      expect(picked, StoreVertical.groceries);
    });
  });

  group('StoreSelectorBar', () {
    testWidgets('fits its label on a narrow screen', (tester) async {
      // "Coffee & Drinks" is the longest label — the one that used to overflow.
      await _pump(
        tester,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: StoreSelectorBar(
              vertical: StoreVertical.coffee, onChanged: _noopVertical),
        ),
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Coffee & Drinks'), findsOneWidget);
    });
  });

  group('GroceryProductCard', () {
    Widget card() => BlocProvider(
          create: (_) => CartCubit(),
          child: const SizedBox(
            // The real grid cell size (maxCrossAxisExtent 220 / extent 264).
            width: 150,
            height: 264,
            child: GroceryProductCard(
              restaurant: _restaurant,
              item: _saleItem,
              isFavorite: false,
              onFavorite: _noop,
              onTap: _noop,
            ),
          ),
        );

    testWidgets('renders sale price + MRP without overflow', (tester) async {
      await _pump(tester, Center(child: card()), size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      expect(find.text('Sweet Oranges'), findsOneWidget);
      expect(find.textContaining('-25%'), findsOneWidget); // 3 off 4
    });

    testWidgets('holds up at a large text scale', (tester) async {
      await _pump(
        tester,
        Center(child: card()),
        size: const Size(320, 640),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('add button becomes a stepper after tapping', (tester) async {
      await _pump(tester, Center(child: card()));
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();

      // Now the line is in the cart: quantity shown, remove control present.
      expect(find.text('1'), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    });
  });

  group('GroceryProductScreen', () {
    Widget page() => withCubits(
          const GroceryProductScreen(
            args: GroceryProductArgs(
              restaurant: _restaurant,
              item: MenuItem(
                id: 'mp_oranges',
                restaurantId: 'monoprix',
                category: 'Fresh',
                name: 'Sweet Oranges',
                priceTND: 3.0,
                mrpTND: 4.0,
                unit: '500g',
                description: 'Naturally sweet and juicy.',
                highlights: ['100% natural', 'Rich in vitamin C'],
              ),
            ),
          ),
        );

    testWidgets('renders the detail without overflow (small screen)',
        (tester) async {
      await _pump(tester, page(), size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      expect(find.text('Sweet Oranges'), findsOneWidget);
      expect(find.text('500g'), findsOneWidget);
      expect(find.text('About this product'), findsOneWidget);
      expect(find.text("Why you'll love it"), findsOneWidget);
      expect(find.textContaining('MRP'), findsOneWidget);
    });

    testWidgets('holds up at a large text scale', (tester) async {
      await _pump(tester, page(), size: const Size(320, 640), textScale: 1.3);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Add to cart puts the chosen quantity in the cart',
        (tester) async {
      final cubit = CartCubit();
      addTearDown(cubit.close);
      await _pump(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider(create: (_) => FavoritesCubit(_StubAuthRepo())),
          ],
          child: const GroceryProductScreen(
            args: GroceryProductArgs(
              restaurant: _restaurant,
              item: MenuItem(
                id: 'mp_oranges',
                restaurantId: 'monoprix',
                category: 'Fresh',
                name: 'Sweet Oranges',
                priceTND: 3.0,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_rounded)); // qty 1 -> 2
      await tester.pump();
      await tester.tap(find.text('Add to cart'));
      await tester.pump();

      expect(cubit.state.itemCount, 2);
      expect(cubit.state.items.single.menuItemId, 'mp_oranges');
    });
  });

  group('GroceryFilterRow', () {
    testWidgets('lays out on a narrow screen', (tester) async {
      await _pump(
        tester,
        GroceryFilterRow(
          sort: GrocerySort.recommended,
          category: null,
          offersOnly: false,
          categories: const ['Fresh', 'Pantry', 'Drinks'],
          onSort: (_) {},
          onCategory: (_) {},
          onOffers: (_) {},
        ),
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Sort by'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Offers'), findsOneWidget);
    });
  });
}

void _noop() {}
void _noopVertical(StoreVertical _) {}
