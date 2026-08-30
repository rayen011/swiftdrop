import 'package:flutter/material.dart';

import '../../../core/models/order.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../reorder.dart';
import 'widgets/order_status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final AppOrder order;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(order.restaurantName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              OrderStatusBadge(status: order.liveStatus()),
              const Spacer(),
              if (order.isEcoOrder)
                Row(
                  children: [
                    Icon(Icons.eco_rounded,
                        color: context.colors.eco, size: 16),
                    const SizedBox(width: 4),
                    Text('${order.co2SavedGrams.toStringAsFixed(0)}g CO₂',
                        style: AppTypography.mono(
                            fontSize: 12, color: context.colors.eco)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Items', style: text.titleMedium),
          const SizedBox(height: 8),
          ...order.items.map((item) => _ItemRow(item: item)),
          const Divider(height: 32),
          _summaryRow(context, 'Subtotal', order.subtotalTND),
          _summaryRow(context, 'Delivery fee', order.deliveryFeeTND),
          if (order.ecoDiscountTND > 0)
            _summaryRow(context, 'Eco discount', -order.ecoDiscountTND,
                color: context.colors.eco),
          const Divider(height: 24),
          _summaryRow(context, 'Total', order.totalTND, bold: true),
          const SizedBox(height: 24),
          Text('Delivered to', style: text.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: context.colors.ember),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.deliveryAddress.label,
                          style: text.titleMedium),
                      Text(order.deliveryAddress.fullAddress,
                          style: text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => reorder(context, order),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reorder'),
          ),
        ],
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

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final options = item.selectedOptions.values.join(', ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${item.quantity}×',
              style: AppTypography.mono(
                  fontSize: 14, color: context.colors.inkSoft)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: text.titleMedium),
                if (options.isNotEmpty)
                  Text(options, style: text.bodySmall),
                if (item.specialInstructions.isNotEmpty)
                  Text('“${item.specialInstructions}”',
                      style: text.bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Text('${item.lineTotal.toStringAsFixed(1)} TND',
              style: AppTypography.mono(fontSize: 13)),
        ],
      ),
    );
  }
}
