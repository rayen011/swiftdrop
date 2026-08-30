import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.cartTitle)),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, cart) {
          if (cart.isEmpty) {
            return Center(child: Text(context.l10n.cartEmpty));
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(cart.restaurant?.name ?? '',
                        style: text.titleLarge),
                    const SizedBox(height: 12),
                    ...cart.items.asMap().entries.map((e) => _CartRow(
                          index: e.key,
                          name: e.value.name,
                          options: e.value.selectedOptions.values.join(', '),
                          lineTotal: e.value.lineTotal,
                          quantity: e.value.quantity,
                        )),
                    const SizedBox(height: 12),
                    const _EcoToggle(),
                    const SizedBox(height: 16),
                    _Breakdown(cart: cart),
                  ],
                ),
              ),
              _CheckoutBar(total: cart.total),
            ],
          );
        },
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({
    required this.index,
    required this.name,
    required this.options,
    required this.lineTotal,
    required this.quantity,
  });

  final int index;
  final String name;
  final String options;
  final double lineTotal;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: text.titleMedium),
                if (options.isNotEmpty)
                  Text(options, style: text.bodySmall),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.colors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      context.read<CartCubit>().changeQuantity(index, -1),
                  icon: const Icon(Icons.remove_rounded, size: 18),
                ),
                Text('$quantity', style: AppTypography.mono(fontSize: 14)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      context.read<CartCubit>().changeQuantity(index, 1),
                  icon: const Icon(Icons.add_rounded, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 64,
            child: Text('${lineTotal.toStringAsFixed(1)} TND',
                textAlign: TextAlign.right,
                style: AppTypography.mono(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// Eco Bundle is a SwiftDrop Plus perk. For a non-subscriber the row stays
/// visible but reads as locked and routes to the paywall — hiding it would hide
/// the reason to subscribe.
class _EcoToggle extends StatelessWidget {
  const _EcoToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        final locked = !cart.isPlus;
        return InkWell(
          onTap: locked ? () => context.push(Routes.plus) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cart.ecoEnabled
                    ? context.colors.eco.withValues(alpha: 0.5)
                    : context.colors.line,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  locked ? Icons.lock_outline_rounded : Icons.eco_rounded,
                  color: locked
                      ? context.colors.inkSoft
                      : context.colors.eco,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(context.l10n.ecoBundle,
                              style: Theme.of(context).textTheme.titleMedium),
                          if (locked) ...[
                            const SizedBox(width: 8),
                            const _PlusChip(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        locked
                            ? context.l10n.ecoLocked
                            : cart.ecoEnabled
                                ? context.l10n.ecoActive(cart.bundleSize,
                                    cart.co2Saved.toStringAsFixed(0))
                                : context.l10n.ecoIdle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (locked)
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: context.colors.inkSoft)
                else
                  Switch(
                    value: cart.ecoEnabled,
                    activeThumbColor: context.colors.eco,
                    onChanged: (v) => context.read<CartCubit>().toggleEco(v),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Small "PLUS" marker used to label a gated affordance.
class _PlusChip extends StatelessWidget {
  const _PlusChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: context.colors.cta,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('PLUS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.colors.onEmber,
            fontSize: 9,
            letterSpacing: 0.4,
          )),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.cart});
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(context, context.l10n.subtotal, cart.subtotal),
        // Plus waives the fee outright, so show the waiver rather than a bare
        // 0.0 — the saving is the whole point of the subscription.
        if (cart.isPlus && cart.baseDeliveryFee > 0)
          _freeDeliveryRow(context)
        else
          _row(context, context.l10n.deliveryFee, cart.deliveryFee),
        if (cart.ecoEnabled)
          _row(context, context.l10n.ecoDiscount, -cart.ecoDiscount,
              color: context.colors.eco),
        const Divider(height: 24),
        _row(context, context.l10n.total, cart.total, bold: true),
      ],
    );
  }

  Widget _freeDeliveryRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(context.l10n.deliveryFee,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 8),
              const _PlusChip(),
            ],
          ),
          Row(
            children: [
              Text(
                '${cart.baseDeliveryFee.toStringAsFixed(1)} TND',
                style: AppTypography.mono(
                  fontSize: 12,
                  color: context.colors.inkSoft,
                ).copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: context.colors.inkSoft,
                ),
              ),
              const SizedBox(width: 8),
              Text(context.l10n.freeLabel,
                  style: AppTypography.mono(
                      fontSize: 13, color: context.colors.eco)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, double value,
      {bool bold = false, Color? color}) {
    final style = AppTypography.mono(
      fontSize: bold ? 16 : 13,
      color: color ?? (bold ? context.colors.ink : context.colors.inkSoft),
    );
    final sign = value < 0 ? '-' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: bold ? context.colors.ink : null,
                    fontWeight: bold ? FontWeight.w600 : null,
                  )),
          Text('$sign${value.abs().toStringAsFixed(1)} TND', style: style),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => context.push(Routes.checkout),
          child:
              Text(context.l10n.goToCheckout(total.toStringAsFixed(1))),
        ),
      ),
    );
  }
}
