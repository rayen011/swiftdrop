import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/address.dart';
import 'package:swiftdrop/core/models/order.dart';
import 'package:swiftdrop/core/models/order_status.dart';
import 'package:swiftdrop/core/models/user_stats.dart';

const _address = Address(
  id: 'addr_1',
  label: 'Home',
  lat: 36.83,
  lng: 10.24,
  fullAddress: 'Lac 2, Tunis',
);

final _now = DateTime(2026, 7, 14, 12, 0);

/// An order placed [secondsAgo] before [_now]; >40s ago means delivered.
AppOrder _order({
  required String id,
  required int secondsAgo,
  String neighborhoodId = 'lac2',
  double co2 = 0,
  bool eco = false,
  OrderStatus status = OrderStatus.pending,
  String promoCode = '',
}) =>
    AppOrder(
      id: id,
      customerId: 'user_1',
      restaurantId: 'resto_1',
      restaurantName: 'Chez Test',
      items: const [OrderItem(menuItemId: 'm1', name: 'Pizza', priceTND: 12)],
      subtotalTND: 12,
      deliveryFeeTND: 2,
      totalTND: 14,
      status: status,
      isEcoOrder: eco,
      co2SavedGrams: co2,
      promoCode: promoCode,
      deliveryAddress: _address,
      neighborhoodId: neighborhoodId,
      placedAt: _now.subtract(Duration(seconds: secondsAgo)),
    );

void main() {
  group('UserStats.fromOrders', () {
    test('is empty for no orders', () {
      final stats = UserStats.fromOrders(const [], now: _now);

      expect(stats.totalOrders, 0);
      expect(stats.totalCo2Saved, 0);
      expect(stats.totalStamps, 0);
      expect(stats.zonesVisited, 0);
    });

    test('ignores orders still in flight', () {
      final stats = UserStats.fromOrders([
        _order(id: 'o1', secondsAgo: 5), // confirmed
        _order(id: 'o2', secondsAgo: 30), // on the way
      ], now: _now);

      expect(stats.totalOrders, 0);
      expect(stats.totalStamps, 0);
    });

    test('counts a delivered order once the clock has run out', () {
      final stats = UserStats.fromOrders([
        _order(id: 'o1', secondsAgo: 41),
      ], now: _now);

      expect(stats.totalOrders, 1);
      expect(stats.stampsIn('lac2'), 1);
    });

    test('sums CO2 across delivered eco orders only', () {
      final stats = UserStats.fromOrders([
        _order(id: 'o1', secondsAgo: 100, eco: true, co2: 140),
        _order(id: 'o2', secondsAgo: 100, eco: true, co2: 210),
        _order(id: 'o3', secondsAgo: 100), // non-eco, contributes 0
        _order(id: 'o4', secondsAgo: 5, eco: true, co2: 210), // undelivered
      ], now: _now);

      expect(stats.totalOrders, 3);
      expect(stats.totalCo2Saved, 350);
    });

    test('stamps accumulate per neighborhood', () {
      final stats = UserStats.fromOrders([
        _order(id: 'o1', secondsAgo: 100, neighborhoodId: 'lac2'),
        _order(id: 'o2', secondsAgo: 100, neighborhoodId: 'lac2'),
        _order(id: 'o3', secondsAgo: 100, neighborhoodId: 'carthage'),
      ], now: _now);

      expect(stats.stampsIn('lac2'), 2);
      expect(stats.stampsIn('carthage'), 1);
      expect(stats.stampsIn('bardo'), 0);
      expect(stats.totalStamps, 3);
      expect(stats.zonesVisited, 2);
    });

    test('skips orders with no neighborhood but still counts them', () {
      final stats = UserStats.fromOrders([
        _order(id: 'o1', secondsAgo: 100, neighborhoodId: ''),
      ], now: _now);

      expect(stats.totalOrders, 1);
      expect(stats.totalStamps, 0);
      expect(stats.zonesVisited, 0);
    });

    test('a cancelled order never counts, however old', () {
      final stats = UserStats.fromOrders([
        _order(id: 'o1', secondsAgo: 9999, status: OrderStatus.cancelled),
      ], now: _now);

      expect(stats.totalOrders, 0);
      expect(stats.totalStamps, 0);
    });
  });

  group('promo redemptions', () {
    test('are zero when no code was used', () {
      final stats = UserStats.fromOrders([
        _order(id: 'o1', secondsAgo: 100),
      ], now: _now);

      expect(stats.redemptionsOf('LAC2-20'), 0);
    });

    test('count from placement, not delivery', () {
      // A single-use code must be spent the moment it is used. Counting only
      // delivered orders would leave a 40-second window in which the same code
      // could be applied to several orders at once.
      final stats = UserStats.fromOrders([
        _order(id: 'o1', secondsAgo: 2, promoCode: 'LAC2-20'), // in flight
      ], now: _now);

      expect(stats.redemptionsOf('LAC2-20'), 1);
      expect(stats.totalOrders, 0); // not delivered yet
    });

    test('accumulate per code', () {
      final stats = UserStats.fromOrders([
        _order(id: 'o1', secondsAgo: 100, promoCode: 'BARDOFREE'),
        _order(id: 'o2', secondsAgo: 100, promoCode: 'BARDOFREE'),
        _order(id: 'o3', secondsAgo: 100, promoCode: 'LAC2-20'),
      ], now: _now);

      expect(stats.redemptionsOf('BARDOFREE'), 2);
      expect(stats.redemptionsOf('LAC2-20'), 1);
    });

    test('a cancelled order releases its redemption', () {
      final stats = UserStats.fromOrders([
        _order(
          id: 'o1',
          secondsAgo: 100,
          promoCode: 'LAC2-20',
          status: OrderStatus.cancelled,
        ),
      ], now: _now);

      expect(stats.redemptionsOf('LAC2-20'), 0);
    });
  });
}
