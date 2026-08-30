import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/neighborhood.dart';

/// Reads Passport neighborhoods from /neighborhoods (seeded once).
class NeighborhoodRepository {
  NeighborhoodRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<PassportNeighborhood>> watchNeighborhoods() => _db
      .collection('neighborhoods')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => PassportNeighborhood.fromMap(d.data()))
          .toList());

  Future<List<PassportNeighborhood>> fetchNeighborhoods() async {
    final snap = await _db.collection('neighborhoods').get();
    return snap.docs
        .map((d) => PassportNeighborhood.fromMap(d.data()))
        .toList();
  }
}
