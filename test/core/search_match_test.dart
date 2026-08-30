import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/restaurant.dart';
import 'package:swiftdrop/features/search/presentation/search_screen.dart';

const _pizza = Restaurant(
  id: 'dar_el_pizza',
  name: 'Dar El Pizza',
  category: 'food',
  neighborhood: 'lac2',
  menuCategories: ['Pizza', 'Sides', 'Drinks'],
);

const _burger = Restaurant(
  id: 'burger_marsa',
  name: 'Burger Marsa',
  category: 'food',
  neighborhood: 'la_marsa',
  menuCategories: ['Burgers', 'Sides'],
);

void main() {
  group('storeMatchesQuery', () {
    test('empty query matches everything (browse mode)', () {
      expect(storeMatchesQuery(_pizza, ''), isTrue);
      expect(storeMatchesQuery(_pizza, '   '), isTrue);
    });

    test('matches on name, case-insensitively', () {
      expect(storeMatchesQuery(_pizza, 'dar'), isTrue);
      expect(storeMatchesQuery(_pizza, 'PIZZA'), isTrue);
      expect(storeMatchesQuery(_burger, 'marsa'), isTrue);
    });

    test('matches on what the store sells (menuCategories)', () {
      // "burgers" isn't in the name but is what they sell.
      expect(storeMatchesQuery(_burger, 'burger'), isTrue);
      expect(storeMatchesQuery(_pizza, 'sides'), isTrue);
    });

    test('rejects a non-match', () {
      expect(storeMatchesQuery(_burger, 'sushi'), isFalse);
      expect(storeMatchesQuery(_pizza, 'pharmacy'), isFalse);
    });
  });
}
