import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/group_order.dart';
import '../../core/models/order.dart';
import '../../core/models/restaurant.dart';
import '../../core/models/store_vertical.dart';
import '../../features/group/presentation/group_checkout_screen.dart';
import '../../features/group/presentation/group_join_screen.dart';
import '../../features/group/presentation/group_lobby_screen.dart';
import '../../features/group/presentation/group_menu_screen.dart';
import '../../features/group/presentation/group_start_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/presentation/order_history_screen.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/auth_state.dart';
import '../../features/auth/presentation/address_setup_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/phone_auth_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/eco/presentation/eco_screen.dart';
import '../../features/grocery/presentation/grocery_product_screen.dart';
import '../../features/grocery/presentation/grocery_store_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/pharmacy/presentation/pharmacy_product_screen.dart';
import '../../features/pharmacy/presentation/pharmacy_store_screen.dart';
import '../../features/menu/presentation/restaurant_menu_screen.dart';
import '../../features/passport/presentation/passport_screen.dart';
import '../../features/plus/presentation/paywall_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/tracking/presentation/tracking_screen.dart';
import 'go_router_refresh_stream.dart';
import 'routes.dart';

/// Builds the app router with auth-driven redirects. [authCubit] is captured for
/// both the redirect guard and the refresh listenable.
GoRouter createRouter(AuthCubit authCubit) {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: Routes.splash,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final status = authCubit.state.status;
      final loc = state.matchedLocation;
      final inAuthArea = loc == Routes.splash || loc.startsWith('/auth');

      switch (status) {
        case AuthStatus.unknown:
          return inAuthArea ? null : Routes.splash;
        case AuthStatus.unauthenticated:
        case AuthStatus.codeSending:
        case AuthStatus.error:
          return loc == Routes.phoneAuth ? null : Routes.phoneAuth;
        case AuthStatus.codeSent:
        case AuthStatus.verifying:
          return loc == Routes.otp ? null : Routes.otp;
        case AuthStatus.needsOnboarding:
          return loc == Routes.addressSetup ? null : Routes.addressSetup;
        case AuthStatus.authenticated:
          return inAuthArea ? Routes.home : null;
      }
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.phoneAuth,
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(path: Routes.otp, builder: (context, state) => const OtpScreen()),
      GoRoute(
        path: Routes.addressSetup,
        builder: (context, state) => const AddressSetupScreen(),
      ),

      // Order flow — full-screen over the shell (root navigator).
      GoRoute(
        path: '${Routes.restaurant}/:id',
        builder: (context, state) {
          final restaurant = state.extra as Restaurant;
          // Each vertical gets its own storefront. Grocery uses the ShopMate
          // product grid; the rest fall back to the menu-list screen.
          return switch (restaurant.category) {
            'grocery' => GroceryStoreScreen(restaurant: restaurant),
            'pharmacy' => PharmacyStoreScreen(restaurant: restaurant),
            _ => RestaurantMenuScreen(restaurant: restaurant),
          };
        },
      ),
      GoRoute(
        path: Routes.groceryProduct,
        builder: (context, state) =>
            GroceryProductScreen(args: state.extra as GroceryProductArgs),
      ),
      GoRoute(
        path: Routes.pharmacyProduct,
        builder: (context, state) =>
            PharmacyProductScreen(args: state.extra as PharmacyProductArgs),
      ),
      GoRoute(
        path: Routes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: Routes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '${Routes.tracking}/:orderId',
        builder: (context, state) {
          final order = state.extra as AppOrder;
          return TrackingScreen(order: order);
        },
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) =>
            SearchScreen(vertical: state.extra as StoreVertical),
      ),
      GoRoute(
        path: Routes.plus,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: Routes.orderHistory,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: Routes.orderDetail,
        builder: (context, state) {
          final order = state.extra as AppOrder;
          return OrderDetailScreen(order: order);
        },
      ),

      // Group order flow.
      GoRoute(
        path: Routes.groupStart,
        builder: (context, state) => const GroupStartScreen(),
      ),
      GoRoute(
        path: Routes.groupJoin,
        builder: (context, state) => const GroupJoinScreen(),
      ),
      GoRoute(
        path: '${Routes.groupLobby}/:id',
        builder: (context, state) => GroupLobbyScreen(
          groupId: state.pathParameters['id']!,
          initial: state.extra as GroupOrder?,
        ),
      ),
      GoRoute(
        path: Routes.groupMenu,
        builder: (context, state) =>
            GroupMenuScreen(args: state.extra as GroupMenuArgs),
      ),
      GoRoute(
        path: Routes.groupCheckout,
        builder: (context, state) =>
            GroupCheckoutScreen(group: state.extra as GroupOrder),
      ),

      // Bottom-nav shell.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.eco,
                builder: (context, state) => const EcoScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.passport,
                builder: (context, state) => const PassportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
