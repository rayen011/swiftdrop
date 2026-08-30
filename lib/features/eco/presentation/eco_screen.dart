import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/user_stats.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/order_repository.dart';
import '../../auth/cubit/auth_cubit.dart';

/// Eco hub: cumulative CO₂ saved + how bundling works + nearby (cosmetic) bundles.
class EcoScreen extends StatelessWidget {
  const EcoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().state.user?.uid;
    return Scaffold(
      // Transparent so MainShell's ambient backdrop shows through.
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Eco')),
      body: StreamBuilder<UserStats>(
        stream: uid == null ? null : sl<OrderRepository>().watchUserStats(uid),
        initialData: UserStats.empty,
        builder: (context, snapshot) {
          final co2 = (snapshot.data ?? UserStats.empty).totalCo2Saved;
          return ListView(
            // Bottom inset clears the floating nav bar.
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              _Co2Card(grams: co2),
              const SizedBox(height: 24),
              Text('How Eco Bundle works',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const _HowItWorks(),
              const SizedBox(height: 24),
              Text('Active bundles near you',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Toggle Eco Bundle in your cart to join one.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              ..._mockBundles.map((b) => _BundleCard(bundle: b)),
            ],
          );
        },
      ),
    );
  }
}

class _Co2Card extends StatelessWidget {
  const _Co2Card({required this.grams});
  final double grams;

  @override
  Widget build(BuildContext context) {
    // Rough equivalence: ~170 g CO₂ per car-km avoided.
    final km = grams / 170;
    final display =
        grams >= 1000 ? '${(grams / 1000).toStringAsFixed(2)} kg' : '${grams.toStringAsFixed(0)} g';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.eco.withValues(alpha: 0.18),
            context.colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.eco.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco_rounded,
                  color: context.colors.eco, size: 20),
              const SizedBox(width: 8),
              Text('Your CO₂ saved',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(display,
              style: AppTypography.mono(
                  fontSize: 40, color: context.colors.eco)),
          const SizedBox(height: 6),
          Text('≈ ${km.toStringAsFixed(1)} km of car driving avoided 🌿',
              style: AppTypography.mono(
                  fontSize: 13, color: context.colors.inkSoft)),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const _steps = [
    ('Toggle Eco Bundle', 'Flip the switch in your cart before checkout.'),
    ('We bundle nearby orders', 'Your order rides with others heading your way.'),
    ('You save & cut CO₂', 'A discount on delivery and fewer trips on the road.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: context.colors.eco.withValues(alpha: 0.15),
                  child: Text('${i + 1}',
                      style: AppTypography.mono(
                          fontSize: 12, color: context.colors.eco)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_steps[i].$1,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(_steps[i].$2,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BundleCard extends StatelessWidget {
  const _BundleCard({required this.bundle});
  final _Bundle bundle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.eco.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.recycling_rounded,
                color: context.colors.eco),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bundle.area, style: text.titleMedium),
                const SizedBox(height: 2),
                Text('${bundle.orders} orders bundling now',
                    style: text.bodySmall),
              ],
            ),
          ),
          Text('-${bundle.savingsTND.toStringAsFixed(1)} TND',
              style: AppTypography.mono(
                  fontSize: 13, color: context.colors.eco)),
        ],
      ),
    );
  }
}

class _Bundle {
  const _Bundle(this.area, this.orders, this.savingsTND);
  final String area;
  final int orders;
  final double savingsTND;
}

const _mockBundles = <_Bundle>[
  _Bundle('Lac 2 · near you', 3, 1.5),
  _Bundle('El Menzah', 2, 1.5),
  _Bundle('La Marsa', 4, 2.0),
];
