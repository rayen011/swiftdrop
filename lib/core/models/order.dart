import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../utils/order_timeline.dart';
import 'address.dart';
import 'order_status.dart';
import 'payment_method.dart';

/// A single line in a cart/order. Reused for cart lines and persisted order items.
/// [priceTND] is the unit price including any selected option extras.
class OrderItem extends Equatable {
  const OrderItem({
    required this.menuItemId,
    required this.name,
    required this.priceTND,
    this.quantity = 1,
    this.selectedOptions = const {},
    this.specialInstructions = '',
  });

  final String menuItemId;
  final String name;
  final double priceTND;
  final int quantity;
  final Map<String, String> selectedOptions; // optionLabel -> choiceName
  final String specialInstructions;

  double get lineTotal => priceTND * quantity;

  OrderItem copyWith({int? quantity}) => OrderItem(
        menuItemId: menuItemId,
        name: name,
        priceTND: priceTND,
        quantity: quantity ?? this.quantity,
        selectedOptions: selectedOptions,
        specialInstructions: specialInstructions,
      );

  Map<String, dynamic> toMap() => {
        'menuItemId': menuItemId,
        'name': name,
        'priceTND': priceTND,
        'quantity': quantity,
        'selectedOptions': selectedOptions,
        'specialInstructions': specialInstructions,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        menuItemId: map['menuItemId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        priceTND: (map['priceTND'] as num?)?.toDouble() ?? 0,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        selectedOptions:
            Map<String, String>.from(map['selectedOptions'] as Map? ?? {}),
        specialInstructions: map['specialInstructions'] as String? ?? '',
      );

  @override
  List<Object?> get props =>
      [menuItemId, quantity, selectedOptions, specialInstructions];
}

/// A placed order at /orders/{id}. Named [AppOrder] to avoid a clash with
/// cloud_firestore's exported [Order] type.
class AppOrder extends Equatable {
  const AppOrder({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotalTND,
    required this.deliveryFeeTND,
    required this.totalTND,
    required this.deliveryAddress,
    required this.neighborhoodId,
    this.status = OrderStatus.pending,
    this.paymentMethod = PaymentMethod.cash,
    this.promoCode = '',
    this.promoDiscountTND = 0,
    this.ecoDiscountTND = 0,
    this.isEcoOrder = false,
    this.co2SavedGrams = 0,
    this.isGroupOrder = false,
    this.groupOrderId,
    this.driverId,
    this.driverLat,
    this.driverLng,
    this.placedAt,
    this.deliveredAt,
  });

  final String id;
  final String customerId;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final double subtotalTND;
  final double deliveryFeeTND;
  final double ecoDiscountTND;

  /// Passport deal code applied to this order ('' when none). Doubles as the
  /// redemption ledger: [UserStats] counts these to enforce a deal's
  /// maxRedemptions, so no separate counter can drift.
  final String promoCode;
  final double promoDiscountTND;

  final double totalTND;
  final OrderStatus status;

  /// Always settled on delivery — SwiftDrop charges nothing in-app.
  final PaymentMethod paymentMethod;
  final bool isEcoOrder;
  final double co2SavedGrams;
  final bool isGroupOrder;
  final String? groupOrderId;
  final Address deliveryAddress;
  final String? driverId;
  final double? driverLat;
  final double? driverLng;
  final DateTime? placedAt;
  final DateTime? deliveredAt;
  final String neighborhoodId;

  /// The order's real status, derived from the server-stamped [placedAt]
  /// (see [OrderTimeline]). The stored [status] is only a seed value written at
  /// creation; it wins only when the order is terminal or not yet server-ack'd.
  ///
  /// Prefer this over [status] everywhere in the UI.
  OrderStatus liveStatus({DateTime? now}) {
    if (status == OrderStatus.cancelled) return OrderStatus.cancelled;
    final at = placedAt;
    if (at == null) return status;
    return OrderTimeline.statusAt(at, now: now);
  }

