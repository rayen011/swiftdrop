import '../constants/app_config.dart';
import '../models/order_status.dart';

/// Projects an order's place-time onto the mock delivery timeline (SPEC §1).
///
/// The simulation is a pure function of elapsed time, so status is *derived*
/// rather than stored-and-advanced. Two consequences that matter:
///
///  * An order can't be stranded. The old timer-driven cubit wrote each
///    transition from the client, so backgrounding the app mid-order left the
///    document parked on whatever status it had reached. Recomputing from
///    `placedAt` gives the right answer whenever anyone next looks.
///  * Clients need no write access to `/orders` after create, which is what
///    lets firestore.rules deny order updates outright.
abstract final class OrderTimeline {
  /// Status after [elapsed] has passed since the order was placed.
  static OrderStatus statusAfter(Duration elapsed) {
    if (elapsed >= DemoTimings.toDelivered) return OrderStatus.delivered;
    if (elapsed >= DemoTimings.toOnTheWay) return OrderStatus.onTheWay;
    if (elapsed >= DemoTimings.toPickedUp) return OrderStatus.pickedUp;
    if (elapsed >= DemoTimings.toPreparing) return OrderStatus.preparing;
    return OrderStatus.confirmed;
  }

  /// Status of an order placed at [placedAt], as of [now] (defaults to wall clock).
  static OrderStatus statusAt(DateTime placedAt, {DateTime? now}) =>
      statusAfter((now ?? DateTime.now()).difference(placedAt));

  /// Driver-pin progress (0..1) from the restaurant to the delivery address.
  /// Stays at 0 before the en-route window opens and 1 once it closes.
  static double routeProgressAt(DateTime placedAt, {DateTime? now}) {
    final intoRoute =
        (now ?? DateTime.now()).difference(placedAt) - DemoTimings.toOnTheWay;
    if (intoRoute <= Duration.zero) return 0;

    final window = DemoTimings.enRouteWindow.inMicroseconds;
    if (window <= 0) return 1;
    return (intoRoute.inMicroseconds / window).clamp(0.0, 1.0);
  }

  /// Time left until delivery, or [Duration.zero] once delivered.
  static Duration remainingAt(DateTime placedAt, {DateTime? now}) {
    final left =
        DemoTimings.toDelivered - (now ?? DateTime.now()).difference(placedAt);
    return left.isNegative ? Duration.zero : left;
  }
}
