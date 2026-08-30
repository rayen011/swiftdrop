import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/constants/app_config.dart';
import 'package:swiftdrop/core/models/order_status.dart';
import 'package:swiftdrop/core/utils/order_timeline.dart';

void main() {
  group('OrderTimeline.statusAfter', () {
    test('walks the SPEC §1 timeline in order', () {
      expect(OrderTimeline.statusAfter(Duration.zero), OrderStatus.confirmed);
      expect(OrderTimeline.statusAfter(const Duration(seconds: 7)),
          OrderStatus.confirmed);
      expect(OrderTimeline.statusAfter(const Duration(seconds: 8)),
          OrderStatus.preparing);
      expect(OrderTimeline.statusAfter(const Duration(seconds: 16)),
          OrderStatus.pickedUp);
      expect(OrderTimeline.statusAfter(const Duration(seconds: 24)),
          OrderStatus.onTheWay);
      expect(OrderTimeline.statusAfter(const Duration(seconds: 40)),
          OrderStatus.delivered);
    });

    test('stays delivered long after the window closes', () {
      expect(OrderTimeline.statusAfter(const Duration(days: 30)),
          OrderStatus.delivered);
    });

    test('treats a future placedAt as freshly confirmed rather than throwing', () {
      // Clock skew between the server stamp and the device shouldn't blow up.
      expect(OrderTimeline.statusAfter(const Duration(seconds: -5)),
          OrderStatus.confirmed);
    });

    test('each boundary is inclusive of the later status', () {
      expect(OrderTimeline.statusAfter(DemoTimings.toPreparing),
          OrderStatus.preparing);
      expect(OrderTimeline.statusAfter(
              DemoTimings.toPreparing - const Duration(microseconds: 1)),
          OrderStatus.confirmed);
    });
  });

  group('OrderTimeline.statusAt', () {
    test('derives from wall-clock distance to placedAt', () {
      final now = DateTime(2026, 7, 14, 12, 0, 30);
      final placedAt = now.subtract(const Duration(seconds: 30));

      expect(OrderTimeline.statusAt(placedAt, now: now), OrderStatus.onTheWay);
    });

    test('an order placed before the app closed resumes at the right step', () {
      // The old timer-driven cubit would have stranded this at `confirmed`.
      final now = DateTime(2026, 7, 14, 12, 5);
      final placedAt = now.subtract(const Duration(minutes: 5));

      expect(OrderTimeline.statusAt(placedAt, now: now), OrderStatus.delivered);
    });
  });

  group('OrderTimeline.routeProgressAt', () {
    final now = DateTime(2026, 7, 14, 12, 0);
    DateTime placedSecondsAgo(int s) => now.subtract(Duration(seconds: s));

    test('is 0 before the en-route window opens', () {
      expect(OrderTimeline.routeProgressAt(placedSecondsAgo(0), now: now), 0);
      expect(OrderTimeline.routeProgressAt(placedSecondsAgo(23), now: now), 0);
    });

    test('interpolates across the en-route window', () {
      // 24s = window opens, 40s = delivered, so 32s is the midpoint.
      expect(OrderTimeline.routeProgressAt(placedSecondsAgo(32), now: now),
          closeTo(0.5, 0.001));
    });

    test('clamps to 1 once delivered', () {
      expect(OrderTimeline.routeProgressAt(placedSecondsAgo(40), now: now), 1);
      expect(OrderTimeline.routeProgressAt(placedSecondsAgo(500), now: now), 1);
    });
  });

  group('OrderTimeline.remainingAt', () {
    final now = DateTime(2026, 7, 14, 12, 0);

    test('counts down to delivery', () {
      expect(
        OrderTimeline.remainingAt(now.subtract(const Duration(seconds: 10)),
            now: now),
        const Duration(seconds: 30),
      );
    });

    test('never goes negative', () {
      expect(
        OrderTimeline.remainingAt(now.subtract(const Duration(hours: 1)),
            now: now),
        Duration.zero,
      );
    });
  });
}
