import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/models/favorite_item.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/order.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/food_image.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../favorites/cubit/favorites_cubit.dart';

/// Navigation payload for [GroceryProductScreen].
class GroceryProductArgs {
  const GroceryProductArgs({required this.restaurant, required this.item});
  final Restaurant restaurant;
  final MenuItem item;
}

/// Compact TND: 3.0 -> "3", 5.5 -> "5.5".
String _tnd(double v) =>
    '${v.truncateToDouble() == v ? v.toStringAsFixed(0) : v.toStringAsFixed(1)} TND';

/// Full-screen grocery product page (ShopMate detail): hero image, price with
/// MRP, description, selling points, and a sticky add-to-cart bar with quantity.
class GroceryProductScreen extends StatefulWidget {
  const GroceryProductScreen({super.key, required this.args});

  final GroceryProductArgs args;

  @override
  State<GroceryProductScreen> createState() => _GroceryProductScreenState();
}

class _GroceryProductScreenState extends State<GroceryProductScreen> {
  int _qty = 1;

  Restaurant get restaurant => widget.args.restaurant;
  MenuItem get item => widget.args.item;

  void _addToCart() {
    context.read<CartCubit>().addItem(
          restaurant,
          OrderItem(
            menuItemId: item.id,
            name: item.name,
            priceTND: item.priceTND,
            quantity: _qty,
          ),
        );
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.addedToCart(_qty, item.name))),
    );
    navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, favs) => _Hero(
                    item: item,
                    favorite: favs.contains(item.id),
                    onFavorite: () => context
                        .read<FavoritesCubit>()
                        .toggle(FavoriteItem.of(restaurant, item)),
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Chip(
                            icon: Icons.schedule_rounded,
                            label: context.l10n
                                .minsChip(restaurant.estimatedMinutes),
                          ),
                          if (item.unit.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            _Chip(label: item.unit, accent: true),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(item.name, style: text.displayLarge),
                      const SizedBox(height: 8),
                      _PriceRow(item: item),
                      const SizedBox(height: 24),
                      if (item.description.isNotEmpty) ...[
                        Text(context.l10n.aboutProduct,
                            style: text.titleLarge),
                        const SizedBox(height: 8),
                        Text(item.description,
                            style: text.bodyMedium?.copyWith(height: 1.5)),
                        const SizedBox(height: 24),
                      ],
                      if (item.highlights.isNotEmpty) ...[
                        Text(context.l10n.whyYoullLoveIt,
                            style: text.titleLarge),
                        const SizedBox(height: 10),
                        ...item.highlights.map((h) => _Bullet(text: h)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _BottomBar(
            qty: _qty,
            unitPrice: item.priceTND,
            onDec: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
            onInc: () => setState(() => _qty++),
            onAdd: _addToCart,
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.item,
    required this.favorite,
    required this.onFavorite,
    required this.onBack,
  });

  final MenuItem item;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: FoodImage.menuItem(item),
        ),
        // Fade into the page so there's no hard seam under the image.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x00000000), context.colors.background],
                begin: Alignment(0, 0.4),
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AppCircleButton(
                    icon: Icons.arrow_back_rounded, size: 42, onTap: onBack),
                const Spacer(),
                AppCircleButton(
                  icon: favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 42,
                  iconColor: favorite ? context.colors.error : null,
                  onTap: onFavorite,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({this.icon, required this.label, this.accent = false});

  final IconData? icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? context.colors.ember : context.colors.inkSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accent
            ? context.colors.ember.withValues(alpha: 0.14)
            : context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
            color: accent ? Colors.transparent : context.colors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppTypography.mono(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.item});
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(_tnd(item.priceTND),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.mono(fontSize: 24, color: context.colors.ember)
                  .copyWith(fontWeight: FontWeight.w700)),
        ),
        if (item.isOnSale) ...[
          const SizedBox(width: 10),
          Text(context.l10n.mrp(_tnd(item.mrpTND)),
              style: AppTypography.mono(
                      fontSize: 14, color: context.colors.inkSoft)
                  .copyWith(
                decoration: TextDecoration.lineThrough,
                decorationColor: context.colors.inkSoft,
              )),
        ],
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.eco.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded,
                size: 13, color: context.colors.eco),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.qty,
    required this.unitPrice,
    required this.onDec,
    required this.onInc,
    required this.onAdd,
  });

  final int qty;
  final double unitPrice;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              QuantityStepper(
                quantity: qty,
                onDecrement: onDec,
                onIncrement: onInc,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppPrimaryButton(
                  onPressed: onAdd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.l10n.addToCart),
                      const SizedBox(width: 10),
                      Text(_tnd(unitPrice * qty),
                          style: AppTypography.mono(
                              fontSize: 14, color: context.colors.onEmber)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
