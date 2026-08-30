import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/neighborhood.dart';
import '../../../core/models/user_stats.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/neighborhood_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'widgets/deal_detail_sheet.dart';

/// Gamified loyalty hub: stamp progress per Tunis neighborhood + unlocked deals.
class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().state.user?.uid;
    return Scaffold(
      // Transparent so MainShell's ambient backdrop shows through.
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Delivery Passport')),
      body: uid == null
          ? const Center(child: Text('Sign in to start collecting stamps'))
          : StreamBuilder<UserStats>(
              stream: sl<OrderRepository>().watchUserStats(uid),
              initialData: UserStats.empty,
              builder: (context, statsSnap) {
                final stats = statsSnap.data ?? UserStats.empty;
                return StreamBuilder<List<PassportNeighborhood>>(
                  stream: sl<NeighborhoodRepository>().watchNeighborhoods(),
                  builder: (context, zoneSnap) {
                    if (zoneSnap.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: context.colors.ember));
                    }
                    final zones = zoneSnap.data ?? [];
                    return _PassportBody(stats: stats, zones: zones);
                  },
                );
              },
            ),
    );
  }
}

class _PassportBody extends StatelessWidget {
  const _PassportBody({required this.stats, required this.zones});

  final UserStats stats;
  final List<PassportNeighborhood> zones;

  @override
  Widget build(BuildContext context) {
    final totalStamps = stats.totalStamps;
    final unlocked =
        zones.where((z) => stats.stampsIn(z.id) >= z.requiredStamps).length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _SummaryCard(
              totalStamps: totalStamps,
              zonesVisited: stats.zonesVisited,
              dealsUnlocked: unlocked,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Text('Tunis neighborhoods',
                style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        SliverPadding(
          // Bottom inset clears the floating nav bar.
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.92,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final zone = zones[i];
                final stamps = stats.stampsIn(zone.id);
                return _ZoneCard(
                  zone: zone,
                  stamps: stamps,
                  onTap: () => showDealDetailSheet(
                    context,
                    zone,
                    stamps,
                    redemptionsUsed: stats.redemptionsOf(zone.deal.code),
                  ),
                );
              },
              childCount: zones.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalStamps,
    required this.zonesVisited,
    required this.dealsUnlocked,
  });

  final int totalStamps;
  final int zonesVisited;
  final int dealsUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: context.colors.hero,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: context.colors.line),
      ),
      child: Row(
        children: [
          _stat(context, '🏅 $totalStamps', 'Stamps'),
          _divider(context),
          _stat(context, '📍 $zonesVisited', 'Zones'),
          _divider(context),
          _stat(context, '🎁 $dealsUnlocked', 'Deals'),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: context.colors.line,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  Widget _stat(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.mono(fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({
    required this.zone,
    required this.stamps,
    required this.onTap,
  });

  final PassportNeighborhood zone;
  final int stamps;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final unlocked = stamps >= zone.requiredStamps;
    final visited = stamps > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unlocked ? context.colors.eco : context.colors.line,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(zone.iconEmoji,
                    style: TextStyle(
                        fontSize: 30,
                        color: visited ? null : context.colors.inkSoft)),
                Icon(
                  unlocked
                      ? Icons.check_circle_rounded
                      : Icons.lock_outline_rounded,
                  size: 18,
                  color: unlocked
                      ? context.colors.eco
                      : context.colors.inkSoft,
                ),
              ],
            ),
            const Spacer(),
            Text(zone.name,
                style: text.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            _StampDots(stamps: stamps, required: zone.requiredStamps),
            const SizedBox(height: 6),
            Text(
              unlocked ? 'Deal unlocked!' : '$stamps/${zone.requiredStamps} stamps',
              style: AppTypography.mono(
                fontSize: 11,
                color: unlocked ? context.colors.eco : context.colors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StampDots extends StatelessWidget {
  const _StampDots({required this.stamps, required this.required});

  final int stamps;
  final int required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(required, (i) {
        final filled = i < stamps;
        return Container(
          margin: const EdgeInsets.only(right: 5),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: filled ? context.colors.ember : context.colors.surfaceHigh,
            shape: BoxShape.circle,
            border: filled
                ? null
                : Border.all(color: context.colors.line, width: 1),
          ),
        );
      }),
    );
  }
}
