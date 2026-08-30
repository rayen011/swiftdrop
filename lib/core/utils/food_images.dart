import '../models/menu_item.dart';
import '../models/restaurant.dart';

/// Resolves real food photography for a restaurant or dish.
///
/// The old placeholder ([picsum.photos]) served *random* images — a burger card
/// might show a mountain — which is useless for App Store screenshots. This
/// keyword-matches the actual item (a burger resolves to a burger, sushi to
/// sushi) and pins each photo with a per-id lock, so a card keeps the same
/// picture across rebuilds and screenshots stay stable.
///
/// This is still placeholder imagery, served by LoremFlickr. A real partner's
/// own `imageUrl` from Firestore always wins (see [AppNetworkImage] — it only
/// falls back here when `imageUrl` is empty). To move to curated or bundled
/// artwork later, change only this file.
abstract final class FoodImages {
  /// Base folder for bundled food photos. A file named `{keyword}.jpg` here is
  /// preferred over the network image (see [FoodImage]); anything missing falls
  /// back to the network, so the app is never broken mid-setup.
  static const assetDir = 'assets/food';

  static String forRestaurant(Restaurant restaurant) =>
      _url(_restaurantKeyword(restaurant), restaurant.id, 800, 500);

  static String forMenuItem(MenuItem item) =>
      _url(_menuKeyword(item), item.id, 600, 600);

  /// Bundled-asset path for a dish, e.g. `assets/food/burger.jpg`. Keyed by the
  /// same keyword as the network image, so one file covers every burger.
  static String assetForMenuItem(MenuItem item) =>
      '$assetDir/${_menuKeyword(item)}.jpg';

  static String assetForRestaurant(Restaurant restaurant) =>
      '$assetDir/${_restaurantKeyword(restaurant)}.jpg';

  /// Every keyword an asset file could be named after — the shopping list for
  /// whoever populates [assetDir].
  static const assetKeywords = <String>{
    'pizza', 'tacos', 'burger', 'nuggets', 'soup', 'sushi', 'harissa',
    'fries', 'lemonade', 'cola', 'tea', 'water', 'milk', 'eggs', 'pasta',
    'vitamins', 'pills', 'mask', 'drink', 'groceries', 'medicine',
    'pharmacy', 'food', 'restaurant', 'coffee', 'juice', 'croissant',
    'orange', 'apple', 'tomato', 'lettuce', 'corn', 'skincare',
  };

  // --- URL ---
  //
  // LoremFlickr returns a real Flickr photo tagged with [keyword]; `lock` pins
  // one specific photo so the same id always yields the same image. Two dishes
  // that share a keyword still differ, because their ids seed different locks.
  static String _url(String keyword, String seed, int width, int height) =>
      'https://loremflickr.com/$width/$height/$keyword?lock=${seed.hashCode.abs()}';

  // --- keyword resolution ---
  //
  // Substring rules on the lowercased name run first (most specific), then the
  // category, then a safe default. Name-first keeps new seed items working
  // without a code change. Single-word tags on purpose: a tag LoremFlickr can't
  // match falls back to a *random* photo, which is the bug we're fixing.

  static String _menuKeyword(MenuItem item) {
    final name = item.name.toLowerCase();
    for (final (needle, keyword) in _nameRules) {
      if (name.contains(needle)) return keyword;
    }
    return _categoryKeyword[item.category.toLowerCase()] ?? 'food';
  }

  static String _restaurantKeyword(Restaurant restaurant) {
    final name = restaurant.name.toLowerCase();
    for (final (needle, keyword) in _cuisineRules) {
      if (name.contains(needle)) return keyword;
    }
    return switch (restaurant.category.toLowerCase()) {
      'grocery' => 'groceries',
      'pharmacy' => 'pharmacy',
      'coffee' => 'coffee',
      _ => 'restaurant',
    };
  }

  /// Ordered: earlier, more specific rules win. Keep pizza/taco/burger/nugget
  /// ahead of anything that could also match them.
  static const _nameRules = <(String, String)>[
    ('pizza', 'pizza'),
    ('pepperoni', 'pizza'),
    ('margher', 'pizza'),
    ('taco', 'tacos'),
    ('nugget', 'nuggets'),
    ('burger', 'burger'),
    ('lablabi', 'soup'),
    ('sushi', 'sushi'),
    ('roll', 'sushi'),
    ('nigiri', 'sushi'),
    ('salmon', 'sushi'),
    ('harissa', 'harissa'),
    ('fries', 'fries'),
    ('croissant', 'croissant'),
    ('espresso', 'coffee'),
    ('cappuccino', 'coffee'),
    ('latte', 'coffee'),
    ('coffee', 'coffee'),
    ('juice', 'juice'),
    ('orange', 'orange'),
    ('apple', 'apple'),
    ('tomato', 'tomato'),
    ('lettuce', 'lettuce'),
    ('corn', 'corn'),
    ('lemon', 'lemonade'),
    ('cola', 'cola'),
    ('tea', 'tea'),
    ('water', 'water'),
    ('milk', 'milk'),
    ('egg', 'eggs'),
    ('pasta', 'pasta'),
    ('vitamin', 'vitamins'),
    ('paracet', 'pills'),
    ('tablet', 'pills'),
    ('syrup', 'medicine'),
    ('cough', 'medicine'),
    ('face wash', 'skincare'),
    ('cleanser', 'skincare'),
    ('plaster', 'pharmacy'),
    ('mask', 'mask'),
  ];

  static const _categoryKeyword = <String, String>{
    'pizza': 'pizza',
    'tacos': 'tacos',
    'burgers': 'burger',
    'lablabi': 'soup',
    'rolls': 'sushi',
    'nigiri': 'sushi',
    'drinks': 'drink',
    'coffee': 'coffee',
    'cold': 'juice',
    'bakery': 'croissant',
    'fresh': 'groceries',
    'pantry': 'groceries',
    'care': 'medicine',
    'essentials': 'pharmacy',
  };

  static const _cuisineRules = <(String, String)>[
    ('pizza', 'pizza'),
    ('sushi', 'sushi'),
    ('taco', 'tacos'),
    ('burger', 'burger'),
    ('lablabi', 'soup'),
    ('café', 'coffee'),
    ('cafe', 'coffee'),
    ('coffee', 'coffee'),
    ('monoprix', 'groceries'),
    ('pharmac', 'pharmacy'),
  ];
}
