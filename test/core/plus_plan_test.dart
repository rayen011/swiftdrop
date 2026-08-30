import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/constants/plus_config.dart';
import 'package:swiftdrop/core/models/app_user.dart';
import 'package:swiftdrop/core/models/plus_plan.dart';

void main() {
  group('PlusPlan pricing', () {
    test('per-week price normalises across plan lengths', () {
      expect(PlusConfig.weekly.pricePerWeekTND, closeTo(6.99, 0.01));
      expect(PlusConfig.monthly.pricePerWeekTND, closeTo(4.66, 0.01));
      expect(PlusConfig.yearly.pricePerWeekTND, closeTo(1.73, 0.01));
    });

    test('longer plans are genuinely cheaper per week', () {
      // Guards the merchandising: a "BEST DEAL" badge must not sit on a plan
      // that costs more per week than the one next to it.
      expect(PlusConfig.yearly.pricePerWeekTND,
          lessThan(PlusConfig.monthly.pricePerWeekTND));
      expect(PlusConfig.monthly.pricePerWeekTND,
          lessThan(PlusConfig.weekly.pricePerWeekTND));
    });

    test('savings are derived from real prices', () {
      expect(PlusConfig.yearly.savingsPercentVersus(PlusConfig.anchor), 75);
      expect(PlusConfig.monthly.savingsPercentVersus(PlusConfig.anchor), 33);
    });

    test('the anchor plan advertises no saving against itself', () {
      expect(PlusConfig.weekly.savingsPercentVersus(PlusConfig.anchor), isNull);
    });

    test('entitlement includes the trial', () {
      expect(PlusConfig.weekly.entitlement, const Duration(days: 10)); // 3 + 7
      expect(PlusConfig.monthly.entitlement, const Duration(days: 30));
    });

    test('only the weekly plan carries a trial', () {
      expect(PlusConfig.weekly.hasTrial, isTrue);
      expect(PlusConfig.monthly.hasTrial, isFalse);
      expect(PlusConfig.yearly.hasTrial, isFalse);
    });
  });

  group('PlusPlanId wire format', () {
    test('round-trips', () {
      for (final id in PlusPlanId.values) {
        expect(PlusPlanId.fromWire(id.wire), id);
      }
    });

    test('an unknown id is null rather than a crash', () {
      expect(PlusPlanId.fromWire('lifetime'), isNull);
      expect(PlusPlanId.fromWire(null), isNull);
    });
  });

  group('AppUser.isPlus', () {
    final now = DateTime(2026, 7, 15, 12);
    AppUser userWith(DateTime? until) => AppUser(
          uid: 'u1',
          phone: '+21600000000',
          plusPlanId: until == null ? '' : 'weekly',
          plusUntil: until,
        );

    test('is false when never subscribed', () {
      expect(userWith(null).isPlus(now: now), isFalse);
      expect(userWith(null).activePlan, isNull);
    });

    test('is true while the entitlement is in the future', () {
      expect(
        userWith(now.add(const Duration(days: 1))).isPlus(now: now),
        isTrue,
      );
    });

    test('lapses on its own once the expiry passes', () {
      // The point of deriving from an expiry: nothing has to run to switch
      // Plus off, so it can never get stuck active.
      expect(
        userWith(now.subtract(const Duration(seconds: 1))).isPlus(now: now),
        isFalse,
      );
    });

    test('activePlan resolves only while active', () {
      final active = AppUser(
        uid: 'u1',
        phone: '+21600000000',
        plusPlanId: 'yearly',
        plusUntil: now.add(const Duration(days: 300)),
      );
      expect(active.activePlan, PlusPlanId.yearly);

      final lapsed = AppUser(
        uid: 'u1',
        phone: '+21600000000',
        plusPlanId: 'yearly',
        plusUntil: now.subtract(const Duration(days: 1)),
      );
      // Lapsed reads as no plan even though the id is still on the document.
      expect(lapsed.isPlus(now: now), isFalse);
    });
  });
}
