// App-level tunables that come straight from the locked SPEC.md decisions.
// Keeping them in one place makes the mock simulation and eco math easy to tweak.

/// Demo-paced timings for the mock driver simulation (resolves SPEC §1).
/// Order status auto-advances on these offsets from order placement.
abstract final class DemoTimings {
  static const Duration toPreparing = Duration(seconds: 8);
  static const Duration toPickedUp = Duration(seconds: 16);
  static const Duration toOnTheWay = Duration(seconds: 24);
  static const Duration toDelivered = Duration(seconds: 40);

  /// Window over which the driver pin interpolates restaurant -> address.
  static const Duration enRouteWindow = Duration(seconds: 16); // 24s -> 40s
}

/// Eco Bundle Mode constants (resolves SPEC §3). Pure UX, no real batching.
abstract final class EcoConfig {
  /// Flat discount applied when the Eco toggle is on.
  static const double discountTND = 1.5;

  /// Simulated number of nearby orders bundled (inclusive range).
  static const int minBundleSize = 2;
  static const int maxBundleSize = 3;

  /// CO₂ saved per eco order = gramsPerOrder * bundleSize -> 140–210 g.
  static const double co2GramsPerBundledOrder = 70;
}

/// Passport rules (resolves SPEC §4).
abstract final class PassportConfig {
  /// Default orders needed in a neighborhood to unlock its deal.
  static const int defaultRequiredStamps = 3;
}
