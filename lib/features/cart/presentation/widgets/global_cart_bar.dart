import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../cubit/cart_cubit.dart';
import '../../cubit/cart_state.dart';

/// The persistent "you have a cart" bar shown above the bottom nav on the main
/// tabs. A started order used to vanish from sight the moment the shopper left
/// the store screen; this keeps it one tap away everywhere.
///
/// Collapses to nothing when the cart is empty (AnimatedSize, so it slides in
/// and out rather than popping). Store screens keep their own local bar — they
/// are pushed over the shell, so the two never show together.
class GlobalCartBar extends StatelessWidget {
  const GlobalCartBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: cart.isEmpty
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Semantics(
                    button: true,
                    label: '${context.l10n.viewCart}, '
                        '${cart.itemCount}, '
                        '${cart.total.toStringAsFixed(1)} TND',
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: context.colors.cta,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusPill),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  context.colors.emberDeep.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _CountBadge(count: cart.itemCount),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cart.restaurant?.name ?? 'Your cart',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: context.colors.onEmber),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // scaleDown so the action + total shrink on narrow
                            // screens instead of overflowing the pill.
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(context.l10n.viewCart,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                color: context.colors.onEmber)),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${cart.total.toStringAsFixed(1)} TND',
                                      style: AppTypography.mono(
                                          fontSize: 13,
                                          color: context.colors.onEmber),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text('$count',
          style: AppTypography.mono(fontSize: 13, color: context.colors.onEmber)),
    );
  }
}
