import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../core/di/service_locator.dart';
import '../../core/models/order.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../cart/cubit/cart_cubit.dart';

/// Which past orders are worth offering as one-tap reorders: delivered ones,
/// newest first, one per restaurant (the most recent), capped at [limit].
/// Dedupe matters — someone who orders the same pizza weekly should see one
/// chip for that pizzeria, not a row full of it.
List<AppOrder> reorderCandidates(
  List<AppOrder> orders, {
  int limit = 5,
  DateTime? now,
}) {
  final seen = <String>{};
  final result = <AppOrder>[];
  for (final order in orders) {
    if (!order.isDelivered(now: now)) continue;
    if (!seen.add(order.restaurantId)) continue;
    result.add(order);
    if (result.length == limit) break;
  }
  return result;
}

/// Rebuilds the cart from a past order and opens the cart. Fetches the
/// restaurant fresh so pricing/fees reflect the current menu.
Future<void> reorder(BuildContext context, AppOrder order) async {
  final messenger = ScaffoldMessenger.of(context);
  final cart = context.read<CartCubit>();
  final router = GoRouter.of(context);

  final restaurant =
      await sl<RestaurantRepository>().fetchRestaurant(order.restaurantId);

  if (restaurant == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('This restaurant is no longer available')),
    );
    return;
  }
  cart.replaceWith(restaurant, order.items);
  router.push(Routes.cart);
}
