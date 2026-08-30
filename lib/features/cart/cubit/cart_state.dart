import 'dart:math';

import 'package:equatable/equatable.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/models/neighborhood.dart';
import '../../../core/models/order.dart';
import '../../../core/models/restaurant.dart';

/// The active cart. One restaurant at a time (adding from another replaces it).
class CartState extends Equatable {
  const CartState({
    this.restaurant,
    this.items = const [],
    this.ecoEnabled = false,
    this.bundleSize = 0,
    this.isPlus = false,
    this.appliedDeal,
  });

  final Restaurant? restaurant;
  final List<OrderItem> items;
  final bool ecoEnabled;
  final int bundleSize; // simulated nearby orders when eco is on

  /// Whether SwiftDrop Plus is active. Pushed in from AuthCubit (see app.dart)
  /// so every money figure below — and the order the checkout builds from them —
  /// comes from one place rather than each screen re-deciding.
  final bool isPlus;

  /// The Passport deal applied to this cart, if any.
  ///
  /// The *deal* is held rather than a fixed discount amount, because a discount
  /// computed at apply-time goes stale the moment the cart changes: a 20% deal
  /// worth 4 TND on a 20 TND cart must not still take 4 TND off after the user
  /// removes half of it. Holding the rule and recomputing keeps the figure true.
  final PassportDeal? appliedDeal;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);

  /// The restaurant's fee before the Plus waiver — shown struck through.
  double get baseDeliveryFee => restaurant?.deliveryFeeTND ?? 0;

  /// Plus waives delivery entirely; the order is then persisted with a fee of 0
  /// rather than a fee plus a discount line, which keeps the totals arithmetic
  /// in firestore.rules unchanged.
  double get deliveryFee => isPlus ? 0 : baseDeliveryFee;

  /// What Plus saved on this cart (0 when not subscribed).
  double get plusSavings => isPlus ? baseDeliveryFee : 0;

  String get promoCode => appliedDeal?.code ?? '';
  bool get hasPromo => appliedDeal != null && promoDiscount > 0;

  /// What the order is worth before any discount.
  double get orderValue => subtotal + deliveryFee;

  /// Flat eco discount, never more than the order value (resolves SPEC §3).
  double get ecoDiscount {
    if (!ecoEnabled) return 0;
    return min(EcoConfig.discountTND, orderValue);
  }

  /// The promo, recomputed against the current cart and taking only what Eco
  /// left behind.
  ///
  /// firestore.rules rejects an order whose discounts exceed its value, so the
  /// stack has to be clamped here too — otherwise a large percentage deal on a
  /// small eco order would be refused at write time with an opaque
  /// permission-denied.
  double get promoDiscount {
    final deal = appliedDeal;
    if (deal == null) return 0;
    final raw = deal.discountFor(subtotal: subtotal, deliveryFee: deliveryFee);
    return min(raw, max(0, orderValue - ecoDiscount));
  }

  double get total => max(0, orderValue - ecoDiscount - promoDiscount);

  double get co2Saved =>
      ecoEnabled ? EcoConfig.co2GramsPerBundledOrder * bundleSize : 0;

  CartState copyWith({
    Restaurant? restaurant,
    List<OrderItem>? items,
    bool? ecoEnabled,
    int? bundleSize,
    bool? isPlus,
    PassportDeal? appliedDeal,
    bool clearDeal = false,
  }) =>
      CartState(
        restaurant: restaurant ?? this.restaurant,
        items: items ?? this.items,
        ecoEnabled: ecoEnabled ?? this.ecoEnabled,
        bundleSize: bundleSize ?? this.bundleSize,
        isPlus: isPlus ?? this.isPlus,
        appliedDeal: clearDeal ? null : (appliedDeal ?? this.appliedDeal),
      );

  @override
  List<Object?> get props =>
      [restaurant, items, ecoEnabled, bundleSize, isPlus, appliedDeal];
}
