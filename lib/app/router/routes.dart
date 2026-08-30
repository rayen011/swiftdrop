/// Centralized route paths. Group-order share codes will deep-link here later
/// (e.g. /group/:shareCode), which is why go_router is the navigator.
abstract final class Routes {
  static const String splash = '/splash';

  // Auth
  static const String phoneAuth = '/auth/phone';
  static const String otp = '/auth/otp';
  static const String addressSetup = '/auth/address';

  // Bottom-nav branches
  static const String home = '/home';
  static const String eco = '/eco';
  static const String passport = '/passport';
  static const String profile = '/profile';

  // Order flow (pushed on top of the shell)
  static const String restaurant = '/restaurant'; // /restaurant/:id
  static const String groceryProduct =
      '/grocery-product'; // extra: GroceryProductArgs
  static const String pharmacyProduct =
      '/pharmacy-product'; // extra: PharmacyProductArgs
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String tracking = '/tracking'; // /tracking/:orderId

  // Search (extra: StoreVertical)
  static const String search = '/search';

  // SwiftDrop Plus paywall
  static const String plus = '/plus';

  // Profile area
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail'; // extra: AppOrder

  // Group order
  static const String groupStart = '/group-start'; // pick restaurant
  static const String groupJoin = '/group-join'; // enter share code
  static const String groupLobby = '/group'; // /group/:id (extra: GroupOrder)
  static const String groupMenu = '/group-menu'; // extra: GroupMenuArgs
  static const String groupCheckout = '/group-checkout'; // extra: GroupOrder
}
