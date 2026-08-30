import 'dart:math';

import 'package:equatable/equatable.dart';

/// What a Passport deal actually does to an order's price.
///
/// The deals used to be free text ("15% off any order"), which meant checkout
/// had no way to honour the code it told the user to type. The type + value pair
/// is what makes a deal computable; [PassportNeighborhood.dealDescription] stays
/// around purely as human copy.
enum DealType {
  /// [PassportDeal.value] percent off the items subtotal.
  percentOff,

  /// Waives the delivery fee. [PassportDeal.value] is ignored.
  freeDelivery,

  /// [PassportDeal.value] TND off the order.
  fixedOff;

  String get wire => switch (this) {
        DealType.percentOff => 'percent_off',
        DealType.freeDelivery => 'free_delivery',
        DealType.fixedOff => 'fixed_off',
      };

  static DealType fromWire(String? value) => switch (value) {
        'free_delivery' => DealType.freeDelivery,
        'fixed_off' => DealType.fixedOff,
        _ => DealType.percentOff,
      };
}

/// The reward behind a neighborhood's stamps.
class PassportDeal extends Equatable {
  const PassportDeal({
    required this.type,
    required this.value,
    required this.code,
    required this.description,
    this.maxRedemptions = 1,
  });

  final DealType type;
  final double value;
  final String code;

  /// Human copy shown on the Passport. Never parsed.
  final String description;

  /// How many times the code may be used. 0 means unlimited.
  ///
  /// Free-delivery deals must stay capped: an uncapped one would hand every
  /// user a permanent version of the headline SwiftDrop Plus perk and
  /// cannibalise the subscription.
  final int maxRedemptions;

  bool get isUnlimited => maxRedemptions == 0;

  /// The discount this deal is worth against a given order, never more than the
  /// order itself. Returns 0 when the deal can't bite (e.g. free delivery on an
  /// order whose delivery is already free).
  double discountFor({required double subtotal, required double deliveryFee}) {
    final raw = switch (type) {
      DealType.percentOff => subtotal * (value / 100),
      DealType.freeDelivery => deliveryFee,
      DealType.fixedOff => value,
    };
    return min(max(raw, 0), subtotal + deliveryFee);
  }

  Map<String, dynamic> toMap() => {
        'dealType': type.wire,
        'dealValue': value,
        'dealCode': code,
        'dealDescription': description,
        'dealMaxRedemptions': maxRedemptions,
      };

  @override
  List<Object?> get props => [type, value, code, maxRedemptions];
}

/// A Passport zone at /neighborhoods/{id}. Seeded once (resolves SPEC §4).
class PassportNeighborhood extends Equatable {
  const PassportNeighborhood({
    required this.id,
    required this.name,
    required this.city,
    required this.deal,
    required this.iconEmoji,
    this.requiredStamps = 3,
  });

  final String id;
  final String name;
  final String city;
  final int requiredStamps;
  final PassportDeal deal;
  final String iconEmoji;

  String get dealDescription => deal.description;
  String get dealCode => deal.code;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'city': city,
        'requiredStamps': requiredStamps,
        'iconEmoji': iconEmoji,
        ...deal.toMap(),
      };

  factory PassportNeighborhood.fromMap(Map<String, dynamic> map) =>
      PassportNeighborhood(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        city: map['city'] as String? ?? 'Tunis',
        requiredStamps: (map['requiredStamps'] as num?)?.toInt() ?? 3,
        iconEmoji: map['iconEmoji'] as String? ?? '📍',
        deal: PassportDeal(
          type: DealType.fromWire(map['dealType'] as String?),
          value: (map['dealValue'] as num?)?.toDouble() ?? 0,
          code: map['dealCode'] as String? ?? '',
          description: map['dealDescription'] as String? ?? '',
          maxRedemptions: (map['dealMaxRedemptions'] as num?)?.toInt() ?? 1,
        ),
      );

  @override
  List<Object?> get props => [id, name, city, deal];
}
