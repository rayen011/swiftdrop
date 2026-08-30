import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/app_user.dart';
import '../../core/models/favorite_item.dart';
import '../../core/models/plus_plan.dart';

/// Wraps Firebase phone-OTP auth and the /users profile document.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentAuthUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  /// Starts phone verification. On Android an SMS is sent (or auto-resolved).
  /// [codeSent] hands back the verificationId used to complete sign-in.
  Future<void> verifyPhone({
    required String phoneNumber,
    required void Function(String verificationId) codeSent,
    required void Function(FirebaseAuthException e) failed,
    void Function(UserCredential credential)? autoVerified,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        final result = await _auth.signInWithCredential(credential);
        autoVerified?.call(result);
      },
      verificationFailed: failed,
      codeSent: (verificationId, _) => codeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Completes sign-in with the SMS code the user typed.
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();

  // --- /users profile ---

  /// Reads the profile, creating a minimal one on first sign-in.
  Future<AppUser> ensureUser({required String uid, required String phone}) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) return AppUser.fromMap(doc.data()!);

    final user = AppUser(uid: uid, phone: phone, createdAt: DateTime.now());
    await _users.doc(uid).set(user.toMap());
    return user;
  }

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? AppUser.fromMap(doc.data()!) : null;
  }

  Stream<AppUser?> watchUser(String uid) => _users.doc(uid).snapshots().map(
        (doc) => doc.exists ? AppUser.fromMap(doc.data()!) : null,
      );

  Future<void> saveProfile(AppUser user) =>
      _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));

  /// Replaces the user's favorites list. Written wholesale rather than with
  /// arrayUnion/arrayRemove: removal by array operator needs an exact map
  /// match, which silently fails the moment any snapshot field differs.
  Future<void> saveFavorites(String uid, List<FavoriteItem> favorites) =>
      _users.doc(uid).set({
        'favorites': favorites.map((f) => f.toMap()).toList(),
      }, SetOptions(merge: true));

  // --- SwiftDrop Plus (TEST PURCHASE) ---

  /// Grants Plus for [plan]'s trial + period, starting now.
  ///
  /// !! TEST ONLY — THIS IS NOT A REAL PURCHASE !!
  /// No payment is taken and nothing verifies entitlement: the client simply
  /// writes its own expiry, so any user can grant themselves Plus for free.
  /// Shipping this for real means the store (App Store / Play) becomes the
  /// source of truth — its server-to-server webhook hits a Cloud Function that
  /// writes `plusUntil`, and firestore.rules drops these two fields back out of
  /// the client-writable allowlist. Until then, treat Plus as cosmetic.
  Future<void> activatePlus({
    required String uid,
    required PlusPlan plan,
    DateTime? from,
  }) {
    final start = from ?? DateTime.now();
    return _users.doc(uid).set({
      'plusPlanId': plan.id.wire,
      'plusUntil': Timestamp.fromDate(start.add(plan.entitlement)),
    }, SetOptions(merge: true));
  }

  /// Ends Plus immediately. Same test-only caveat as [activatePlus].
  Future<void> cancelPlus(String uid) => _users.doc(uid).set({
        'plusPlanId': '',
        'plusUntil': null,
      }, SetOptions(merge: true));

  // There is deliberately no applyOrderCompletion here. Order / CO₂ / stamp
  // totals used to be incremented from the client when the mock delivery timer
  // fired, which meant anyone could grant themselves stamps by calling it. They
  // are now derived from the user's own orders (see UserStats), so completing an
  // order writes nothing to /users at all.
}
