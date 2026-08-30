// Layout + behaviour tests for the pharmacy UI, at 320pt and 1.3x text scale.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/menu_item.dart';
import 'package:swiftdrop/core/models/restaurant.dart';
import 'package:swiftdrop/core/l10n/l10n.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';
import 'package:swiftdrop/data/repositories/auth_repository.dart';
import 'package:swiftdrop/features/cart/cubit/cart_cubit.dart';
import 'package:swiftdrop/features/favorites/cubit/favorites_cubit.dart';
import 'package:swiftdrop/features/pharmacy/presentation/pharmacy_product_screen.dart';
import 'package:swiftdrop/features/pharmacy/presentation/widgets/medicine_card.dart';
import 'package:swiftdrop/features/pharmacy/presentation/widgets/medicine_request_sheet.dart';

const _pharmacy = Restaurant(
  id: 'pharmacie_centrale',
  name: 'Pharmacie Centrale',
  category: 'pharmacy',
  neighborhood: 'centre_ville',
  rating: 4.9,
  deliveryFeeTND: 1.5,
  estimatedMinutes: 22,
);

const _mask = MenuItem(
  id: 'pc_mask',
  restaurantId: 'pharmacie_centrale',
  category: 'Essentials',
  name: 'Surgical Face Masks',
  description: '3-ply protective masks, box of 10.',
  priceTND: 3.5,
  mrpTND: 5.0,
  rating: 4.7,
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
  group('MedicineCard', () {
    Widget card() => BlocProvider(
          create: (_) => CartCubit(),
          child: const SizedBox(
            width: 150,
            height: 268,
            child: MedicineCard(
              restaurant: _pharmacy,
              item: _mask,
              isFavorite: false,
              onFavorite: _noop,
              onTap: _noop,
            ),
          ),
        );

    testWidgets('shows rating + sale without overflow', (tester) async {
      await _pump(tester, Center(child: card()), size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      expect(find.text('Surgical Face Masks'), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);
      expect(find.textContaining('-30%'), findsOneWidget); // 3.5 off 5
    });

    testWidgets('holds up at a large text scale', (tester) async {
      await _pump(tester, Center(child: card()),
          size: const Size(320, 640), textScale: 1.3);
      expect(tester.takeException(), isNull);
    });
  });

  group('PharmacyProductScreen', () {
    Widget page() => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => CartCubit()),
            BlocProvider(create: (_) => FavoritesCubit(_StubAuthRepo())),
          ],
          child: const PharmacyProductScreen(
            args: PharmacyProductArgs(restaurant: _pharmacy, item: _mask),
          ),
        );

    testWidgets('renders rating, SKU and description', (tester) async {
      await _pump(tester, page(), size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      expect(find.text('Surgical Face Masks'), findsOneWidget);
      expect(find.textContaining('SKU'), findsOneWidget);
      expect(find.textContaining('4.7'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('holds up at a large text scale', (tester) async {
      await _pump(tester, page(), size: const Size(320, 640), textScale: 1.3);
      expect(tester.takeException(), isNull);
    });
  });

  group('medicine request sheet (mock)', () {
    testWidgets('send is gated until a photo is attached', (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showMedicineRequestSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
        size: const Size(320, 640),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Before attaching: the CTA prompts to attach and is disabled.
      expect(find.text('Attach a photo to continue'), findsOneWidget);
      expect(find.textContaining('no photo is uploaded'), findsOneWidget);

      await tester.tap(find.text('Add a photo'));
      await tester.pump();

      // After attaching: it flips to a sendable state.
      expect(find.text('Send request'), findsOneWidget);
      expect(find.text('prescription.jpg'), findsOneWidget);
    });
  });
}

void _noop() {}

/// Unbound FavoritesCubit never touches its repo — a throwing stub suffices.
class _StubAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
