import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/skeletons.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../../core/models/favorite_item.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/cubit/cart_state.dart';
import '../../favorites/cubit/favorites_cubit.dart';
import 'grocery_product_screen.dart';
import 'widgets/grocery_product_card.dart';
import 'widgets/grocery_filters.dart';

/// The ShopMate-style grocery storefront — a product grid instead of a menu
/// list, shown when a shopper opens a `grocery` store. Sort / Category / Offers
/// are real filters, not decoration.
class GroceryStoreScreen extends StatefulWidget {
  const GroceryStoreScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  State<GroceryStoreScreen> createState() => _GroceryStoreScreenState();
}

class _GroceryStoreScreenState extends State<GroceryStoreScreen> {
  final _repo = sl<RestaurantRepository>();

  /// Subscribed once — setState (typing, filters) must not recreate the
  /// Firestore stream on every rebuild.
  late final Stream<List<MenuItem>> _menu =
      _repo.watchMenu(widget.restaurant.id);

  GrocerySort _sort = GrocerySort.recommended;
  String? _category; // null = all categories
  bool _offersOnly = false;
  String _query = '';

  Restaurant get restaurant => widget.restaurant;

  List<MenuItem> _apply(List<MenuItem> items) {
    final q = _query.trim().toLowerCase();
    var list = items.where((i) {
      if (_category != null && i.category != _category) return false;
      if (_offersOnly && !i.isOnSale) return false;
      if (q.isNotEmpty &&
          !i.name.toLowerCase().contains(q) &&
          !i.description.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();

    switch (_sort) {
      case GrocerySort.priceAsc:
        list.sort((a, b) => a.priceTND.compareTo(b.priceTND));
      case GrocerySort.priceDesc:
        list.sort((a, b) => b.priceTND.compareTo(a.priceTND));
      case GrocerySort.recommended:
        break;
    }
    return list;
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
            final all = snapshot.data ?? [];
            final categories =
                {for (final i in all) i.category}.toList(growable: false);
            final items = _apply(all);

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
                        GroceryFilterRow(
                          sort: _sort,
                          category: _category,
                          offersOnly: _offersOnly,
                          categories: categories,
                          onSort: (s) => setState(() => _sort = s),
                          onCategory: (c) => setState(() => _category = c),
                          onOffers: (v) => setState(() => _offersOnly = v),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(context.l10n.freshItems,
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
                      child:
                          Center(child: Text(context.l10n.noFilterMatches)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      // maxCrossAxisExtent keeps it 2-up on phones and adds
                      // columns on tablets; the fixed mainAxisExtent gives each
                      // card a known height so text can't push it into overflow.
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: 264,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final item = items[i];
                          return BlocBuilder<FavoritesCubit, FavoritesState>(
                            builder: (context, favs) => GroceryProductCard(
                              restaurant: restaurant,
                              item: item,
                              isFavorite: favs.contains(item.id),
                              onFavorite: () => context
                                  .read<FavoritesCubit>()
                                  .toggle(FavoriteItem.of(restaurant, item)),
                              onTap: () => _openItem(item),
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

  void _openItem(MenuItem item) => context.push(
        Routes.groceryProduct,
        extra: GroceryProductArgs(restaurant: restaurant, item: item),
      );
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
                context.l10n.minFeeDelivery(restaurant.estimatedMinutes,
                    restaurant.deliveryFeeTND.toStringAsFixed(1)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.mono(
                    fontSize: 12, color: context.colors.inkSoft),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const AppCircleButton(icon: Icons.favorite_border_rounded, size: 42),
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
        hintText: context.l10n.searchHintGroceries,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 6),
          child: Icon(Icons.search_rounded, color: context.colors.inkSoft),
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
        // Only show the bar for this store's cart.
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
