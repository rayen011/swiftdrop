import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/food_image.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/cubit/cart_state.dart';
import 'item_detail_sheet.dart';

/// Browse a restaurant's menu and build the cart.
class RestaurantMenuScreen extends StatelessWidget {
  const RestaurantMenuScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final repo = sl<RestaurantRepository>();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: StreamBuilder<List<MenuItem>>(
        stream: repo.watchMenu(restaurant.id),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final byCategory = <String, List<MenuItem>>{};
          for (final item in items) {
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: context.colors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(restaurant.name, style: text.titleLarge),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      FoodImage.restaurant(restaurant),
                      // Scrim so the pinned title stays legible.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, context.colors.background],
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: context.colors.star, size: 16),
                      const SizedBox(width: 4),
                      Text(restaurant.rating.toStringAsFixed(1),
                          style: AppTypography.mono(fontSize: 13)),
                      const SizedBox(width: 12),
                      Text('${restaurant.estimatedMinutes} min · '
                          '${restaurant.deliveryFeeTND.toStringAsFixed(1)} TND delivery',
                          style: AppTypography.mono(
                              fontSize: 13, color: context.colors.inkSoft)),
                    ],
                  ),
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                        child:
                            CircularProgressIndicator(color: context.colors.ember)),
                  ),
                )
              else
                for (final category in byCategory.keys)
                  SliverToBoxAdapter(
                    child: _CategorySection(
                      title: category,
                      items: byCategory[category]!,
                      onTap: (item) =>
                          showItemDetailSheet(context, restaurant, item),
                    ),
                  ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      bottomNavigationBar: const _CartBar(),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<MenuItem> items;
  final void Function(MenuItem) onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(title, style: text.titleLarge),
        ),
        ...items.map((item) => _MenuRow(item: item, onTap: () => onTap(item))),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.onTap});

  final MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: item.isAvailable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: text.titleMedium),
                  const SizedBox(height: 4),
                  if (item.description.isNotEmpty)
                    Text(item.description,
                        style: text.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('${item.priceTND.toStringAsFixed(1)} TND',
                      style: AppTypography.mono(
                          fontSize: 13, color: context.colors.ember)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FoodImage.menuItem(item),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: context.colors.background.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.isAvailable
                              ? Icons.add_rounded
                              : Icons.block_rounded,
                          size: 16,
                          color: item.isAvailable
                              ? context.colors.ember
                              : context.colors.inkSoft,
                        ),
                      ),
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

class _CartBar extends StatelessWidget {
  const _CartBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        if (cart.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => context.push(Routes.cart),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''}'),
                  const Text('View cart'),
                  Text('${cart.subtotal.toStringAsFixed(1)} TND',
                      style: AppTypography.mono(
                          fontSize: 15, color: context.colors.onEmber)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
