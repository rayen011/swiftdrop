import 'package:equatable/equatable.dart';

import 'menu_item.dart';
import 'restaurant.dart';

/// A hearted product, stored on the user document.
///
/// Carries enough display data (name, price, store) to render a favorites list
/// without fetching every store's menu — the id alone would force N
/// subcollection reads just to show what the user saved. Display data can go
/// stale if a store renames an item; the id is the identity, the rest is a
/// snapshot.
class FavoriteItem extends Equatable {
  const FavoriteItem({
    required this.itemId,
    required this.restaurantId,
    required this.restaurantName,
    required this.name,
    required this.priceTND,
  });

  factory FavoriteItem.of(Restaurant restaurant, MenuItem item) => FavoriteItem(
        itemId: item.id,
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        name: item.name,
        priceTND: item.priceTND,
      );

  final String itemId;
  final String restaurantId;
  final String restaurantName;
  final String name;
  final double priceTND;

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'name': name,
        'priceTND': priceTND,
      };

  factory FavoriteItem.fromMap(Map<String, dynamic> map) => FavoriteItem(
        itemId: map['itemId'] as String? ?? '',
        restaurantId: map['restaurantId'] as String? ?? '',
        restaurantName: map['restaurantName'] as String? ?? '',
        name: map['name'] as String? ?? '',
        priceTND: (map['priceTND'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [itemId, restaurantId, name, priceTND];
}
