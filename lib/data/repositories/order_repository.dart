import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/order.dart';
import '../../core/models/user_stats.dart';

/// Creates and reads orders at /orders/{id}.
///
/// Orders are create-only by design. Status is derived from the server-stamped
/// `placedAt` (see [OrderTimeline]) rather than advanced by the client, so there
/// is deliberately no updateStatus / markDelivered here — firestore.rules denies
/// order updates outright.
class OrderRepository {
  OrderRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  /// Persists a new order and returns it with the generated id and the
  /// server-resolved `placedAt`.
  ///
  /// [order] must leave `placedAt` null so [AppOrder.toMap] emits a
  /// `serverTimestamp()` sentinel — rules require `placedAt == request.time`,
  /// so a client-supplied timestamp is rejected. The write-back read resolves
  /// that sentinel into a real value for the tracking screen to derive from.
  Future<AppOrder> placeOrder(AppOrder order) async {
    final ref = _orders.doc();
    final withId = order.copyWithId(ref.id);
    await ref.set(withId.toMap());

    final saved = await ref.get();
    return saved.exists ? AppOrder.fromMap(saved.data()!) : withId;
  }

  Stream<AppOrder?> watchOrder(String orderId) => _orders
      .doc(orderId)
      .snapshots()
      .map((doc) => doc.exists ? AppOrder.fromMap(doc.data()!) : null);

  Future<AppOrder?> fetchOrder(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    return doc.exists ? AppOrder.fromMap(doc.data()!) : null;
  }

  /// Sorted client-side (newest first) to avoid requiring a composite index.
  Stream<List<AppOrder>> watchUserOrders(String customerId) => _orders
      .where('customerId', isEqualTo: customerId)
      .snapshots()
      .map((snap) {
        final orders = snap.docs.map((d) => AppOrder.fromMap(d.data())).toList();
        orders.sort((a, b) => (b.placedAt ?? DateTime(0))
            .compareTo(a.placedAt ?? DateTime(0)));
        return orders;
      });

  /// One-shot [UserStats] for this user.
  ///
  /// Used where a decision is made once rather than rendered continuously —
  /// judging a promo code at checkout needs the stamps and redemptions as they
  /// stand at that moment, not a subscription to them.
  Future<UserStats> fetchUserStats(String customerId) async {
    final snap =
        await _orders.where('customerId', isEqualTo: customerId).get();
    return UserStats.fromOrders(
      snap.docs.map((d) => AppOrder.fromMap(d.data())).toList(),
    );
  }

  /// Live [UserStats] projected from this user's orders (see [UserStats]).
  ///
  /// Folds in a slow clock tick as well as the Firestore stream: an in-flight
  /// order crosses into `delivered` purely by elapsed time, with no document
  /// write to wake the snapshot listener. Without the tick, a stamp earned
  /// while the user sits on the Passport screen wouldn't appear until they
  /// navigated away and back. The tick only re-folds already-loaded orders in
  /// memory — it costs no reads — and stops once nothing is in flight.
  Stream<UserStats> watchUserStats(String customerId) {
    late final StreamController<UserStats> controller;
    StreamSubscription<List<AppOrder>>? subscription;
    Timer? ticker;
    var latest = const <AppOrder>[];

    void emit() {
      controller.add(UserStats.fromOrders(latest));
      if (latest.every((o) => o.isDelivered())) {
        ticker?.cancel();
        ticker = null;
      }
    }

    controller = StreamController<UserStats>(
      onListen: () {
        subscription = watchUserOrders(customerId).listen(
          (orders) {
            latest = orders;
            // A newly placed order restarts the clock.
            ticker ??= Timer.periodic(_statsTick, (_) => emit());
            emit();
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        ticker?.cancel();
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  static const _statsTick = Duration(seconds: 2);
}
