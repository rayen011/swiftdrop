import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/address.dart';
import '../../../core/models/order.dart';
import '../../../core/models/order_status.dart';
import '../../../core/models/payment_method.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/order_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/cubit/cart_state.dart';
import 'widgets/promo_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _payment = PaymentMethod.cash;
  bool _placing = false;

  Future<void> _placeOrder(CartState cart, AuthState auth) async {
    final user = auth.user;
    final restaurant = cart.restaurant;
    final address = user?.defaultAddress;
    if (user == null || restaurant == null || address == null) return;

    setState(() => _placing = true);
    final draft = AppOrder(
      id: '',
      customerId: user.uid,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      items: cart.items,
      subtotalTND: cart.subtotal,
      deliveryFeeTND: cart.deliveryFee,
      ecoDiscountTND: cart.ecoDiscount,
      // Only record the code when it's actually worth something — a deal that
      // clamped to zero must not burn one of its limited redemptions.
      promoCode: cart.hasPromo ? cart.promoCode : '',
      promoDiscountTND: cart.hasPromo ? cart.promoDiscount : 0,
      totalTND: cart.total,
      status: OrderStatus.pending,
      paymentMethod: _payment,
      isEcoOrder: cart.ecoEnabled,
      co2SavedGrams: cart.co2Saved,
      deliveryAddress: address,
      neighborhoodId: restaurant.neighborhood,
      // placedAt intentionally left null — toMap() emits a serverTimestamp
      // sentinel, and placeOrder reads back the resolved value. The delivery
      // timeline is derived from it, so it must be the server's clock.
    );

    try {
      final placed = await sl<OrderRepository>().placeOrder(draft);
      if (!mounted) return;
      context.read<CartCubit>().clear();
      context.go('${Routes.tracking}/${placed.id}', extra: placed);
    } catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.orderFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.checkoutTitle)),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, auth) {
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cart) {
              final address = auth.user?.defaultAddress;
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(context.l10n.deliverTo, style: text.titleMedium),
                        const SizedBox(height: 8),
                        _AddressCard(address: address),
                        const SizedBox(height: 24),
                        Text(context.l10n.payment, style: text.titleMedium),
                        const SizedBox(height: 8),
                        _PaymentTile(
                          method: PaymentMethod.cash,
                          icon: Icons.payments_outlined,
                          group: _payment,
                          onTap: () =>
                              setState(() => _payment = PaymentMethod.cash),
                        ),
                        _PaymentTile(
                          method: PaymentMethod.card,
                          icon: Icons.credit_card_rounded,
                          group: _payment,
                          onTap: () =>
                              setState(() => _payment = PaymentMethod.card),
                        ),
                        const SizedBox(height: 24),
                        Text(context.l10n.passportDeal,
                            style: text.titleMedium),
                        const SizedBox(height: 8),
                        const PromoField(),
                        const SizedBox(height: 24),
                        Text(context.l10n.orderSummary,
                            style: text.titleMedium),
                        const SizedBox(height: 8),
                        _summaryRow(
                            context, context.l10n.subtotal, cart.subtotal),
                        if (cart.isPlus && cart.baseDeliveryFee > 0)
                          _summaryRow(context, context.l10n.deliveryFeePlus, 0,
                              color: context.colors.eco)
                        else
                          _summaryRow(context, context.l10n.deliveryFee,
                              cart.deliveryFee),
                        if (cart.ecoEnabled)
                          _summaryRow(context, context.l10n.ecoDiscount,
                              -cart.ecoDiscount,
                              color: context.colors.eco),
                        if (cart.hasPromo)
                          _summaryRow(
                              context, cart.promoCode, -cart.promoDiscount,
                              color: context.colors.eco),
                        const Divider(height: 24),
                        _summaryRow(context, context.l10n.total, cart.total,
                            bold: true),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: (_placing || address == null)
                            ? null
                            : () => _placeOrder(cart, auth),
                        child: _placing
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.colors.onEmber),
                              )
                            : Text(context.l10n
                                .placeOrder(cart.total.toStringAsFixed(1))),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, double value,
      {bool bold = false, Color? color}) {
    final sign = value < 0 ? '-' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text('$sign${value.abs().toStringAsFixed(1)} TND',
              style: AppTypography.mono(
                fontSize: bold ? 16 : 13,
                color: color ??
                    (bold ? context.colors.ink : context.colors.inkSoft),
              )),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});
  final Address? address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: context.colors.ember),
          const SizedBox(width: 12),
          Expanded(
            child: address == null
                ? Text(context.l10n.noAddress)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address!.label,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(address!.fullAddress,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.icon,
    required this.group,
    required this.onTap,
  });

  final PaymentMethod method;
  final IconData icon;
  final PaymentMethod group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = method == group;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? context.colors.ember : context.colors.line,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.colors.ink, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label(context.l10n),
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(method.hint(context.l10n),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? context.colors.ember : context.colors.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}
