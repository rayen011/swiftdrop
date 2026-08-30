import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'address.dart';
import 'favorite_item.dart';
import 'plus_plan.dart';

/// SwiftDrop user profile. Stored at /users/{uid}. Named [AppUser] to avoid a
/// clash with firebase_auth's [User].
///
/// Profile data only. Order / CO₂ / stamp totals live in [UserStats], which is
/// projected from the user's orders rather than stored here — see that class for
/// why. firestore.rules pins /users to exactly the fields below, so adding a
/// counter here would be rejected by the backend.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.phone,
    this.name = '',
    this.savedAddresses = const [],
    this.defaultAddressId = '',
    this.plusPlanId = '',
    this.plusUntil,
    this.favorites = const [],
    this.locale = '',
    this.themeMode = '',
    this.createdAt,
  });

  final String uid;
  final String phone;
  final String name;
  final List<Address> savedAddresses;
  final String defaultAddressId;

  /// Wire id of the active SwiftDrop Plus plan ('' when never subscribed).
  final String plusPlanId;

  /// When Plus lapses. Null means the user has never subscribed.
  final DateTime? plusUntil;

  /// Hearted products (see [FavoriteItem]).
  final List<FavoriteItem> favorites;

  /// Preferred app language ('en', 'fr'; '' follows the device). Stored on the
  /// account so it travels across devices.
  final String locale;

  /// Preferred appearance: '' follows the system, 'light' and 'dark' pin it.
  /// Stored on the account for the same reason [locale] is — it travels with
  /// the user rather than being stranded on one device.
  final String themeMode;

  final DateTime? createdAt;

  bool get isOnboarded => name.isNotEmpty && savedAddresses.isNotEmpty;

  /// Whether SwiftDrop Plus is currently active.
  ///
  /// Derived from [plusUntil] rather than stored as a flag, for the same reason
  /// order status is derived from `placedAt`: an expiry needs no job to flip it
  /// off, so a subscription cannot get stuck "active" after it lapses.
  bool isPlus({DateTime? now}) {
    final until = plusUntil;
    return until != null && until.isAfter(now ?? DateTime.now());
  }

  /// The active plan, or null when Plus is inactive or lapsed.
  PlusPlanId? get activePlan =>
      isPlus() ? PlusPlanId.fromWire(plusPlanId) : null;

  Address? get defaultAddress {
    if (savedAddresses.isEmpty) return null;
    return savedAddresses.firstWhere(
      (a) => a.id == defaultAddressId,
      orElse: () => savedAddresses.first,
    );
  }

  /// Keys here must stay in lockstep with the `validProfile` allowlist in
  /// firestore.rules — an unlisted key fails the write.
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'phone': phone,
        'name': name,
        'savedAddresses': savedAddresses.map((a) => a.toMap()).toList(),
        'defaultAddressId': defaultAddressId,
        'plusPlanId': plusPlanId,
        'plusUntil': plusUntil != null ? Timestamp.fromDate(plusUntil!) : null,
        'favorites': favorites.map((f) => f.toMap()).toList(),
        'locale': locale,
        'themeMode': themeMode,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        name: map['name'] as String? ?? '',
        savedAddresses: (map['savedAddresses'] as List<dynamic>? ?? [])
            .map((e) => Address.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        defaultAddressId: map['defaultAddressId'] as String? ?? '',
        plusPlanId: map['plusPlanId'] as String? ?? '',
        plusUntil: (map['plusUntil'] as Timestamp?)?.toDate(),
        favorites: (map['favorites'] as List<dynamic>? ?? [])
            .map((e) =>
                FavoriteItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        locale: map['locale'] as String? ?? '',
        themeMode: map['themeMode'] as String? ?? '',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      );

  AppUser copyWith({
    String? name,
    List<Address>? savedAddresses,
    String? defaultAddressId,
    String? plusPlanId,
    DateTime? plusUntil,
    List<FavoriteItem>? favorites,
    String? locale,
    String? themeMode,
  }) =>
      AppUser(
        uid: uid,
        phone: phone,
        name: name ?? this.name,
        savedAddresses: savedAddresses ?? this.savedAddresses,
        defaultAddressId: defaultAddressId ?? this.defaultAddressId,
        plusPlanId: plusPlanId ?? this.plusPlanId,
        plusUntil: plusUntil ?? this.plusUntil,
        favorites: favorites ?? this.favorites,
        locale: locale ?? this.locale,
        themeMode: themeMode ?? this.themeMode,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        uid, phone, name, savedAddresses, defaultAddressId, plusPlanId,
        plusUntil, favorites, locale, themeMode,
      ];
}
