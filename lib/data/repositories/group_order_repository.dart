import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/group_order.dart';
import '../../core/models/order.dart';
import '../../core/models/restaurant.dart';

/// Manages shared group-order sessions at /groupOrders/{id}.
class GroupOrderRepository {
  GroupOrderRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('groupOrders');

  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  String _generateCode() {
    final rng = Random();
    return List.generate(6, (_) => _codeChars[rng.nextInt(_codeChars.length)])
        .join();
  }

  /// Host starts a group for [restaurant]; they're added as the first member.
  Future<GroupOrder> createGroup({
    required String hostUserId,
    required String hostName,
    required Restaurant restaurant,
  }) async {
    final ref = _groups.doc();
    final group = GroupOrder(
      id: ref.id,
      hostUserId: hostUserId,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      deliveryFeeTND: restaurant.deliveryFeeTND,
      shareCode: _generateCode(),
      participants: [
        GroupParticipant(userId: hostUserId, name: hostName, isHost: true),
      ],
      createdAt: DateTime.now(),
    );
    await ref.set(group.toMap());
    return group;
  }

  Future<GroupOrder?> findByShareCode(String code) async {
    final snap = await _groups
        .where('shareCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return GroupOrder.fromMap(snap.docs.first.data());
  }

  Stream<GroupOrder?> watchGroup(String groupId) => _groups
      .doc(groupId)
      .snapshots()
      .map((doc) => doc.exists ? GroupOrder.fromMap(doc.data()!) : null);

  /// Adds a participant if not already present (idempotent on re-join).
  Future<void> joinGroup({
    required String groupId,
    required String userId,
    required String name,
  }) {
    return _db.runTransaction((txn) async {
      final ref = _groups.doc(groupId);
      final snap = await txn.get(ref);
      if (!snap.exists) return;
      final group = GroupOrder.fromMap(snap.data()!);
      if (group.participant(userId) != null) return;
      final updated = [
        ...group.participants,
        GroupParticipant(userId: userId, name: name),
      ];
      txn.update(ref, {
        'participants': updated.map((p) => p.toMap()).toList(),
      });
    });
  }

  /// Replaces a single participant's items (used as they add/remove).
  Future<void> updateParticipantItems({
    required String groupId,
    required String userId,
    required List<OrderItem> items,
  }) {
    return _db.runTransaction((txn) async {
      final ref = _groups.doc(groupId);
      final snap = await txn.get(ref);
      if (!snap.exists) return;
      final group = GroupOrder.fromMap(snap.data()!);
      final updated = group.participants
          .map((p) => p.userId == userId ? p.copyWith(items: items) : p)
          .toList();
      txn.update(ref, {
        'participants': updated.map((p) => p.toMap()).toList(),
      });
    });
  }

  Future<void> lockGroup(String groupId) =>
      _groups.doc(groupId).update({'status': GroupStatus.locked.wire});

  Future<void> reopenGroup(String groupId) =>
      _groups.doc(groupId).update({'status': GroupStatus.open.wire});

  Future<void> markOrdered(String groupId, String orderId) =>
      _groups.doc(groupId).update({
        'status': GroupStatus.ordered.wire,
        'placedOrderId': orderId,
      });
}
