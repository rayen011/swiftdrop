import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// Loading skeletons: greyed-out card shapes that pulse while real data loads.
///
/// A skeleton tells the user *what* is coming and *where* it will appear; a
/// centred spinner tells them nothing. The pulse is a simple opacity breathe —
/// deliberately not a shader sweep, which costs more and reads busier on the
/// dark theme.

/// Repeating opacity pulse applied over any skeleton layout.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

/// One grey placeholder block.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 10,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Placeholder for a [RestaurantCard] while the store list loads.
class StoreCardSkeleton extends StatelessWidget {
  const StoreCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: context.colors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 150, width: double.infinity, radius: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 160, height: 18),
                SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonBox(width: 70, height: 24, radius: 12),
                    SizedBox(width: 8),
                    SkeletonBox(width: 84, height: 24, radius: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A pulsing column of store-card placeholders (drop-in for a list body).
class StoreListSkeleton extends StatelessWidget {
  const StoreListSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            const StoreCardSkeleton(),
            if (i != count - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

/// Placeholder for one product tile in the grocery/pharmacy grids.
class ProductTileSkeleton extends StatelessWidget {
  const ProductTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: context.colors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 116, width: double.infinity, radius: 0),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 100, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 60, height: 11),
                SizedBox(height: 14),
                Row(
                  children: [
                    SkeletonBox(width: 52, height: 15),
                    Spacer(),
                    SkeletonBox(width: 34, height: 34, radius: 17),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A pulsing product-grid placeholder matching the store grids' geometry.
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 264,
        ),
        itemCount: count,
        itemBuilder: (_, _) => const ProductTileSkeleton(),
      ),
    );
  }
}
