import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/models/store_vertical.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';

/// Maps a vertical to its icon. Lives here, not on the model, so [StoreVertical]
/// stays pure Dart.
IconData storeVerticalIcon(StoreVertical v) => switch (v) {
      StoreVertical.fastFood => Icons.lunch_dining_rounded,
      StoreVertical.groceries => Icons.local_grocery_store_rounded,
      StoreVertical.pharmacy => Icons.medical_services_rounded,
      StoreVertical.coffee => Icons.local_cafe_rounded,
    };

/// Each store type owns an accent colour. Switching verticals recolours the top
/// of Home (see the accent wash + selector), so the change reads as a change of
/// mode — not just a different list of items. Brand ember stays the app-wide
/// action colour; these accents live in the home header only.
Color storeVerticalAccent(BuildContext context, StoreVertical v) => switch (v) {
      StoreVertical.fastFood => context.colors.ember, // ember
      StoreVertical.groceries => context.colors.eco, // fresh green
      StoreVertical.pharmacy => const Color(0xFF3BAFDA), // calm blue
      StoreVertical.coffee => const Color(0xFFCB8A4E), // caramel
    };

LinearGradient storeVerticalGradient(BuildContext context, StoreVertical v) {
  final accent = storeVerticalAccent(context, v);
  return LinearGradient(
    colors: [Color.lerp(accent, Colors.white, 0.18)!, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// The pressable bar at the top of Home that shows the active store type and
/// opens the picker. This replaces the old category chips.
class StoreSelectorBar extends StatelessWidget {
  const StoreSelectorBar({
    super.key,
    required this.vertical,
    required this.onChanged,
  });

  final StoreVertical vertical;
  final ValueChanged<StoreVertical> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showStorePicker(context, vertical);
        if (picked != null && picked != vertical) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: context.colors.line),
        ),
        child: Row(
          children: [
            _IconBadge(vertical: vertical),
            const SizedBox(width: 12),
            // Expanded + single-line ellipsis: a long label ("Coffee & Drinks")
            // on a narrow phone truncates instead of overflowing the row.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.shoppingFor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 2),
                  Text(vertical.label(context.l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: storeVerticalAccent(context, vertical)),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet dropdown listing every store type. Returns the chosen vertical,
/// or null if dismissed.
Future<StoreVertical?> showStorePicker(
  BuildContext context,
  StoreVertical current,
) {
  return showModalBottomSheet<StoreVertical>(
    context: context,
    backgroundColor: context.colors.surface,
    // Content-height sheet, but capped and scrollable so it can never overflow
    // on a short screen (or when the OS text size is cranked up).
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => StorePickerSheet(
      current: current,
      onSelect: (v) => Navigator.of(sheetContext).pop(v),
    ),
  );
}

/// The picker's body, extracted so it can be pumped directly in layout tests
/// (bottom sheets are awkward to drive in widget tests).
class StorePickerSheet extends StatelessWidget {
  const StorePickerSheet({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final StoreVertical current;
  final ValueChanged<StoreVertical> onSelect;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
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
              Text(context.l10n.chooseStoreType,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(context.l10n.storeTypeSubtitle,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              for (final v in StoreVertical.menu)
                _StoreOption(
                  vertical: v,
                  selected: v == current,
                  onTap: () => onSelect(v),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.vertical});

  final StoreVertical vertical;

  @override
  Widget build(BuildContext context) {
    // AnimatedContainer so the badge smoothly recolours when the vertical
    // changes in the selector bar.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: storeVerticalGradient(context, vertical),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        storeVerticalIcon(vertical),
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _StoreOption extends StatelessWidget {
  const _StoreOption({
    required this.vertical,
    required this.selected,
    required this.onTap,
  });

  final StoreVertical vertical;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surfaceHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? context.colors.ember : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              _IconBadge(vertical: vertical),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vertical.label(context.l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(vertical.tagline(context.l10n),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
      ),
    );
  }
}
