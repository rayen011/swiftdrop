import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/order.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/order_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../reorder.dart';
import 'widgets/order_status_badge.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().state.user?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Order history')),
      body: uid == null
          ? const Center(child: Text('Sign in to see your orders'))
          : StreamBuilder<List<AppOrder>>(
              stream: sl<OrderRepository>().watchUserOrders(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: context.colors.ember));
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const _EmptyHistory();
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final AppOrder order;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () =>
          context.push(Routes.orderDetail, extra: order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(order.restaurantName,
                        style: text.titleMedium)),
                OrderStatusBadge(status: order.liveStatus()),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${order.items.length} item${order.items.length > 1 ? 's' : ''}'
              ' · ${_date(order.placedAt)}',
              style: text.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${order.totalTND.toStringAsFixed(1)} TND',
                    style: AppTypography.mono(
                        fontSize: 15, color: context.colors.ember)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => reorder(context, order),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reorder'),
                  style: TextButton.styleFrom(
                      foregroundColor: context.colors.ink),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime? d) {
    if (d == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              color: context.colors.inkSoft, size: 48),
          const SizedBox(height: 12),
          Text('No orders yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Your past orders will show up here',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
