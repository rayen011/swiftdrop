import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/l10n/l10n.dart';
import 'package:swiftdrop/core/models/address.dart';
import 'package:swiftdrop/core/models/order.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';
import 'package:swiftdrop/data/repositories/order_repository.dart';
import 'package:swiftdrop/features/home/presentation/widgets/order_again_row.dart';
import 'package:swiftdrop/features/orders/reorder.dart';

const _address = Address(
    id: 'a1', label: 'Home', lat: 36.8, lng: 10.2, fullAddress: 'Tunis');

/// Anchored to the real clock: the widget derives delivered-ness from
/// DateTime.now(), so fixture times must be genuinely in the past.
final _now = DateTime.now();

AppOrder _order({
  required String id,
  required String restaurantId,
  int minutesAgo = 60, // long delivered
  String name = 'Store',
}) =>
    AppOrder(
      id: id,
      customerId: 'u1',
      restaurantId: restaurantId,
      restaurantName: name,
      items: const [OrderItem(menuItemId: 'm', name: 'Thing', priceTND: 10)],
      subtotalTND: 10,
      deliveryFeeTND: 2,
      totalTND: 12,
      deliveryAddress: _address,
      neighborhoodId: 'lac2',
      placedAt: _now.subtract(Duration(minutes: minutesAgo)),
    );

class _FakeOrdersRepo implements OrderRepository {
  _FakeOrdersRepo(this.orders);
  final List<AppOrder> orders;

  @override
  Stream<List<AppOrder>> watchUserOrders(String customerId) =>
      Stream.value(orders);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('reorderCandidates', () {
    test('keeps only delivered orders', () {
      final candidates = reorderCandidates([
        _order(id: 'o1', restaurantId: 'r1', minutesAgo: 0), // in flight
        _order(id: 'o2', restaurantId: 'r2'),
      ], now: _now);

      expect(candidates.map((o) => o.id), ['o2']);
    });

    test('dedupes by restaurant, keeping the most recent', () {
      final candidates = reorderCandidates([
        _order(id: 'new_pizza', restaurantId: 'pizza', minutesAgo: 30),
        _order(id: 'old_pizza', restaurantId: 'pizza', minutesAgo: 300),
        _order(id: 'burger', restaurantId: 'burger', minutesAgo: 60),
      ], now: _now);

      expect(candidates.map((o) => o.id), ['new_pizza', 'burger']);
    });

    test('caps at the limit', () {
      final orders = [
        for (var i = 0; i < 10; i++)
          _order(id: 'o$i', restaurantId: 'r$i', minutesAgo: 60 + i),
      ];
      expect(reorderCandidates(orders, limit: 5, now: _now).length, 5);
    });
  });

  group('OrderAgainRow', () {
    Future<void> pump(WidgetTester tester, List<AppOrder> orders) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderAgainRow(uid: 'u1', repo: _FakeOrdersRepo(orders)),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('collapses entirely for a user with no delivered orders',
        (tester) async {
      await pump(tester, [
        _order(id: 'o1', restaurantId: 'r1', minutesAgo: 0), // still in flight
      ]);
      expect(find.text('Order again'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows one card per store with count and total',
        (tester) async {
      await pump(tester, [
        _order(id: 'o1', restaurantId: 'pizza', name: 'Dar El Pizza'),
        _order(
            id: 'o2',
            restaurantId: 'pizza',
            name: 'Dar El Pizza',
            minutesAgo: 300),
        _order(id: 'o3', restaurantId: 'burger', name: 'Burger Marsa'),
      ]);

      expect(find.text('Order again'), findsOneWidget);
      expect(find.text('Dar El Pizza'), findsOneWidget); // deduped
      expect(find.text('Burger Marsa'), findsOneWidget);
      expect(find.textContaining('1 item'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });
}
