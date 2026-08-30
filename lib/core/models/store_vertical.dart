/// A store type the shopper switches between from the top picker (SPEC: the
/// old Food/Grocery/Pharmacy chips became a single top-of-screen selector).
///
/// A vertical is the browsing lens: it filters the store list by [category].
/// Pure Dart on purpose — icons live in the widget layer, and all user-facing
/// copy (label, tagline, headings…) is localized via the StoreVerticalCopy
/// extension in core/l10n/l10n.dart, never hardcoded here.
enum StoreVertical {
  fastFood,
  groceries,
  pharmacy,
  coffee;

  /// The `Restaurant.category` value this vertical shows.
  String get category => switch (this) {
        StoreVertical.fastFood => 'food',
        StoreVertical.groceries => 'grocery',
        StoreVertical.pharmacy => 'pharmacy',
        StoreVertical.coffee => 'coffee',
      };

  /// Display order in the picker. [fastFood] is the default landing vertical.
  static const menu = <StoreVertical>[
    StoreVertical.fastFood,
    StoreVertical.groceries,
    StoreVertical.pharmacy,
    StoreVertical.coffee,
  ];
}
