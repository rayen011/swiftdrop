// Pins the keyword mapping: the whole point is that a burger resolves to a
// "burger" photo, not a random one. Asserts on the resolved URL's keyword
// segment for the actual seed dishes.

import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/menu_item.dart';
import 'package:swiftdrop/core/models/restaurant.dart';
import 'package:swiftdrop/core/utils/food_images.dart';
import 'package:swiftdrop/data/seed/seed_data.dart';

/// The keyword LoremFlickr is asked for, e.g. .../600/600/pizza?lock=1 -> pizza.
String _keywordOf(String url) => Uri.parse(url).pathSegments.last;

MenuItem _item(String name, String category) => MenuItem(
      id: 'test_$name',
      restaurantId: 'r',
      category: category,
      name: name,
      priceTND: 1,
    );

void main() {
  group('menu item keywords', () {
    const cases = <(String, String, String)>[
      // name, category, expected keyword
      ('Margherita', 'Pizza', 'pizza'),
      ('Pepperoni', 'Pizza', 'pizza'),
      ('Chicken Tacos', 'Tacos', 'tacos'),
      ('Beef Tacos', 'Tacos', 'tacos'),
      ('Classic Burger', 'Burgers', 'burger'),
      ('Crispy Chicken', 'Burgers', 'burger'),
      ('Nuggets x6', 'Sides', 'nuggets'),
      ('Fries', 'Sides', 'fries'),
      ('Loaded Fries', 'Sides', 'fries'),
      ('Lablabi Classic', 'Lablabi', 'soup'),
      ('California Roll x8', 'Rolls', 'sushi'),
      ('Salmon Nigiri x4', 'Nigiri', 'sushi'),
      ('Cola', 'Drinks', 'cola'),
      ('Lemonade', 'Drinks', 'lemonade'),
      ('Green Tea', 'Drinks', 'tea'),
      ('Water', 'Drinks', 'water'),
      ('Milk 1L', 'Fresh', 'milk'),
      ('Eggs x12', 'Fresh', 'eggs'),
      ('Pasta 500g', 'Pantry', 'pasta'),
      ('Vitamin C', 'Care', 'vitamins'),
      ('Paracetamol', 'Care', 'pills'),
      ('Face Masks x10', 'Essentials', 'mask'),
    ];

    for (final (name, category, keyword) in cases) {
      test('$name -> $keyword', () {
        expect(_keywordOf(FoodImages.forMenuItem(_item(name, category))),
            keyword);
      });
    }

    test('an unknown item falls back to food, never a random tag', () {
      expect(_keywordOf(FoodImages.forMenuItem(_item('Mystery', 'Unknown'))),
          'food');
    });
  });

  group('restaurant keywords', () {
    const cases = <(String, String, String)>[
      ('Dar El Pizza', 'food', 'pizza'),
      ('Sushi Lac', 'food', 'sushi'),
      ('Tacos Tunis', 'food', 'tacos'),
      ('Burger Marsa', 'food', 'burger'),
      ('Lablabi House', 'food', 'soup'),
      ('Monoprix Express', 'grocery', 'groceries'),
      ('Pharmacie Centrale', 'pharmacy', 'pharmacy'),
    ];

    for (final (name, category, keyword) in cases) {
      test('$name -> $keyword', () {
        final r = Restaurant(
            id: 'r_$name', name: name, category: category, neighborhood: 'z');
        expect(_keywordOf(FoodImages.forRestaurant(r)), keyword);
      });
    }
  });

  group('stability', () {
    test('the same id always resolves to the same photo', () {
      final a = FoodImages.forMenuItem(_item('Margherita', 'Pizza'));
      final b = FoodImages.forMenuItem(_item('Margherita', 'Pizza'));
      expect(a, b); // deterministic lock -> stable screenshots
    });

    test('two dishes sharing a keyword still get different photos', () {
      final margherita =
          FoodImages.forMenuItem(_item('Margherita', 'Pizza'));
      final pepperoni = FoodImages.forMenuItem(_item('Pepperoni', 'Pizza'));
      expect(margherita, isNot(pepperoni)); // same keyword, different lock
    });
  });

  group('every seeded dish and restaurant resolves', () {
    // Guards against a future seed item that maps to nothing meaningful. Every
    // real menu item should hit a specific keyword, not the generic fallback.
    test('no seeded menu item falls through to the generic default', () {
      for (final items in seedMenus.values) {
        for (final item in items) {
          final keyword = _keywordOf(FoodImages.forMenuItem(item));
          expect(keyword, isNot('food'),
              reason: '${item.name} (${item.category}) has no specific photo');
        }
      }
    });

    test('every seeded restaurant resolves to a real URL', () {
      for (final r in seedRestaurants) {
        expect(FoodImages.forRestaurant(r), startsWith('https://'));
      }
    });
  });
}
