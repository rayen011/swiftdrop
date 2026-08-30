import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/auth_repository.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../features/auth/cubit/auth_state.dart';
import '../features/cart/cubit/cart_cubit.dart';
import '../features/favorites/cubit/favorites_cubit.dart';
import 'router/app_router.dart';

class SwiftDropApp extends StatefulWidget {
  const SwiftDropApp({super.key});

  @override
  State<SwiftDropApp> createState() => _SwiftDropAppState();
}

class _SwiftDropAppState extends State<SwiftDropApp> {
  late final AuthCubit _authCubit;
  late final CartCubit _cartCubit;
  late final FavoritesCubit _favoritesCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(sl<AuthRepository>());
    _cartCubit = CartCubit();
    _favoritesCubit = FavoritesCubit(sl<AuthRepository>())
      ..bind(_authCubit.state.user?.uid);
    _router = createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _cartCubit.close();
    _favoritesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _cartCubit),
        BlocProvider.value(value: _favoritesCubit),
      ],
      // Per-user state (Plus entitlement, favorites) is mirrored from auth in
      // this one place, so CartCubit / FavoritesCubit stay auth-agnostic and
      // react the moment the user signs in, out, or their entitlement changes.
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listenWhen: (prev, next) =>
                (prev.user?.isPlus() ?? false) !=
                (next.user?.isPlus() ?? false),
            listener: (context, state) =>
                _cartCubit.setPlusEntitlement(state.user?.isPlus() ?? false),
          ),
          BlocListener<AuthCubit, AuthState>(
            listenWhen: (prev, next) => prev.user?.uid != next.user?.uid,
            listener: (context, state) => _favoritesCubit.bind(state.user?.uid),
          ),
        ],
        // Rebuild on locale or appearance change so either switch applies
        // instantly rather than on next launch.
        child: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (prev, next) =>
              prev.user?.locale != next.user?.locale ||
              prev.user?.themeMode != next.user?.themeMode,
          builder: (context, auth) {
            final saved = auth.user?.locale ?? '';
            return MaterialApp.router(
              title: 'SwiftDrop',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: _themeMode(auth.user?.themeMode),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              // '' follows the device; anything else is the user's choice.
              locale: saved.isEmpty ? null : Locale(saved),
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }

  /// Maps the stored preference onto Flutter's [ThemeMode]. Anything
  /// unrecognised — including the empty default — follows the system.
  static ThemeMode _themeMode(String? stored) => switch (stored) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
