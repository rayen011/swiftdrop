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
import 'widgets/medicine_request_sheet.dart';

class PharmacyProductArgs {
  const PharmacyProductArgs({required this.restaurant, required this.item});
  final Restaurant restaurant;
  final MenuItem item;
}

/// Full-screen medicine detail: rating, SKU, description, add-to-cart, and a
/// shortcut to the (mock) photo request.
class PharmacyProductScreen extends StatefulWidget {
  const PharmacyProductScreen({super.key, required this.args});

  final PharmacyProductArgs args;

  @override
  State<PharmacyProductScreen> createState() => _PharmacyProductScreenState();
}

class _PharmacyProductScreenState extends State<PharmacyProductScreen> {
  int _qty = 1;

  Restaurant get restaurant => widget.args.restaurant;
  MenuItem get item => widget.args.item;

  String get _sku => 'SKU ${item.id.toUpperCase().replaceAll('_', '-')}';

  void _add() {
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
                      // Wrap, not Row: at a large text scale the rating + a long
                      // category tag would overflow a single line.
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (item.rating > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 18, color: context.colors.star),
                                const SizedBox(width: 4),
                                Text('${item.rating.toStringAsFixed(1)}/5',
                                    style: AppTypography.mono(fontSize: 13)),
                              ],
                            ),
                          _Tag(label: item.category, accent: true),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(item.name, style: text.headlineLarge),
                      const SizedBox(height: 6),
                      Text(_sku,
                          style: AppTypography.mono(
                              fontSize: 12, color: context.colors.inkSoft)),
                      const SizedBox(height: 14),
                      _PriceRow(item: item),
                      const SizedBox(height: 24),
                      if (item.description.isNotEmpty) ...[
                        Text(context.l10n.description, style: text.titleLarge),
                        const SizedBox(height: 8),
                        Text(item.description,
                            style: text.bodyMedium?.copyWith(height: 1.5)),
                        const SizedBox(height: 24),
                      ],
                      _RequestTile(
                        onTap: () => showMedicineRequestSheet(context),
                      ),
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
            onAdd: _add,
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.accent = false});
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent
            ? pharmacyAccent.withValues(alpha: 0.14)
            : context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: accent ? pharmacyAccent : null)),
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
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('${item.priceTND.toStringAsFixed(2)} TND',
              style: AppTypography.mono(fontSize: 24, color: context.colors.ember)
                  .copyWith(fontWeight: FontWeight.w700)),
          if (item.isOnSale) ...[
            const SizedBox(width: 10),
            Text('MRP ${item.mrpTND.toStringAsFixed(2)}',
                style: AppTypography.mono(
                        fontSize: 14, color: context.colors.inkSoft)
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

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: pharmacyAccent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: pharmacyAccent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_a_photo_outlined, color: pharmacyAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.cantFindNeed,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(context.l10n.requestTileSubtitle,
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
                      Text('${(unitPrice * qty).toStringAsFixed(2)} TND',
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
