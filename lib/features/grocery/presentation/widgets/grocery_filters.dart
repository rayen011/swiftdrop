import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';

/// Grocery grid sort order. Display copy is looked up via [pillLabel] /
/// [optionLabel] so it's translated.
enum GrocerySort {
  recommended,
  priceAsc,
  priceDesc;

  /// Compact label for the filter pill.
  String pillLabel(AppLocalizations l10n) => switch (this) {
        GrocerySort.recommended => l10n.sortBy,
        GrocerySort.priceAsc => l10n.priceAscShort,
        GrocerySort.priceDesc => l10n.priceDescShort,
      };

  /// Full label in the sort sheet.
  String optionLabel(AppLocalizations l10n) => switch (this) {
        GrocerySort.recommended => l10n.sortRecommended,
        GrocerySort.priceAsc => l10n.sortPriceAsc,
        GrocerySort.priceDesc => l10n.sortPriceDesc,
      };
}

/// Sort / Category / Offers — real filters over the grid. The row scrolls
/// horizontally so it never overflows on a narrow phone.
class GroceryFilterRow extends StatelessWidget {
  const GroceryFilterRow({
    super.key,
    required this.sort,
    required this.category,
    required this.offersOnly,
    required this.categories,
    required this.onSort,
    required this.onCategory,
    required this.onOffers,
  });

  final GrocerySort sort;
  final String? category;
  final bool offersOnly;
  final List<String> categories;
  final ValueChanged<GrocerySort> onSort;
  final ValueChanged<String?> onCategory;
  final ValueChanged<bool> onOffers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Pill(
            icon: Icons.swap_vert_rounded,
            label: sort.pillLabel(context.l10n),
            active: sort != GrocerySort.recommended,
            onTap: () async {
              final picked = await _pickSort(context, sort);
              if (picked != null) onSort(picked);
            },
          ),
          const SizedBox(width: 10),
          _Pill(
            icon: Icons.category_outlined,
            label: category ?? context.l10n.categoryLabel,
            active: category != null,
            onTap: () async {
              final picked = await _pickCategory(context, categories, category);
              // Sentinel: the sheet returns '' to mean "All".
              if (picked != null) onCategory(picked.isEmpty ? null : picked);
            },
          ),
          const SizedBox(width: 10),
          _Pill(
            icon: Icons.local_offer_outlined,
            label: context.l10n.offers,
            active: offersOnly,
            onTap: () => onOffers(!offersOnly),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? context.colors.ember.withValues(alpha: 0.16)
                : context.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(
                color: active ? context.colors.ember : context.colors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: active ? context.colors.ember : context.colors.inkSoft),
              const SizedBox(width: 6),
              Text(label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: active ? context.colors.ember : context.colors.ink,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

Future<GrocerySort?> _pickSort(BuildContext context, GrocerySort current) {
  return _sheet<GrocerySort>(
    context,
    title: context.l10n.sortBy,
    children: [
      for (final value in GrocerySort.values)
        _OptionRow(
          label: value.optionLabel(context.l10n),
          selected: value == current,
          onTap: () => Navigator.of(context).pop(value),
        ),
    ],
  );
}

Future<String?> _pickCategory(
  BuildContext context,
  List<String> categories,
  String? current,
) {
  return _sheet<String>(
    context,
    title: context.l10n.categoryLabel,
    children: [
      _OptionRow(
        label: context.l10n.allCategories,
        selected: current == null,
        onTap: () => Navigator.of(context).pop(''), // '' = all
      ),
      for (final c in categories)
        _OptionRow(
          label: c,
          selected: c == current,
          onTap: () => Navigator.of(context).pop(c),
        ),
    ],
  );
}

/// Scroll-safe bottom sheet used by the filter pickers.
Future<T?> _sheet<T>(
  BuildContext context, {
  required String title,
  required List<Widget> children,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: context.colors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color:
                            selected ? context.colors.ember : context.colors.ink,
                      )),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? context.colors.ember : context.colors.inkSoft,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
