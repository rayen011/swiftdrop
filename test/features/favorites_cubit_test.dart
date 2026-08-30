import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/app_user.dart';
import 'package:swiftdrop/core/models/favorite_item.dart';
import 'package:swiftdrop/data/repositories/auth_repository.dart';
import 'package:swiftdrop/features/favorites/cubit/favorites_cubit.dart';

/// Fake: FavoritesCubit only uses watchUser + saveFavorites.
class _FakeAuthRepo implements AuthRepository {
  final controller = StreamController<AppUser?>.broadcast();
  final saved = <List<FavoriteItem>>[];

  @override
  Stream<AppUser?> watchUser(String uid) => controller.stream;

  @override
  Future<void> saveFavorites(String uid, List<FavoriteItem> favorites) async {
    saved.add(List.of(favorites));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _fav = FavoriteItem(
  itemId: 'mp_oranges',
  restaurantId: 'monoprix',
  restaurantName: 'Monoprix Express',
  name: 'Sweet Oranges',
  priceTND: 3.0,
);

AppUser _user({List<FavoriteItem> favorites = const []}) => AppUser(
      uid: 'u1',
      phone: '+21600000000',
      favorites: favorites,
    );

void main() {
  test('bind mirrors the user document', () async {
    final repo = _FakeAuthRepo();
    final cubit = FavoritesCubit(repo)..bind('u1');

    repo.controller.add(_user(favorites: const [_fav]));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.contains('mp_oranges'), isTrue);
    expect(cubit.state.count, 1);
    await cubit.close();
  });

  test('toggle adds optimistically and persists', () async {
    final repo = _FakeAuthRepo();
    final cubit = FavoritesCubit(repo)..bind('u1');

    await cubit.toggle(_fav);

    expect(cubit.state.contains('mp_oranges'), isTrue); // before any stream echo
    expect(repo.saved.single.single.itemId, 'mp_oranges');
    await cubit.close();
  });

  test('toggling again removes', () async {
    final repo = _FakeAuthRepo();
    final cubit = FavoritesCubit(repo)..bind('u1');

    await cubit.toggle(_fav);
    await cubit.toggle(_fav);

    expect(cubit.state.count, 0);
    expect(repo.saved.last, isEmpty);
    await cubit.close();
  });

  test('sign-out clears and stops writes', () async {
    final repo = _FakeAuthRepo();
    final cubit = FavoritesCubit(repo)..bind('u1');
    await cubit.toggle(_fav);

    cubit.bind(null);
    expect(cubit.state.count, 0);

    // A toggle with no user must not write to anyone's document.
    await cubit.toggle(_fav);
    expect(repo.saved.length, 1); // only the pre-sign-out write
    await cubit.close();
  });

  test('rebinding to another user swaps the stream', () async {
    final repo = _FakeAuthRepo();
    final cubit = FavoritesCubit(repo)..bind('u1');
    repo.controller.add(_user(favorites: const [_fav]));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.count, 1);

    cubit.bind('u2');
    // Cleared immediately: user2 must never glimpse user1's hearts.
    expect(cubit.state.count, 0);
    await cubit.close();
  });
}
