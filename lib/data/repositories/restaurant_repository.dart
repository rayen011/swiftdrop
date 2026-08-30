import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/menu_item.dart';
import '../../core/models/restaurant.dart';

/// Reads restaurants and their menus from Firestore.
class RestaurantRepository {
  RestaurantRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _restaurants =>
      _db.collection('restaurants');

  Stream<List<Restaurant>> watchRestaurants({String? category}) {
    Query<Map<String, dynamic>> query = _restaurants;
    if (category != null && category != 'all') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map(
          (snap) => snap.docs.map((d) => Restaurant.fromMap(d.data())).toList(),
        );
  }

  Future<List<Restaurant>> fetchRestaurants() async {
    final snap = await _restaurants.get();
    return snap.docs.map((d) => Restaurant.fromMap(d.data())).toList();
  }

  Future<Restaurant?> fetchRestaurant(String id) async {
    final doc = await _restaurants.doc(id).get();
    return doc.exists ? Restaurant.fromMap(doc.data()!) : null;
  }

  Stream<List<MenuItem>> watchMenu(String restaurantId) {
    return _restaurants
        .doc(restaurantId)
        .collection('menuItems')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MenuItem.fromMap(d.data())).toList());
  }

  Future<List<MenuItem>> fetchMenu(String restaurantId) async {
    final snap =
        await _restaurants.doc(restaurantId).collection('menuItems').get();
    return snap.docs.map((d) => MenuItem.fromMap(d.data())).toList();
  }

  /// True if at least one restaurant exists (used to decide whether to seed).
  Future<bool> hasData() async {
    final snap = await _restaurants.limit(1).get();
    return snap.docs.isNotEmpty;
  }
}
