import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'order.dart';

enum GroupStatus {
  open, // accepting participants & items
  locked, // host locked it, ready to checkout
  ordered; // order placed

  String get wire => name;

  static GroupStatus fromWire(String? v) =>
      GroupStatus.values.firstWhere((s) => s.name == v,
          orElse: () => GroupStatus.open);
}

/// One member of a group order and the items they added.
class GroupParticipant extends Equatable {
  const GroupParticipant({
    required this.userId,
    required this.name,
    this.items = const [],
    this.isHost = false,
  });

  final String userId;
  final String name;
  final List<OrderItem> items;
  final bool isHost;

  double get subtotal => items.fold(0, (acc, i) => acc + i.lineTotal);

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'isHost': isHost,
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
      };

  factory GroupParticipant.fromMap(Map<String, dynamic> map) =>
      GroupParticipant(
        userId: map['userId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        isHost: map['isHost'] as bool? ?? false,
        items: (map['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  GroupParticipant copyWith({List<OrderItem>? items}) => GroupParticipant(
        userId: userId,
        name: name,
        isHost: isHost,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [userId, name, isHost, items];
}

/// A shared cart session at /groupOrders/{id}.
class GroupOrder extends Equatable {
  const GroupOrder({
    required this.id,
    required this.hostUserId,
    required this.restaurantId,
    required this.restaurantName,
    required this.deliveryFeeTND,
    required this.shareCode,
    this.participants = const [],
    this.status = GroupStatus.open,
    this.placedOrderId,
    this.createdAt,
  });

  final String id;
  final String hostUserId;
  final String restaurantId;
  final String restaurantName;
  final double deliveryFeeTND;
  final String shareCode;
  final List<GroupParticipant> participants;
  final GroupStatus status;
  final String? placedOrderId;
  final DateTime? createdAt;

  double get itemsSubtotal =>
      participants.fold(0, (acc, p) => acc + p.subtotal);

  int get participantCount => participants.length;

  /// Equal split of the single delivery fee (resolves SPEC §2).
  double get feeSharePerPerson =>
      participantCount == 0 ? deliveryFeeTND : deliveryFeeTND / participantCount;

  double get grandTotal => itemsSubtotal + deliveryFeeTND;

  GroupParticipant? participant(String userId) {
    for (final p in participants) {
      if (p.userId == userId) return p;
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'hostUserId': hostUserId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'deliveryFeeTND': deliveryFeeTND,
        'shareCode': shareCode,
        'participants': participants.map((p) => p.toMap()).toList(),
        'status': status.wire,
        'placedOrderId': placedOrderId,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  factory GroupOrder.fromMap(Map<String, dynamic> map) => GroupOrder(
        id: map['id'] as String? ?? '',
        hostUserId: map['hostUserId'] as String? ?? '',
        restaurantId: map['restaurantId'] as String? ?? '',
        restaurantName: map['restaurantName'] as String? ?? '',
        deliveryFeeTND: (map['deliveryFeeTND'] as num?)?.toDouble() ?? 0,
        shareCode: map['shareCode'] as String? ?? '',
        participants: (map['participants'] as List<dynamic>? ?? [])
            .map((e) =>
                GroupParticipant.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        status: GroupStatus.fromWire(map['status'] as String?),
        placedOrderId: map['placedOrderId'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      );

  @override
  List<Object?> get props => [id, status, participants, placedOrderId];
}
