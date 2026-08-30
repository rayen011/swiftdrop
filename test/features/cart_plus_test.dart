// Covers the money the subscription actually moves: Plus waives delivery, and
// Eco Bundle is refused to non-subscribers at the cubit rather than only being
// greyed out in the UI.

import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/neighborhood.dart';
import 'package:swiftdrop/core/models/order.dart';
import 'package:swiftdrop/core/models/restaurant.dart';
import 'package:swiftdrop/features/cart/cubit/cart_cubit.dart';

const _restaurant = Restaurant(
  id: 'resto_1',
  name: 'Le Grill du Lac',
  category: 'food',
  neighborhood: 'lac2',
  rating: 4.8,
  deliveryFeeTND: 2.5,
  estimatedMinutes: 25,
);

const _item = OrderItem(
  menuItemId: 'm1',
  name: 'Burger',
  priceTND: 10,
  quantity: 2, // subtotal = 20
);

void main() {
  group('delivery fee', () {
    test('a free user pays the restaurant fee', () {
      final cubit = CartCubit()..addItem(_restaurant, _item);

      expect(cubit.state.isPlus, isFalse);
      expect(cubit.state.deliveryFee, 2.5);
      expect(cubit.state.plusSavings, 0);
      expect(cubit.state.total, 22.5);
    });

    test('Plus waives it and reports the saving', () {
      final cubit = CartCubit()
        ..setPlusEntitlement(true)
        ..addItem(_restaurant, _item);

      expect(cubit.state.deliveryFee, 0);
      expect(cubit.state.baseDeliveryFee, 2.5); // still shown, struck through
      expect(cubit.state.plusSavings, 2.5);
      expect(cubit.state.total, 20);
    });
  });

  group('eco bundle gating', () {
    test('a free user cannot turn Eco on', () {
      final cubit = CartCubit()..addItem(_restaurant, _item);

      cubit.toggleEco(true);

      expect(cubit.state.ecoEnabled, isFalse);
      expect(cubit.state.ecoDiscount, 0);
      expect(cubit.state.co2Saved, 0);
      expect(cubit.state.total, 22.5);
    });

    test('a Plus user can, and gets the discount', () {
      final cubit = CartCubit()
        ..setPlusEntitlement(true)
        ..addItem(_restaurant, _item);

      cubit.toggleEco(true);

      expect(cubit.state.ecoEnabled, isTrue);
      expect(cubit.state.ecoDiscount, 1.5);
      expect(cubit.state.co2Saved, greaterThan(0));
      expect(cubit.state.total, 18.5); // 20 subtotal - 1.5, delivery waived
    });

    test('losing Plus drops Eco and its discount', () {
      final cubit = CartCubit()
        ..setPlusEntitlement(true)
        ..addItem(_restaurant, _item)
        ..toggleEco(true);
      expect(cubit.state.ecoEnabled, isTrue);

      // Expiry mid-cart must not leave a perk the user no longer has.
      cubit.setPlusEntitlement(false);

      expect(cubit.state.ecoEnabled, isFalse);
      expect(cubit.state.ecoDiscount, 0);
      expect(cubit.state.co2Saved, 0);
      expect(cubit.state.total, 22.5);
    });
  });

  group('passport deal', () {
    const percentDeal = PassportDeal(
      type: DealType.percentOff,
      value: 20,
      code: 'LAC2-20',
      description: '20% off any order',
    );

    test('applies against the current cart', () {
      final cubit = CartCubit()
        ..addItem(_restaurant, _item) // subtotal 20, delivery 2.5
        ..applyDeal(percentDeal);

      expect(cubit.state.hasPromo, isTrue);
      expect(cubit.state.promoCode, 'LAC2-20');
      expect(cubit.state.promoDiscount, 4); // 20% of 20
      expect(cubit.state.total, 18.5); // 20 + 2.5 - 4
    });

    test('re-prices when the cart changes', () {
      // The reason the deal is stored rather than a fixed amount: a discount
      // computed at apply-time would still take 4 TND off a halved cart.
      final cubit = CartCubit()
        ..addItem(_restaurant, _item)
        ..applyDeal(percentDeal);
      expect(cubit.state.promoDiscount, 4);

      cubit.changeQuantity(0, -1); // subtotal now 10

      expect(cubit.state.promoDiscount, 2); // 20% of 10, not 4
      expect(cubit.state.total, 10.5);
    });

    test('stacks with Eco without exceeding the order', () {
      final cubit = CartCubit()
        ..setPlusEntitlement(true)
        ..addItem(_restaurant, _item)
        ..toggleEco(true)
        ..applyDeal(percentDeal);

      // Delivery waived (Plus) -> order value 20. Eco 1.5, promo 20% of 20 = 4.
      expect(cubit.state.ecoDiscount, 1.5);
      expect(cubit.state.promoDiscount, 4);
      expect(cubit.state.total, 14.5);
    });

    test('the discount stack never exceeds the order value', () {
      // firestore.rules rejects an order whose discounts exceed its value, so
      // the cart must clamp rather than produce a write that gets denied.
      const bigDeal = PassportDeal(
        type: DealType.fixedOff,
        value: 500,
        code: 'HUGE',
        description: '',
      );
      final cubit = CartCubit()
        ..addItem(_restaurant, _item)
        ..toggleEco(false)
        ..applyDeal(bigDeal);

      expect(cubit.state.promoDiscount, 22.5); // clamped to order value
      expect(cubit.state.total, 0);
      expect(
        cubit.state.ecoDiscount + cubit.state.promoDiscount,
        lessThanOrEqualTo(cubit.state.orderValue),
      );
    });

    test('a free-delivery deal is worth nothing to a Plus member', () {
      const freeDelivery = PassportDeal(
        type: DealType.freeDelivery,
        value: 0,
        code: 'BARDOFREE',
        description: '',
      );
      final cubit = CartCubit()
        ..setPlusEntitlement(true)
        ..addItem(_restaurant, _item)
        ..applyDeal(freeDelivery);

      expect(cubit.state.promoDiscount, 0);
      // hasPromo is false, so checkout records no code and burns no redemption.
      expect(cubit.state.hasPromo, isFalse);
    });

    test('clearing removes it', () {
      final cubit = CartCubit()
        ..addItem(_restaurant, _item)
        ..applyDeal(percentDeal);

      cubit.clearDeal();

      expect(cubit.state.hasPromo, isFalse);
      expect(cubit.state.promoCode, '');
      expect(cubit.state.total, 22.5);
    });

    test('emptying the cart drops the deal', () {
      final cubit = CartCubit()
        ..addItem(_restaurant, _item)
        ..applyDeal(percentDeal);

      cubit.clear();

      expect(cubit.state.appliedDeal, isNull);
    });
  });

  group('entitlement survives cart churn', () {
    test('clear() keeps Plus — it belongs to the user, not the cart', () {
      final cubit = CartCubit()
        ..setPlusEntitlement(true)
        ..addItem(_restaurant, _item);

      cubit.clear();

      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.isPlus, isTrue);
    });

    test('emptying via quantity change keeps Plus', () {
      final cubit = CartCubit()
        ..setPlusEntitlement(true)
        ..addItem(_restaurant, _item);

      cubit.changeQuantity(0, -2); // removes the only line

      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.isPlus, isTrue);
    });

    test('reorder keeps Plus', () {
      final cubit = CartCubit()..setPlusEntitlement(true);

      cubit.replaceWith(_restaurant, const [_item]);

      expect(cubit.state.isPlus, isTrue);
      expect(cubit.state.deliveryFee, 0);
    });

    test('switching restaurant keeps Plus', () {
      final cubit = CartCubit()
        ..setPlusEntitlement(true)
        ..addItem(_restaurant, _item);

      cubit.addItem(
        const Restaurant(
          id: 'resto_2',
          name: 'Other',
          category: 'food',
          neighborhood: 'lac1',
          rating: 4,
          deliveryFeeTND: 3,
          estimatedMinutes: 30,
        ),
        _item,
      );

      expect(cubit.state.isPlus, isTrue);
      expect(cubit.state.deliveryFee, 0);
    });
  });
}
