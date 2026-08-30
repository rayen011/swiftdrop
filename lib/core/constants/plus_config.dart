import '../models/plus_plan.dart';

/// SwiftDrop Plus — the subscription tier and what it unlocks.
///
/// Sits beside [EcoConfig] / [DemoTimings] as app-level tunables rather than
/// Firestore data: pricing is compiled in, exactly like the demo timings, and a
/// real build would source it from the store's product catalog instead.
abstract final class PlusConfig {
  // Weekly is the anchor price everything else is discounted against, and the
  // only plan carrying a trial — it's the low-commitment entry point.
  static const PlusPlan weekly = PlusPlan(
    id: PlusPlanId.weekly,
    priceTND: 6.99,
    period: Duration(days: 7),
    trial: Duration(days: 3),
  );

  static const PlusPlan monthly = PlusPlan(
    id: PlusPlanId.monthly,
    priceTND: 19.99,
    period: Duration(days: 30),
  );

  static const PlusPlan yearly = PlusPlan(
    id: PlusPlanId.yearly,
    priceTND: 89.99,
    period: Duration(days: 365),
  );

  /// Display order — the trial plan sits in the middle where it reads first.
  static const List<PlusPlan> plans = [monthly, weekly, yearly];

  /// Preselected on the paywall: the trial is the cheapest way in.
  static const PlusPlan defaultPlan = weekly;

  /// The plan all savings percentages are quoted against.
  static const PlusPlan anchor = weekly;

  static PlusPlan? byId(PlusPlanId? id) {
    for (final plan in plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  // The perk list (what a subscription unlocks) is built localized by
  // plusPerks() in core/l10n/l10n.dart.
}

class PlusPerk {
  const PlusPerk({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}
