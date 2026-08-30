import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/skeletons.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../core/models/favorite_item.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/cubit/cart_state.dart';
import '../../favorites/cubit/favorites_cubit.dart';
import 'pharmacy_product_screen.dart';
import 'widgets/medicine_card.dart';
import 'widgets/medicine_request_sheet.dart';

/// Pharmacy storefront: a "Recommendation" medicine grid plus a prominent
/// photo-request entry for items not in the catalogue.
class PharmacyStoreScreen extends StatefulWidget {
  const PharmacyStoreScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  State<PharmacyStoreScreen> createState() => _PharmacyStoreScreenState();
}

class _PharmacyStoreScreenState extends State<PharmacyStoreScreen> {
  final _repo = sl<RestaurantRepository>();
  String _query = '';

  /// Subscribed once — typing must not recreate the Firestore stream.
  late final Stream<List<MenuItem>> _menu =
      _repo.watchMenu(widget.restaurant.id);

  Restaurant get restaurant => widget.restaurant;

  List<MenuItem> _filtered(List<MenuItem> items) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q) ||
            i.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<MenuItem>>(
          stream: _menu,
          builder: (context, snapshot) {
            final loading =
                snapshot.connectionState == ConnectionState.waiting;
            final items = _filtered(snapshot.data ?? []);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(restaurant: restaurant),
                        const SizedBox(height: 16),
                        _SearchBar(
                          onChanged: (v) => setState(() => _query = v),
                        ),
                        const SizedBox(height: 14),
                        _RequestBanner(
                          onTap: () => showMedicineRequestSheet(context),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(context.l10n.recommendation,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(width: 8),
                            if (!loading)
                              Text('· ${items.length}',
                                  style: AppTypography.mono(
                                      fontSize: 13,
                                      color: context.colors.inkSoft)),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (loading)
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver:
                        SliverToBoxAdapter(child: ProductGridSkeleton()),
                  )
                else if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text(_query.trim().isEmpty
                            ? context.l10n.noItemsYet
                            : context.l10n.noMatchesTryPhoto),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: 268,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final item = items[i];
                          return BlocBuilder<FavoritesCubit, FavoritesState>(
                            builder: (context, favs) => MedicineCard(
                              restaurant: restaurant,
                              item: item,
                              isFavorite: favs.contains(item.id),
                              onFavorite: () => context
                                  .read<FavoritesCubit>()
                                  .toggle(FavoriteItem.of(restaurant, item)),
                              onTap: () => context.push(
                                Routes.pharmacyProduct,
                                extra: PharmacyProductArgs(
                                    restaurant: restaurant, item: item),
                              ),
                            ),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _CartBar(restaurant: restaurant),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppCircleButton(
          icon: Icons.arrow_back_rounded,
          size: 42,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                context.l10n.deliveredToDoor(restaurant.estimatedMinutes),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.mono(
                    fontSize: 12, color: context.colors.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: context.l10n.searchHintPharmacy,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 6),
          child: Icon(Icons.search_rounded, color: context.colors.inkSoft),
        ),
      ),
    );
  }
}

class _RequestBanner extends StatelessWidget {
  const _RequestBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              pharmacyAccent.withValues(alpha: 0.22),
              context.colors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: pharmacyAccent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: pharmacyAccent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_a_photo_outlined,
                  color: pharmacyAccent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.cantFindMedicine,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(context.l10n.requestBannerSubtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: context.colors.inkSoft),
          ],
        ),
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        if (cart.isEmpty || cart.restaurant?.id != restaurant.id) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppPrimaryButton(
              onPressed: () => context.push(Routes.cart),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.cartItemCount(cart.itemCount)),
                  const SizedBox(width: 10),
                  Text('· ${context.l10n.viewCart} ·'),
                  const SizedBox(width: 10),
                  Text('${cart.total.toStringAsFixed(1)} TND',
                      style: AppTypography.mono(
                          fontSize: 14, color: context.colors.onEmber)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
