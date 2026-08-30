import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/models/neighborhood.dart';
import '../../../core/models/order.dart';
import '../../../core/models/restaurant.dart';
import 'cart_state.dart';

/// Holds the single active cart across the browse → checkout flow.
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  final _random = Random();

  /// Adds a line. If it belongs to a different restaurant, the cart resets.
  void addItem(Restaurant restaurant, OrderItem item) {
    final differentResto = state.restaurant?.id != restaurant.id;
    final items = differentResto ? <OrderItem>[] : List<OrderItem>.from(state.items);

    final existing = items.indexWhere((i) =>
        i.menuItemId == item.menuItemId &&
        _sameOptions(i.selectedOptions, item.selectedOptions) &&
        i.specialInstructions == item.specialInstructions);

    if (existing >= 0) {
      items[existing] =
          items[existing].copyWith(quantity: items[existing].quantity + item.quantity);
    } else {
      items.add(item);
    }

    emit(state.copyWith(
      restaurant: restaurant,
      items: items,
      ecoEnabled: differentResto ? false : state.ecoEnabled,
    ));
  }

  void changeQuantity(int index, int delta) {
    final items = List<OrderItem>.from(state.items);
    final next = items[index].quantity + delta;
    if (next <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: next);
    }
    if (items.isEmpty) {
      _emitEmpty();
    } else {
      emit(state.copyWith(items: items));
    }
  }

  /// Eco Bundle is a SwiftDrop Plus perk, so a non-subscriber turning it on is
  /// ignored here rather than only being blocked in the UI — the discount is a
  /// money figure, and it shouldn't depend on which screen asked for it.
  void toggleEco(bool enabled) {
    if (enabled && !state.isPlus) return;
    final bundleSize = enabled
        ? EcoConfig.minBundleSize +
            _random.nextInt(EcoConfig.maxBundleSize - EcoConfig.minBundleSize + 1)
        : 0;
    emit(state.copyWith(ecoEnabled: enabled, bundleSize: bundleSize));
  }

  /// Applies a Passport deal already validated by `resolvePromo`.
  void applyDeal(PassportDeal deal) => emit(state.copyWith(appliedDeal: deal));

  void clearDeal() => emit(state.copyWith(clearDeal: true));

  /// Mirrors the signed-in user's Plus entitlement into the cart (see app.dart).
  /// Losing Plus mid-cart also drops Eco, so the totals can't keep a perk the
  /// user is no longer entitled to.
  void setPlusEntitlement(bool isPlus) {
    if (isPlus == state.isPlus) return;
    emit(state.copyWith(
      isPlus: isPlus,
      ecoEnabled: isPlus && state.ecoEnabled,
      bundleSize: isPlus ? state.bundleSize : 0,
    ));
  }

  /// Replaces the whole cart in one shot (used by reorder).
  void replaceWith(Restaurant restaurant, List<OrderItem> items) => emit(
        CartState(
          restaurant: restaurant,
          items: List<OrderItem>.from(items),
          isPlus: state.isPlus,
        ),
      );

  void clear() => _emitEmpty();

  /// Empties the cart while keeping the entitlement — it belongs to the user,
  /// not to the cart, and a fresh `CartState()` would silently drop it.
  void _emitEmpty() => emit(CartState(isPlus: state.isPlus));

  bool _sameOptions(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }
}
