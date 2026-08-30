import 'package:equatable/equatable.dart';

import 'order.dart';
import 'order_status.dart';

/// A user's order / eco / passport totals, projected from their delivered orders.
///
/// These are deliberately *not* stored on the user document. A stored counter
/// has to be incremented by whoever completes the order, and on a client-driven
/// mock simulation that means the client — which lets anyone grant themselves
/// stamps and CO₂ without ordering. Deriving instead means there is no counter
/// to inflate: the only way to move these numbers is to create a real order and
/// wait out the delivery clock, which firestore.rules pins to the server.
class UserStats extends Equatable {
  const UserStats({
    this.totalOrders = 0,
    this.totalCo2Saved = 0,
    this.stampCounts = const {},
    this.promoRedemptions = const {},
  });

  static const empty = UserStats();

  final int totalOrders;
  final double totalCo2Saved; // grams saved via Eco Mode
  final Map<String, int> stampCounts; // neighborhoodId -> stamps earned there

  /// promo code -> times used. Counted from the orders that carry the code, so
  /// a deal's redemption cap needs no separate ledger to fall out of sync with
  /// what was actually ordered.
  final Map<String, int> promoRedemptions;

  /// Total stamps across all zones.
  int get totalStamps => stampCounts.values.fold(0, (acc, v) => acc + v);

  /// Number of distinct neighborhoods visited.
  int get zonesVisited => stampCounts.keys.length;

  int stampsIn(String neighborhoodId) => stampCounts[neighborhoodId] ?? 0;

  int redemptionsOf(String promoCode) => promoRedemptions[promoCode] ?? 0;

  /// Folds a user's orders into totals.
  ///
  /// Stamps and CO₂ count only *delivered* orders — the reward is for a
  /// completed delivery (SPEC §4). Promo redemptions deliberately count from the
  /// moment an order is *placed*: waiting for delivery would leave a 40-second
  /// window in which the same single-use code could be spent on several orders
  /// at once. Cancelled orders release their redemption.
  factory UserStats.fromOrders(List<AppOrder> orders, {DateTime? now}) {
    var totalOrders = 0;
    var totalCo2Saved = 0.0;
    final stampCounts = <String, int>{};
    final promoRedemptions = <String, int>{};

    for (final order in orders) {
      if (order.status != OrderStatus.cancelled && order.promoCode.isNotEmpty) {
        promoRedemptions[order.promoCode] =
            (promoRedemptions[order.promoCode] ?? 0) + 1;
      }

      if (!order.isDelivered(now: now)) continue;

      totalOrders++;
      totalCo2Saved += order.co2SavedGrams;
      if (order.neighborhoodId.isNotEmpty) {
        stampCounts[order.neighborhoodId] =
            (stampCounts[order.neighborhoodId] ?? 0) + 1;
      }
    }

    return UserStats(
      totalOrders: totalOrders,
      totalCo2Saved: totalCo2Saved,
      stampCounts: Map.unmodifiable(stampCounts),
      promoRedemptions: Map.unmodifiable(promoRedemptions),
    );
  }

  @override
  List<Object?> get props =>
      [totalOrders, totalCo2Saved, stampCounts, promoRedemptions];
}
