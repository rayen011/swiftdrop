import 'package:flutter/material.dart';

import '../../../../core/models/order_status.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  Color _color(BuildContext context) => switch (status) {
        OrderStatus.delivered => context.colors.eco,
        OrderStatus.cancelled => context.colors.error,
        _ => context.colors.ember,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTypography.mono(fontSize: 11, color: color),
      ),
    );
  }
}
