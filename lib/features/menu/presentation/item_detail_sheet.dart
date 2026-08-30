import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/menu_item.dart';
import '../../../core/models/order.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/food_image.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../cart/cubit/cart_cubit.dart';

/// Slide-up modal to customize a single item before adding it.
/// By default the built [OrderItem] is added to the personal [CartCubit];
/// pass [onAdd] (e.g. group mode) to route it elsewhere instead.
Future<void> showItemDetailSheet(
  BuildContext context,
  Restaurant restaurant,
  MenuItem item, {
  void Function(OrderItem item)? onAdd,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => BlocProvider.value(
      value: context.read<CartCubit>(),
      child: _ItemDetailSheet(
          restaurant: restaurant, item: item, onAdd: onAdd),
    ),
  );
}

class _ItemDetailSheet extends StatefulWidget {
  const _ItemDetailSheet({
    required this.restaurant,
    required this.item,
    this.onAdd,
  });

  final Restaurant restaurant;
  final MenuItem item;
  final void Function(OrderItem item)? onAdd;

  @override
  State<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<_ItemDetailSheet> {
  final _instructions = TextEditingController();
  final Map<String, MenuChoice> _selected = {};
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    // Preselect the first choice of each option group.
    for (final option in widget.item.options) {
      if (option.choices.isNotEmpty) {
        _selected[option.label] = option.choices.first;
      }
    }
  }

  @override
  void dispose() {
    _instructions.dispose();
    super.dispose();
  }

  double get _unitPrice =>
      widget.item.priceTND +
      _selected.values.fold(0, (sum, c) => sum + c.extraPriceTND);

  void _add() {
    final orderItem = OrderItem(
      menuItemId: widget.item.id,
      name: widget.item.name,
      priceTND: _unitPrice,
      quantity: _qty,
      selectedOptions: {
        for (final e in _selected.entries) e.key: e.value.name,
      },
      specialInstructions: _instructions.text.trim(),
    );
    if (widget.onAdd != null) {
      widget.onAdd!(orderItem);
    } else {
      context.read<CartCubit>().addItem(widget.restaurant, orderItem);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Column(
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  _Hero(item: widget.item),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.item.category.isNotEmpty) ...[
                          _CategoryTag(label: widget.item.category),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(widget.item.name,
                                  style: text.headlineMedium),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${widget.item.priceTND.toStringAsFixed(2)} TND',
                              style: AppTypography.mono(
                                  fontSize: 18, color: context.colors.ember),
                            ),
                          ],
                        ),
                        if (widget.item.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(widget.item.description, style: text.bodyMedium),
                        ],
                        if (widget.item.options.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Customize', style: text.titleLarge),
                          const SizedBox(height: 14),
                          for (final option in widget.item.options)
                            _OptionGroup(
                              option: option,
                              selected: _selected[option.label],
                              onSelect: (c) =>
                                  setState(() => _selected[option.label] = c),
                            ),
                        ],
                        const SizedBox(height: 8),
                        Text('Special instructions', style: text.titleMedium),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _instructions,
                          decoration: const InputDecoration(
                            hintText: 'e.g. no onions, extra spicy…',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _Footer(
              qty: _qty,
              unitPrice: _unitPrice,
              onDec: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
              onInc: () => setState(() => _qty++),
              onAdd: _add,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-bleed food photography at the top of the sheet, with the drag handle
/// floated over it — the image is the hook, so it gets the space.
class _Hero extends StatelessWidget {
  const _Hero({required this.item});
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FoodImage.menuItem(item),
          // Fades the photo into the sheet so there's no hard seam.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x00000000), context.colors.surface],
                begin: Alignment.center,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.ink.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.ember.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: context.colors.emberText),
      ),
    );
  }
}

class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.option,
    required this.selected,
    required this.onSelect,
  });

  final MenuOption option;
  final MenuChoice? selected;
  final void Function(MenuChoice) onSelect;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(option.label, style: text.bodyLarge),
          ),
          Expanded(
            flex: 5,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: option.choices.map((c) {
                final isSelected = selected == c;
                final label = c.extraPriceTND > 0
                    ? '${c.name} +${c.extraPriceTND.toStringAsFixed(1)}'
                    : c.name;
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? context.colors.onEmber
                        : context.colors.inkSoft,
                  ),
                  onSelected: (_) => onSelect(c),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
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
                  // MainAxisSize.min: AppPrimaryButton scales this row down via
                  // FittedBox, which imposes unbounded width.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Add to Cart', maxLines: 1),
                      const SizedBox(width: 10),
                      Text(
                        '${(unitPrice * qty).toStringAsFixed(2)} TND',
                        maxLines: 1,
                        style: AppTypography.mono(
                          fontSize: 14,
                          color: context.colors.onEmber,
                        ),
                      ),
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