  /// True once the delivery timeline has fully elapsed. Drives stamp / CO₂
  /// accounting, which is why it must never be a client-writable flag.
  bool isDelivered({DateTime? now}) =>
      liveStatus(now: now) == OrderStatus.delivered;

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerId': customerId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'items': items.map((i) => i.toMap()).toList(),
        'subtotalTND': subtotalTND,
        'deliveryFeeTND': deliveryFeeTND,
        'ecoDiscountTND': ecoDiscountTND,
        'promoCode': promoCode,
        'promoDiscountTND': promoDiscountTND,
        'totalTND': totalTND,
        'status': status.wire,
        'paymentMethod': paymentMethod.wire,
        'isEcoOrder': isEcoOrder,
        'co2SavedGrams': co2SavedGrams,
        'isGroupOrder': isGroupOrder,
        'groupOrderId': groupOrderId,
        'deliveryAddress': deliveryAddress.toMap(),
        'driverId': driverId,
        'driverLat': driverLat,
        'driverLng': driverLng,
        'placedAt': placedAt != null
            ? Timestamp.fromDate(placedAt!)
            : FieldValue.serverTimestamp(),
        'deliveredAt':
            deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
        'neighborhoodId': neighborhoodId,
      };

  factory AppOrder.fromMap(Map<String, dynamic> map) => AppOrder(
        id: map['id'] as String? ?? '',
        customerId: map['customerId'] as String? ?? '',
        restaurantId: map['restaurantId'] as String? ?? '',
        restaurantName: map['restaurantName'] as String? ?? '',
        items: (map['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        subtotalTND: (map['subtotalTND'] as num?)?.toDouble() ?? 0,
        deliveryFeeTND: (map['deliveryFeeTND'] as num?)?.toDouble() ?? 0,
        ecoDiscountTND: (map['ecoDiscountTND'] as num?)?.toDouble() ?? 0,
        promoCode: map['promoCode'] as String? ?? '',
        promoDiscountTND: (map['promoDiscountTND'] as num?)?.toDouble() ?? 0,
        totalTND: (map['totalTND'] as num?)?.toDouble() ?? 0,
        status: OrderStatus.fromWire(map['status'] as String?),
        paymentMethod: PaymentMethod.fromWire(map['paymentMethod'] as String?),
        isEcoOrder: map['isEcoOrder'] as bool? ?? false,
        co2SavedGrams: (map['co2SavedGrams'] as num?)?.toDouble() ?? 0,
        isGroupOrder: map['isGroupOrder'] as bool? ?? false,
        groupOrderId: map['groupOrderId'] as String?,
        deliveryAddress: Address.fromMap(
            Map<String, dynamic>.from(map['deliveryAddress'] as Map? ?? {})),
        driverId: map['driverId'] as String?,
        driverLat: (map['driverLat'] as num?)?.toDouble(),
        driverLng: (map['driverLng'] as num?)?.toDouble(),
        placedAt: (map['placedAt'] as Timestamp?)?.toDate(),
        deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
        neighborhoodId: map['neighborhoodId'] as String? ?? '',
      );

  /// Returns a copy with the Firestore-generated document id set.
  AppOrder copyWithId(String newId) => AppOrder(
        id: newId,
        customerId: customerId,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: items,
        subtotalTND: subtotalTND,
        deliveryFeeTND: deliveryFeeTND,
        ecoDiscountTND: ecoDiscountTND,
        promoCode: promoCode,
        promoDiscountTND: promoDiscountTND,
        totalTND: totalTND,
        status: status,
        paymentMethod: paymentMethod,
        isEcoOrder: isEcoOrder,
        co2SavedGrams: co2SavedGrams,
        isGroupOrder: isGroupOrder,
        groupOrderId: groupOrderId,
        deliveryAddress: deliveryAddress,
        driverId: driverId,
        driverLat: driverLat,
        driverLng: driverLng,
        placedAt: placedAt,
        deliveredAt: deliveredAt,
        neighborhoodId: neighborhoodId,
      );

  AppOrder copyWith({
    OrderStatus? status,
    String? driverId,
    double? driverLat,
    double? driverLng,
    DateTime? deliveredAt,
  }) =>
      AppOrder(
        id: id,
        customerId: customerId,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: items,
        subtotalTND: subtotalTND,
        deliveryFeeTND: deliveryFeeTND,
        ecoDiscountTND: ecoDiscountTND,
        promoCode: promoCode,
        promoDiscountTND: promoDiscountTND,
        totalTND: totalTND,
        status: status ?? this.status,
        paymentMethod: paymentMethod,
        isEcoOrder: isEcoOrder,
        co2SavedGrams: co2SavedGrams,
        isGroupOrder: isGroupOrder,
        groupOrderId: groupOrderId,
        deliveryAddress: deliveryAddress,
        driverId: driverId ?? this.driverId,
        driverLat: driverLat ?? this.driverLat,
        driverLng: driverLng ?? this.driverLng,
        placedAt: placedAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
        neighborhoodId: neighborhoodId,
      );

  @override
  List<Object?> get props => [id, status, driverLat, driverLng];
}
