import 'package:equatable/equatable.dart';

import '../../../core/models/app_user.dart';

enum AuthStatus {
  unknown, // checking persisted session
  unauthenticated, // no user — show phone entry
  codeSending, // verifyPhoneNumber in flight
  codeSent, // OTP dispatched — show code entry
  verifying, // signing in with the code
  needsOnboarding, // signed in but no name/address yet
  authenticated, // fully set up
  error,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.phone = '',
    this.verificationId,
    this.error,
  });

  final AuthStatus status;
  final AppUser? user;
  final String phone;
  final String? verificationId;
  final String? error;

  bool get isBusy =>
      status == AuthStatus.codeSending || status == AuthStatus.verifying;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? phone,
    String? verificationId,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        phone: phone ?? this.phone,
        verificationId: verificationId ?? this.verificationId,
        error: error,
      );

  @override
  List<Object?> get props => [status, user, phone, verificationId, error];
}
