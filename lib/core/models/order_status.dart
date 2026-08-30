/// Lifecycle of an order. Wire/serialized as snake_case strings in Firestore.
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  pickedUp,
  onTheWay,
  delivered,
  cancelled;

  String get wire => switch (this) {
        OrderStatus.pending => 'pending',
        OrderStatus.confirmed => 'confirmed',
        OrderStatus.preparing => 'preparing',
        OrderStatus.pickedUp => 'picked_up',
        OrderStatus.onTheWay => 'on_the_way',
        OrderStatus.delivered => 'delivered',
        OrderStatus.cancelled => 'cancelled',
      };

  static OrderStatus fromWire(String? value) => switch (value) {
        'confirmed' => OrderStatus.confirmed,
        'preparing' => OrderStatus.preparing,
        'picked_up' => OrderStatus.pickedUp,
        'on_the_way' => OrderStatus.onTheWay,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.pending,
      };

  /// Customer-facing label for the tracking timeline.
  String get label => switch (this) {
        OrderStatus.pending => 'Placing order',
        OrderStatus.confirmed => 'Order confirmed',
        OrderStatus.preparing => 'Preparing your food',
        OrderStatus.pickedUp => 'Driver picked up',
        OrderStatus.onTheWay => 'On the way',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };

  /// Ordered steps shown in the tracking timeline (excludes pending/cancelled).
  static const List<OrderStatus> timeline = [
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.pickedUp,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  int get step => timeline.indexOf(this);
}
