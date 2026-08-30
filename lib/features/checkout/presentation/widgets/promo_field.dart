import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/models/neighborhood.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/promo.dart';
import '../../../../data/repositories/neighborhood_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/cubit/cart_state.dart';

/// Redeems a Passport deal code at checkout — the other half of the loop the
/// Passport has been promising ("use this code at checkout") since it shipped.
class PromoField extends StatefulWidget {
  const PromoField({super.key});

  @override
  State<PromoField> createState() => _PromoFieldState();
}

class _PromoFieldState extends State<PromoField> {
  final _controller = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _controller.text.trim();
    if (code.isEmpty || _checking) return;

    final uid = context.read<AuthCubit>().state.user?.uid;
    if (uid == null) return;

    setState(() {
      _checking = true;
      _error = null;
    });

    try {
      // Zones carry the deal rules; stats carry what this user has earned and
      // already spent. Both are needed to judge a code, so both are read fresh
      // rather than trusted from whatever the Passport screen last rendered.
      final zones = await sl<NeighborhoodRepository>().fetchNeighborhoods();
      final stats = await sl<OrderRepository>().fetchUserStats(uid);
      if (!mounted) return;

      final cart = context.read<CartCubit>().state;
      final outcome = resolvePromo(
        code: code,
        zones: zones,
        stats: stats,
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
      );

      switch (outcome) {
        case PromoAccepted(:final zone):
          context.read<CartCubit>().applyDeal(zone.deal);
          _controller.clear();
          setState(() => _checking = false);
        case PromoRejected():
          setState(() {
            _checking = false;
            _error = promoRejectionMessage(context.l10n, outcome);
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _error = context.l10n.promoCheckFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        final deal = cart.appliedDeal;
        if (deal != null) {
          return _AppliedDeal(
            deal: deal,
            discount: cart.promoDiscount,
            onRemove: () => context.read<CartCubit>().clearDeal(),
          );
        }
        return _Input(
          controller: _controller,
          error: _error,
          checking: _checking,
          onApply: _apply,
        );
      },
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.error,
    required this.checking,
    required this.onApply,
  });

  final TextEditingController controller;
  final String? error;
  final bool checking;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => onApply(),
                decoration: InputDecoration(
                  hintText: context.l10n.promoHint,
                  prefixIcon: Icon(Icons.local_activity_outlined,
                      color: context.colors.inkSoft),
                  errorText: error,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 56,
              child: TextButton(
                onPressed: checking ? null : onApply,
                child: checking
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(context.l10n.apply),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AppliedDeal extends StatelessWidget {
  const _AppliedDeal({
    required this.deal,
    required this.discount,
    required this.onRemove,
  });

  final PassportDeal deal;
  final double discount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.eco.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_activity_rounded,
              color: context.colors.eco, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deal.code,
                    style: AppTypography.mono(
                        fontSize: 13, color: context.colors.ink)),
                const SizedBox(height: 2),
                Text(deal.description,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text('-${discount.toStringAsFixed(1)} TND',
              style: AppTypography.mono(
                  fontSize: 13, color: context.colors.eco)),
          IconButton(
            onPressed: onRemove,
            tooltip: context.l10n.removeDeal,
            icon: Icon(Icons.close_rounded,
                size: 18, color: context.colors.inkSoft),
          ),
        ],
      ),
    );
  }
}
