import 'package:cloud_firestore/cloud_firestore.dart';

import 'seed_data.dart';

/// Writes neighborhoods + restaurants + menus to Firestore in one batch.
/// Idempotent at the doc level (set overwrites), so safe to re-run.
class FirestoreSeeder {
  FirestoreSeeder({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Seeds only if there are no restaurants yet, unless [force] is set.
  Future<bool> seedIfEmpty({bool force = false}) async {
    if (!force) {
      final existing = await _db.collection('restaurants').limit(1).get();
      if (existing.docs.isNotEmpty) return false;
    }
    await seed();
    return true;
  }

  Future<void> seed() async {
    final batch = _db.batch();

    for (final n in seedNeighborhoods) {
      batch.set(_db.collection('neighborhoods').doc(n.id), n.toMap());
    }

    for (final r in seedRestaurants) {
      final ref = _db.collection('restaurants').doc(r.id);
      batch.set(ref, r.toMap());
      for (final item in seedMenus[r.id] ?? const []) {
        batch.set(ref.collection('menuItems').doc(item.id), item.toMap());
      }
    }

    await batch.commit();
  }
}
