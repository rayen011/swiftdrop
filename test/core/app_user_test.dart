import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/app_user.dart';

/// Reads the `hasOnly` field allowlist out of `validProfile` in firestore.rules.
Set<String> _validProfileAllowlist() {
  final rules = File('firestore.rules').readAsStringSync();
  final fn = rules.indexOf('function validProfile');
  expect(fn, isNot(-1), reason: 'validProfile() vanished from firestore.rules');

  final call = rules.indexOf('hasOnly', fn);
  final open = rules.indexOf('[', call);
  final close = rules.indexOf(']', open);
  return RegExp(r"'([^']+)'")
      .allMatches(rules.substring(open, close))
      .map((m) => m.group(1)!)
      .toSet();
}

void main() {
  group('AppUser', () {
    test('themeMode survives a Firestore round trip', () {
      // createdAt must be set: toMap() emits a serverTimestamp() sentinel when
      // it is null, and that sentinel is not readable back by fromMap.
      final user = AppUser(
        uid: 'u1',
        phone: '+21611111111',
        name: 'rayen',
        locale: 'fr',
        themeMode: 'dark',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final back = AppUser.fromMap(user.toMap());
      expect(back.themeMode, 'dark');
      expect(back.locale, 'fr');
    });

    test('themeMode defaults to following the system', () {
      expect(const AppUser(uid: 'u', phone: 'p').themeMode, isEmpty);
      // A profile written before the field existed reads back as "system"
      // rather than throwing.
      expect(AppUser.fromMap(const {'uid': 'u', 'phone': 'p'}).themeMode,
          isEmpty);
    });

    test('copyWith carries themeMode and leaves it alone when omitted', () {
      const user = AppUser(uid: 'u', phone: 'p', themeMode: 'light');
      expect(user.copyWith(name: 'x').themeMode, 'light');
      expect(user.copyWith(themeMode: 'dark').themeMode, 'dark');
    });

    test('themeMode participates in equality', () {
      const a = AppUser(uid: 'u', phone: 'p', themeMode: 'light');
      const b = AppUser(uid: 'u', phone: 'p', themeMode: 'dark');
      // AuthCubit emits a copyWith'd user to flip the theme; if themeMode were
      // missing from props the state would compare equal and never rebuild.
      expect(a, isNot(equals(b)));
    });
  });

  // The README's warning made executable: /users is pinned to an exact field
  // list by `hasOnly`, so a key in toMap() that rules don't list fails the
  // write at runtime as an opaque permission-denied, with nothing at compile
  // time to catch it.
  test('every key AppUser writes is allowed by firestore.rules', () {
    const user = AppUser(uid: 'u', phone: 'p');
    final written = user.toMap().keys.toSet();
    final allowed = _validProfileAllowlist();

    expect(
      written.difference(allowed),
      isEmpty,
      reason: 'AppUser.toMap() writes keys that validProfile() rejects — '
          'add them to the hasOnly list in firestore.rules',
    );
  });

  test('the rules allowlist has no field the model never writes', () {
    const user = AppUser(uid: 'u', phone: 'p');
    final written = user.toMap().keys.toSet();
    final allowed = _validProfileAllowlist();

    expect(
      allowed.difference(written),
      isEmpty,
      reason: 'firestore.rules permits fields AppUser no longer writes — '
          'a stale allowlist entry is a hole in the client-write surface',
    );
  });
}
