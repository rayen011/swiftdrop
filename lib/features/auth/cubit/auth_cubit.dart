import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/address.dart';
import '../../../core/models/app_user.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Drives the phone-OTP flow and resolves whether the user still needs onboarding.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState()) {
    _bootstrap();
  }

  final AuthRepository _repo;
  StreamSubscription<AppUser?>? _userSub;

  Future<void> _bootstrap() async {
    final authUser = _repo.currentAuthUser;
    if (authUser == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    await _loadProfile(authUser);
  }

  Future<void> _loadProfile(User authUser) async {
    final user = await _repo.ensureUser(
      uid: authUser.uid,
      phone: authUser.phoneNumber ?? state.phone,
    );
    emit(state.copyWith(
      status: user.isOnboarded
          ? AuthStatus.authenticated
          : AuthStatus.needsOnboarding,
      user: user,
    ));
    _watchProfile(user.uid);
  }

  /// Keeps the in-memory user in lockstep with the /users document.
  ///
  /// Without this, the state is a snapshot from sign-in: buying SwiftDrop Plus
  /// wrote `plusUntil` to Firestore but the cart's entitlement mirror and the
  /// group-hosting gate (both fed from this cubit) stayed stale until the app
  /// restarted. Streaming the document makes a purchase — or an expiry, or a
  /// change from another device — take effect immediately.
  void _watchProfile(String uid) {
    _userSub?.cancel();
    _userSub = _repo.watchUser(uid).listen((user) {
      if (isClosed || user == null) return;
      emit(state.copyWith(
        status: user.isOnboarded
            ? AuthStatus.authenticated
            : AuthStatus.needsOnboarding,
        user: user,
      ));
    });
  }

  /// Sends an OTP to [phone] (expects full E.164, e.g. +21655123456).
  Future<void> sendOtp(String phone) async {
    emit(state.copyWith(status: AuthStatus.codeSending, phone: phone));
    await _repo.verifyPhone(
      phoneNumber: phone,
      codeSent: (verificationId) => emit(state.copyWith(
        status: AuthStatus.codeSent,
        verificationId: verificationId,
      )),
      failed: (e) => emit(state.copyWith(
        status: AuthStatus.error,
        error: e.message ?? 'Verification failed',
      )),
      autoVerified: (credential) {
        final u = credential.user;
        if (u != null) _loadProfile(u);
      },
    );
  }

  /// Completes sign-in with the SMS [code].
  Future<void> verifyOtp(String code) async {
    final verificationId = state.verificationId;
    if (verificationId == null) return;
    emit(state.copyWith(status: AuthStatus.verifying));
    try {
      final credential = await _repo.signInWithOtp(
        verificationId: verificationId,
        smsCode: code,
      );
      final u = credential.user;
      if (u != null) {
        await _loadProfile(u);
      } else {
        emit(state.copyWith(status: AuthStatus.error, error: 'Sign-in failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.message ?? 'Invalid code',
      ));
    }
  }

  /// Saves name + first address and flips the user to authenticated.
  Future<void> completeOnboarding({
    required String name,
    required Address address,
  }) async {
    final current = state.user;
    if (current == null) return;
    final updated = current.copyWith(
      name: name,
      savedAddresses: [address],
      defaultAddressId: address.id,
    );
    await _repo.saveProfile(updated);
    emit(state.copyWith(status: AuthStatus.authenticated, user: updated));
  }

  /// Persists the preferred app language and re-emits so MaterialApp's locale
  /// (bound to this state in app.dart) switches immediately.
  Future<void> saveLocale(String locale) async {
    final current = state.user;
    if (current == null) return;
    final updated = current.copyWith(locale: locale);
    emit(state.copyWith(user: updated));
    await _repo.saveProfile(updated);
  }

  /// Persists the preferred appearance and re-emits so MaterialApp's themeMode
  /// (bound to this state in app.dart) switches immediately.
  Future<void> saveThemeMode(String mode) async {
    final current = state.user;
    if (current == null) return;
    final updated = current.copyWith(themeMode: mode);
    emit(state.copyWith(user: updated));
    await _repo.saveProfile(updated);
  }

  /// Lets the user step back from OTP entry to fix their number.
  void resetToPhone() => emit(
        state.copyWith(status: AuthStatus.unauthenticated, verificationId: null),
      );

  Future<void> signOut() async {
    await _userSub?.cancel();
    _userSub = null;
    await _repo.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}
