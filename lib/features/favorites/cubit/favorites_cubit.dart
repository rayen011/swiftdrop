import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/favorite_item.dart';
import '../../../data/repositories/auth_repository.dart';

class FavoritesState extends Equatable {
  const FavoritesState({this.items = const []});

  final List<FavoriteItem> items;

  bool contains(String itemId) => items.any((f) => f.itemId == itemId);
  int get count => items.length;

  @override
  List<Object?> get props => [items];
}

/// The signed-in user's hearted products, kept live from their /users document
/// and written back through [AuthRepository.saveFavorites].
///
/// Bound to the auth lifecycle at the app root (see app.dart), same pattern as
/// the cart's Plus mirror: screens just read one cubit instead of each watching
/// the user document themselves.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repo) : super(const FavoritesState());

  final AuthRepository _repo;
  StreamSubscription<dynamic>? _sub;
  String? _uid;

  /// Points the cubit at [uid]'s favorites (null on sign-out clears them).
  void bind(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    _sub = null;
    // Always reset first: switching accounts must never show the previous
    // user's hearts while the new document loads.
    emit(const FavoritesState());
    if (uid == null) return;
    _sub = _repo.watchUser(uid).listen((user) {
      if (!isClosed) emit(FavoritesState(items: user?.favorites ?? const []));
    });
  }

  /// Adds or removes [item]. Emits optimistically so the heart flips at tap
  /// speed; the document stream re-emits the confirmed state afterwards.
  Future<void> toggle(FavoriteItem item) async {
    final uid = _uid;
    if (uid == null) return;

    final items = [...state.items];
    final index = items.indexWhere((f) => f.itemId == item.itemId);
    if (index >= 0) {
      items.removeAt(index);
    } else {
      items.add(item);
    }
    emit(FavoritesState(items: items));
    await _repo.saveFavorites(uid, items);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
