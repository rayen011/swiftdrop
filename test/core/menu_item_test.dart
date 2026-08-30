import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/menu_item.dart';

void main() {
  group('MenuItem sale pricing', () {
    test('no MRP means not on sale', () {
      const item = MenuItem(
        id: 'x',
        restaurantId: 'r',
        category: 'Fresh',
        name: 'Corn',
        priceTND: 2.0,
      );
      expect(item.isOnSale, isFalse);
      expect(item.discountPercent, 0);
    });

    test('MRP above price is a sale with a rounded percent', () {
      const item = MenuItem(
        id: 'x',
        restaurantId: 'r',
        category: 'Fresh',
        name: 'Sweet Oranges',
        priceTND: 3.0,
        mrpTND: 4.0,
      );
      expect(item.isOnSale, isTrue);
      expect(item.discountPercent, 25);
    });

    test('an MRP at or below price is ignored', () {
      const item = MenuItem(
        id: 'x',
        restaurantId: 'r',
        category: 'Fresh',
        name: 'Thing',
        priceTND: 5.0,
        mrpTND: 5.0,
      );
      expect(item.isOnSale, isFalse);
    });

    test('mrp / unit / highlights / rating round-trip through the map', () {
      const item = MenuItem(
        id: 'mp_oranges',
        restaurantId: 'monoprix',
        category: 'Fresh',
        name: 'Sweet Oranges',
        priceTND: 3.0,
        mrpTND: 4.0,
        unit: '500g',
        highlights: ['100% natural', 'Rich in vitamin C'],
        rating: 4.6,
      );
      final restored = MenuItem.fromMap(item.toMap());
      expect(restored.mrpTND, 4.0);
      expect(restored.unit, '500g');
      expect(restored.highlights, ['100% natural', 'Rich in vitamin C']);
      expect(restored.rating, 4.6);
      expect(restored.isOnSale, isTrue);
      expect(restored, item); // props include all display fields
    });
  });
}
