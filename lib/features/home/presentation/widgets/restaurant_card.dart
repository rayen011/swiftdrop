import 'package:flutter/material.dart';

import '../../../../core/models/restaurant.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/food_image.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant, this.onTap});

  final Restaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: context.colors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FoodImage.restaurant(restaurant),
                  // Keeps the overlaid rating legible over bright photography.
                  DecoratedBox(
                    decoration:
                        BoxDecoration(gradient: context.colors.imageScrim),
                  ),
                  if (!restaurant.isOpen)
                    Container(
                      color: context.colors.background.withValues(alpha: 0.68),
                      alignment: Alignment.center,
                      child: Text('Closed',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _RatingPill(rating: restaurant.rating),
                  ),
                  if (restaurant.isEcoEligible)
                    const Positioned(top: 10, right: 10, child: _EcoBadge()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Meta(
                        icon: Icons.schedule_rounded,
                        label: '${restaurant.estimatedMinutes} min',
                      ),
                      const SizedBox(width: 8),
                      _Meta(
                        icon: Icons.delivery_dining_rounded,
                        label:
                            '${restaurant.deliveryFeeTND.toStringAsFixed(1)} TND',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.background.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: context.colors.star, size: 14),
          const SizedBox(width: 4),
          Text(rating.toStringAsFixed(1),
              style: AppTypography.mono(fontSize: 12)),
        ],
      ),
    );
  }
}

/// Chip on a card's meta row — a muted capsule rather than dot-separated text,
/// so delivery time and fee stay scannable at a glance.
class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: context.colors.inkSoft),
          const SizedBox(width: 5),
          Text(label,
              style: AppTypography.mono(
                  fontSize: 11, color: context.colors.inkSoft)),
        ],
      ),
    );
  }
}

class _EcoBadge extends StatelessWidget {
  const _EcoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.background.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.eco.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, color: context.colors.eco, size: 12),
          const SizedBox(width: 4),
          Text('ECO',
              style:
                  AppTypography.mono(fontSize: 10, color: context.colors.eco)),
        ],
      ),
    );
  }
}
