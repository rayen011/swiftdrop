import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// The "− 1 +" pill used wherever a line quantity is edited.
///
/// Decrement dims at [min] rather than disappearing, so the control keeps a
/// stable width and the row doesn't reflow as the count changes.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.min = 1,
    this.compact = false,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final int min;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 30.0 : 38.0;
    final atMin = quantity <= min;

    return Container(
      padding: EdgeInsets.all(compact ? 3 : 5),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: context.colors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Step(
            icon: Icons.remove_rounded,
            size: size,
            onTap: onDecrement,
            color: atMin ? context.colors.inkSoft : context.colors.ink,
          ),
          Container(
            constraints: BoxConstraints(minWidth: compact ? 22 : 30),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: AppTypography.mono(fontSize: compact ? 13 : 16),
            ),
          ),
          _Step(
            icon: Icons.add_rounded,
            size: size,
            onTap: onIncrement,
            color: context.colors.ember,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.size,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.5, color: color),
        ),
      ),
    );
  }
}
