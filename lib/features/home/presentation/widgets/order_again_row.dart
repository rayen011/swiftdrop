import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/models/order.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../orders/reorder.dart';

/// One-tap reorder chips from the user's recent delivered orders — the single
/// highest-convenience action a returning customer has. Collapses to nothing
/// for a new user (no heading, no empty state), so Home stays clean until
/// there's something worth repeating.
class OrderAgainRow extends StatefulWidget {
  const OrderAgainRow({super.key, required this.uid, this.repo});

  final String uid;

  /// Injectable for tests; defaults to the registered repository.
  final OrderRepository? repo;

  @override
  State<OrderAgainRow> createState() => _OrderAgainRowState();
}

class _OrderAgainRowState extends State<OrderAgainRow> {
  /// Subscribed once — Home rebuilds (vertical switches) must not recreate the
  /// Firestore stream.
  late final Stream<List<AppOrder>> _orders =
      (widget.repo ?? sl<OrderRepository>()).watchUserOrders(widget.uid);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<AppOrder>>(
      stream: _orders,
      builder: (context, snapshot) {
        final candidates = reorderCandidates(snapshot.data ?? const []);
        if (candidates.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.orderAgain, style: text.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: candidates.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _ReorderCard(order: candidates[i]),
              ),
            ),
            const SizedBox(height: 26),
          ],
        );
      },
    );
  }
}

class _ReorderCard extends StatelessWidget {
  const _ReorderCard({required this.order});
  final AppOrder order;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.quantity);

    return Semantics(
      button: true,
      label: 'Order again from ${order.restaurantName}',
      child: InkWell(
        onTap: () => reorder(context, order),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Container(
          width: 190,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: context.colors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.restaurantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium,
              ),
              Text(
                context.l10n.itemsSummary(
                    itemCount, order.totalTND.toStringAsFixed(1)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.mono(
                    fontSize: 11, color: context.colors.inkSoft),
              ),
              Row(
                children: [
                  Icon(Icons.replay_rounded,
                      size: 14, color: context.colors.ember),
                  const SizedBox(width: 5),
                  Text(context.l10n.reorder,
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: context.colors.emberText)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
