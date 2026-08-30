// Verifies the live user-document subscription in AuthCubit: buying SwiftDrop
// Plus (which just writes plusUntil) must reach the session immediately — the
// cart's free-delivery mirror and the group-hosting gate both read this cubit.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/address.dart';
import 'package:swiftdrop/core/models/app_user.dart';
import 'package:swiftdrop/data/repositories/auth_repository.dart';
import 'package:swiftdrop/features/auth/cubit/auth_cubit.dart';
import 'package:swiftdrop/features/auth/cubit/auth_state.dart';

class _FakeFirebaseUser implements User {
  @override
  String get uid => 'u1';

  @override
  String? get phoneNumber => '+21655000000';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepo implements AuthRepository {
  final userDoc = StreamController<AppUser?>.broadcast();

  static final _onboarded = AppUser(
    uid: 'u1',
    phone: '+21655000000',
    name: 'Sami',
    savedAddresses: const [],
    defaultAddressId: 'a1',
  );

  @override
  User? get currentAuthUser => _FakeFirebaseUser();

  @override
  Future<AppUser> ensureUser({required String uid, required String phone}) async =>
      // Name set + an address makes isOnboarded true.
      _onboarded.copyWith(savedAddresses: [
        const Address(
            id: 'a1', label: 'Home', lat: 0, lng: 0, fullAddress: 'Tunis'),
      ]);

  @override
  Stream<AppUser?> watchUser(String uid) => userDoc.stream;

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a Plus purchase written to the user doc reaches the cubit live',
      () async {
    final repo = _FakeAuthRepo();
    final cubit = AuthCubit(repo);
    await Future<void>.delayed(Duration.zero); // let bootstrap finish

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user?.isPlus() ?? false, isFalse);

    // Simulate activatePlus: the document gains a future plusUntil.
    repo.userDoc.add(_FakeAuthRepo._onboarded.copyWith(
      savedAddresses: [
        const Address(
            id: 'a1', label: 'Home', lat: 0, lng: 0, fullAddress: 'Tunis'),
      ],
      plusPlanId: 'weekly',
      plusUntil: DateTime.now().add(const Duration(days: 10)),
    ));
    await Future<void>.delayed(Duration.zero);

    // No restart needed: the session sees the entitlement immediately.
    expect(cubit.state.user?.isPlus() ?? false, isTrue);
    expect(cubit.state.status, AuthStatus.authenticated);

    await cubit.close();
  });

  test('sign-out stops the subscription and clears state', () async {
    final repo = _FakeAuthRepo();
    final cubit = AuthCubit(repo);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.status, AuthStatus.authenticated);

    await cubit.signOut();
    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.user, isNull);

    // A late doc emit must not resurrect the signed-out session.
    repo.userDoc.add(_FakeAuthRepo._onboarded);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.user, isNull);
    expect(cubit.state.status, AuthStatus.unauthenticated);

    await cubit.close();
  });
}
