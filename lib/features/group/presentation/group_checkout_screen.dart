import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/group_order.dart';
import '../../../core/models/order.dart';
import '../../../core/models/order_status.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/group_order_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../auth/cubit/auth_cubit.dart';

/// Host-only: confirms the combined order with one delivery fee split equally,
/// places a single [AppOrder], and sends everyone to tracking.
class GroupCheckoutScreen extends StatefulWidget {
  const GroupCheckoutScreen({super.key, required this.group});

  final GroupOrder group;

  @override
  State<GroupCheckoutScreen> createState() => _GroupCheckoutScreenState();
}

class _GroupCheckoutScreenState extends State<GroupCheckoutScreen> {
  bool _placing = false;

  GroupOrder get group => widget.group;

  Future<void> _placeOrder() async {
    final host = context.read<AuthCubit>().state.user;
    final address = host?.defaultAddress;
    if (host == null || address == null || _placing) return;

    setState(() => _placing = true);
    final groupRepo = sl<GroupOrderRepository>();
    final router = GoRouter.of(context);
    try {
      final restaurant =
          await sl<RestaurantRepository>().fetchRestaurant(group.restaurantId);
      final items = [
        for (final p in group.participants) ...p.items,
      ];
      final draft = AppOrder(
        id: '',
        customerId: host.uid,
        restaurantId: group.restaurantId,
        restaurantName: group.restaurantName,
        items: items,
        subtotalTND: group.itemsSubtotal,
        deliveryFeeTND: group.deliveryFeeTND,
        totalTND: group.grandTotal,
        status: OrderStatus.pending,
        isGroupOrder: true,
        groupOrderId: group.id,
        deliveryAddress: address,
        neighborhoodId: restaurant?.neighborhood ?? '',
        // placedAt intentionally left null — toMap() emits a serverTimestamp
        // sentinel, and placeOrder reads back the resolved value. The delivery
        // timeline is derived from it, so it must be the server's clock.
      );
      final placed = await sl<OrderRepository>().placeOrder(draft);
      await groupRepo.markOrdered(group.id, placed.id);
      if (!mounted) return;
      router.go('${Routes.tracking}/${placed.id}', extra: placed);
    } catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not place order: $e')),
      );
    }
  }

  /// Reopen the group if the host backs out without ordering, so participants
  /// aren't stuck on "host is checking out".
  Future<void> _onPop() async {
    if (group.status != GroupStatus.ordered) {
      await sl<GroupOrderRepository>().reopenGroup(group.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final feeShare = group.feeSharePerPerson;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _onPop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Group checkout')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(group.restaurantName, style: text.titleLarge),
                  const SizedBox(height: 4),
                  Text('One delivery fee, split ${feeShare.toStringAsFixed(2)} TND '
                      'across ${group.participantCount}',
                      style: text.bodySmall),
                  const SizedBox(height: 20),
                  ...group.participants.map((p) => _ParticipantSummary(
                        participant: p,
                        feeShare: feeShare,
                      )),
                  const Divider(height: 32),
                  _row(context, 'Items subtotal', group.itemsSubtotal),
                  _row(context, 'Delivery fee', group.deliveryFeeTND),
                  const Divider(height: 16),
                  _row(context, 'Group total', group.grandTotal, bold: true),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _placing ? null : _placeOrder,
                  child: _placing
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: context.colors.onEmber),
                        )
                      : Text(
                          'Place group order · ${group.grandTotal.toStringAsFixed(1)} TND'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, double value,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text('${value.toStringAsFixed(1)} TND',
              style: AppTypography.mono(
                fontSize: bold ? 16 : 13,
                color: bold ? context.colors.ink : context.colors.inkSoft,
              )),
        ],
      ),
    );
  }
}

class _ParticipantSummary extends StatelessWidget {
  const _ParticipantSummary({
    required this.participant,
    required this.feeShare,
  });

  final GroupParticipant participant;
  final double feeShare;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final owed = participant.subtotal + feeShare;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(participant.name, style: text.titleMedium),
                Text(
                  '${participant.subtotal.toStringAsFixed(1)} + '
                  '${feeShare.toStringAsFixed(2)} fee',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          Text('${owed.toStringAsFixed(2)} TND',
              style: AppTypography.mono(fontSize: 14, color: context.colors.emberText)),
        ],
      ),
    );
  }
}
