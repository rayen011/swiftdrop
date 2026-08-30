import 'package:flutter/material.dart';

import '../../../../core/models/menu_item.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cart_quantity_control.dart';
import '../../../../core/widgets/food_image.dart';
import 'medicine_request_sheet.dart' show pharmacyAccent;

/// One medicine tile in the pharmacy "Recommendation" grid: image, favourite,
/// rating, price with struck-through MRP, and the shared add/stepper control.
class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.restaurant,
    required this.item,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  final Restaurant restaurant;
  final MenuItem item;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: context.colors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 116,
                  width: double.infinity,
                  child: FoodImage.menuItem(item),
                ),
                if (item.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge('-${item.discountPercent}%'),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: _Heart(active: isFavorite, onTap: onFavorite),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 13.5, height: 1.2),
                        ),
                        if (item.rating > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 13, color: context.colors.star),
                              const SizedBox(width: 3),
                              Text(item.rating.toStringAsFixed(1),
                                  style: AppTypography.mono(
                                      fontSize: 11,
                                      color: context.colors.inkSoft)),
                            ],
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _PriceRow(item: item)),
                        const SizedBox(width: 8),
                        CartQuantityControl(restaurant: restaurant, item: item),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.item});
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('${item.priceTND.toStringAsFixed(1)} TND',
              style: AppTypography.mono(fontSize: 14).copyWith(
                  fontWeight: FontWeight.w700, color: context.colors.ink)),
          if (item.isOnSale) ...[
            const SizedBox(width: 5),
            Text(item.mrpTND.toStringAsFixed(1),
                style: AppTypography.mono(
                        fontSize: 11, color: context.colors.inkSoft)
                    .copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: context.colors.inkSoft,
                )),
          ],
        ],
      ),
    );
  }
}

class _Heart extends StatelessWidget {
  const _Heart({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.background.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 16,
            color: active ? context.colors.error : context.colors.ink,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: pharmacyAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Colors.white, fontSize: 10)),
    );
  }
}
