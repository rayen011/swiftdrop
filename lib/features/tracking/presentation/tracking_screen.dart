import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/models/order.dart';
import '../../../core/models/order_status.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../cubit/tracking_cubit.dart';
import 'widgets/mock_map.dart';

/// Live (mock) order tracking. Owns a [TrackingCubit], which derives everything
/// from the order's `placedAt` and writes nothing back.
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.order});

  final AppOrder order;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackingCubit(order: order),
      child: const _TrackingView(),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          if (state.status == OrderStatus.delivered) {
            return _DeliveredView(state: state);
          }
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: MockMap(progress: state.routeProgress),
                ),
                _TrackingSheet(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({required this.state});
  final TrackingState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.status.label, style: text.headlineMedium),
          const SizedBox(height: 16),
          _Timeline(current: state.status),
          if (state.order.isEcoOrder) ...[
            const SizedBox(height: 16),
            _EcoChip(co2: state.order.co2SavedGrams),
          ],
          const SizedBox(height: 20),
          _DriverCard(state: state),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.current});
  final OrderStatus current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: OrderStatus.timeline.map((step) {
        final reached = current.step >= step.step;
        final isLast = step == OrderStatus.timeline.last;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: reached ? context.colors.ember : context.colors.surfaceHigh,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 3,
                    color:
                        reached ? context.colors.ember : context.colors.surfaceHigh,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _EcoChip extends StatelessWidget {
  const _EcoChip({required this.co2});
  final double co2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.eco.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, color: context.colors.eco, size: 16),
          const SizedBox(width: 8),
          Text('Eco order · saving ${co2.toStringAsFixed(0)}g CO₂',
              style:
                  AppTypography.mono(fontSize: 12, color: context.colors.eco)),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.state});
  final TrackingState state;

  @override
  Widget build(BuildContext context) {
    final driver = state.driver;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: context.colors.surfaceHigh,
          child: Text(driver.initials,
              style: AppTypography.mono(
                  fontSize: 14, color: context.colors.ink)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(driver.name,
                  style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  Icon(Icons.star_rounded,
                      color: context.colors.star, size: 14),
                  const SizedBox(width: 3),
                  Text('${driver.rating} · ${driver.vehicle}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
        _circleButton(context, Icons.chat_bubble_outline_rounded),
        const SizedBox(width: 8),
        _circleButton(context, Icons.call_outlined),
      ],
    );
  }

  Widget _circleButton(BuildContext context, IconData icon) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: context.colors.surfaceHigh, shape: BoxShape.circle),
        child: Icon(icon, color: context.colors.ink, size: 20),
      );
}

/// Combined Order-Delivered screen: rating + passport stamp + reorder.
class _DeliveredView extends StatelessWidget {
  const _DeliveredView({required this.state});
  final TrackingState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.colors.eco.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded,
                  color: context.colors.eco, size: 52),
            ),
            const SizedBox(height: 24),
            Text('Delivered 🎉', style: text.displayLarge),
            const SizedBox(height: 8),
            if (state.order.isEcoOrder)
              Text(
                'You saved ${state.order.co2SavedGrams.toStringAsFixed(0)}g CO₂ today 🌿',
                style: AppTypography.mono(
                    fontSize: 14, color: context.colors.eco),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Passport stamp earned in this neighborhood!',
                        style: text.titleMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('How was your order?', style: text.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Icon(Icons.star_rounded,
                    color: context.colors.star, size: 36),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Back to home'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
