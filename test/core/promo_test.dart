import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/l10n/l10n.dart';
import 'package:swiftdrop/core/models/neighborhood.dart';
import 'package:swiftdrop/core/models/user_stats.dart';
import 'package:swiftdrop/core/utils/promo.dart';
import 'package:swiftdrop/l10n/gen/app_localizations_en.dart';
import 'package:swiftdrop/l10n/gen/app_localizations_fr.dart';

const _percentZone = PassportNeighborhood(
  id: 'lac2',
  name: 'Lac 2',
  city: 'Tunis',
  iconEmoji: '🛥️',
  deal: PassportDeal(
    type: DealType.percentOff,
    value: 20,
    code: 'LAC2-20',
    description: '20% off any order',
  ),
);

const _freeDeliveryZone = PassportNeighborhood(
  id: 'bardo',
  name: 'Le Bardo',
  city: 'Tunis',
  iconEmoji: '🕌',
  deal: PassportDeal(
    type: DealType.freeDelivery,
    value: 0,
    code: 'BARDOFREE',
    description: 'Free delivery, twice',
    maxRedemptions: 2,
  ),
);

const _zones = [_percentZone, _freeDeliveryZone];

/// Stamps enough to have earned every zone in [_zones].
const _earned = UserStats(stampCounts: {'lac2': 3, 'bardo': 3});

void main() {
  group('PassportDeal.discountFor', () {
    test('percent off applies to the subtotal, not the delivery fee', () {
      const deal = PassportDeal(
          type: DealType.percentOff, value: 20, code: 'X', description: '');
      expect(deal.discountFor(subtotal: 20, deliveryFee: 2.5), 4);
    });

    test('free delivery is worth exactly the fee', () {
      const deal = PassportDeal(
          type: DealType.freeDelivery, value: 0, code: 'X', description: '');
      expect(deal.discountFor(subtotal: 20, deliveryFee: 2.5), 2.5);
    });

    test('free delivery is worth nothing when delivery is already free', () {
      const deal = PassportDeal(
          type: DealType.freeDelivery, value: 0, code: 'X', description: '');
      expect(deal.discountFor(subtotal: 20, deliveryFee: 0), 0);
    });

    test('fixed off is capped at the order value', () {
      const deal = PassportDeal(
          type: DealType.fixedOff, value: 4, code: 'X', description: '');
      expect(deal.discountFor(subtotal: 20, deliveryFee: 2), 4);
      // Never hand back more than the order is worth.
      expect(deal.discountFor(subtotal: 1, deliveryFee: 0), 1);
    });
  });

  group('resolvePromo', () {
    test('accepts an earned code and prices it', () {
      final outcome = resolvePromo(
        code: 'LAC2-20',
        zones: _zones,
        stats: _earned,
        subtotal: 20,
        deliveryFee: 2.5,
      );

      expect(outcome, isA<PromoAccepted>());
      expect((outcome as PromoAccepted).discountTND, 4);
      expect(outcome.zone.id, 'lac2');
    });

    test('is case and whitespace insensitive', () {
      final outcome = resolvePromo(
        code: '  lac2-20 ',
        zones: _zones,
        stats: _earned,
        subtotal: 20,
        deliveryFee: 2.5,
      );
      expect(outcome, isA<PromoAccepted>());
    });

    test('rejects an unknown code', () {
      final outcome = resolvePromo(
        code: 'NOPE',
        zones: _zones,
        stats: _earned,
        subtotal: 20,
        deliveryFee: 2.5,
      );
      expect(outcome, isA<PromoRejected>());
      expect((outcome as PromoRejected).reason, PromoRejection.unknown);
    });

    test('rejects a code whose stamps are not collected', () {
      final outcome = resolvePromo(
        code: 'LAC2-20',
        zones: _zones,
        stats: const UserStats(stampCounts: {'lac2': 2}), // needs 3
        subtotal: 20,
        deliveryFee: 2.5,
      );
      expect((outcome as PromoRejected).reason, PromoRejection.notEarned);
      // The zone comes back so the copy can name it.
      expect(outcome.zone?.name, 'Lac 2');
    });

    test('rejects once the redemption cap is spent', () {
      final outcome = resolvePromo(
        code: 'BARDOFREE',
        zones: _zones,
        stats: const UserStats(
          stampCounts: {'bardo': 3},
          promoRedemptions: {'BARDOFREE': 2}, // cap is 2
        ),
        subtotal: 20,
        deliveryFee: 2.5,
      );
      expect((outcome as PromoRejected).reason, PromoRejection.exhausted);
    });

    test('allows a capped deal that still has uses left', () {
      final outcome = resolvePromo(
        code: 'BARDOFREE',
        zones: _zones,
        stats: const UserStats(
          stampCounts: {'bardo': 3},
          promoRedemptions: {'BARDOFREE': 1}, // one of two used
        ),
        subtotal: 20,
        deliveryFee: 2.5,
      );
      expect(outcome, isA<PromoAccepted>());
      expect((outcome as PromoAccepted).discountTND, 2.5);
    });

    test('rejects free delivery when Plus already waived the fee', () {
      // Otherwise a Plus member burns a limited redemption for nothing.
      final outcome = resolvePromo(
        code: 'BARDOFREE',
        zones: _zones,
        stats: _earned,
        subtotal: 20,
        deliveryFee: 0, // waived by Plus
      );
      expect((outcome as PromoRejected).reason, PromoRejection.noValue);
    });

    test('an unlimited deal never exhausts', () {
      const zone = PassportNeighborhood(
        id: 'x',
        name: 'X',
        city: 'Tunis',
        iconEmoji: '📍',
        deal: PassportDeal(
          type: DealType.percentOff,
          value: 10,
          code: 'FOREVER',
          description: '',
          maxRedemptions: 0,
        ),
      );
      final outcome = resolvePromo(
        code: 'FOREVER',
        zones: const [zone],
        stats: const UserStats(
          stampCounts: {'x': 3},
          promoRedemptions: {'FOREVER': 99},
        ),
        subtotal: 20,
        deliveryFee: 2,
      );
      expect(outcome, isA<PromoAccepted>());
    });
  });

  group('rejection copy', () {
    test('names the zone when the code is real but unearned', () {
      const rejection =
          PromoRejected(PromoRejection.notEarned, zone: _percentZone);
      expect(promoRejectionMessage(AppLocalizationsEn(), rejection),
          contains('Lac 2'));
      expect(promoRejectionMessage(AppLocalizationsFr(), rejection),
          contains('Lac 2'));
    });

    test('every reason has copy in every language', () {
      for (final l10n in [AppLocalizationsEn(), AppLocalizationsFr()]) {
        for (final reason in PromoRejection.values) {
          final message = promoRejectionMessage(
              l10n, PromoRejected(reason, zone: _percentZone));
          expect(message, isNotEmpty);
        }
      }
    });
  });
}
