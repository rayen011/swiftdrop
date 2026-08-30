import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/restaurant.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../../features/cart/cubit/cart_cubit.dart';
import '../../features/cart/cubit/cart_state.dart';

/// The compact "add ↔ stepper" control used on product tiles across the grocery
/// and pharmacy grids. Reflects the live cart: an option-less line is matched by
/// menuItemId, so tapping + again steps the same line.
///
/// Only for items without options — a quick add can't choose a size. Cards for
/// items with options should route to the detail screen instead.
class CartQuantityControl extends StatelessWidget {
  const CartQuantityControl({
    super.key,
    required this.restaurant,
    required this.item,
  });

  final Restaurant restaurant;
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        final index = cart.items.indexWhere(
            (i) => i.menuItemId == item.id && i.selectedOptions.isEmpty);
        final qty = index >= 0 ? cart.items[index].quantity : 0;
        final cubit = context.read<CartCubit>();

        if (qty == 0) {
          return _RoundAdd(
            onTap: () => cubit.addItem(
              restaurant,
              OrderItem(
                menuItemId: item.id,
                name: item.name,
                priceTND: item.priceTND,
              ),
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceHigh,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(color: context.colors.line),
          ),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Step(
                icon: Icons.remove_rounded,
                onTap: () => cubit.changeQuantity(index, -1),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                alignment: Alignment.center,
                child: Text('$qty', style: AppTypography.mono(fontSize: 13)),
              ),
              _Step(
                icon: Icons.add_rounded,
                onTap: () => cubit.changeQuantity(index, 1),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoundAdd extends StatelessWidget {
  const _RoundAdd({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration:
              BoxDecoration(gradient: context.colors.cta, shape: BoxShape.circle),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(Icons.add_rounded,
                color: context.colors.onEmber, size: 20),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 16, color: context.colors.ember),
        ),
      ),
    );
  }
}
