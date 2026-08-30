import 'package:equatable/equatable.dart';

/// Wire ids for the SwiftDrop Plus plans. Persisted on the user document, so
/// the names are part of the schema — don't rename without a migration.
enum PlusPlanId {
  weekly,
  monthly,
  yearly;

  String get wire => name;

  static PlusPlanId? fromWire(String? value) {
    for (final id in PlusPlanId.values) {
      if (id.name == value) return id;
    }
    return null;
  }
}

/// One purchasable SwiftDrop Plus plan.
///
/// Per-week price and the savings badge are *derived* from [priceTND] and
/// [period] rather than typed in, so the marketing copy can never drift out of
/// sync with what a plan actually charges.
class PlusPlan extends Equatable {
  const PlusPlan({
    required this.id,
    required this.priceTND,
    required this.period,
    this.trial = Duration.zero,
  });

  final PlusPlanId id;
  final double priceTND;

  /// How long one purchase entitles the user for (excluding [trial]).
  final Duration period;

  /// Free days granted before billing starts. Zero for most plans.
  final Duration trial;

  // Display copy (label, merchandising badge) lives in the PlusPlanCopy l10n
  // extension so it's translated.

  bool get hasTrial => trial > Duration.zero;

  /// Normalised price so plans of different lengths are comparable.
  double get pricePerWeekTND => priceTND * 7 / period.inDays;

  /// Total entitlement granted by one purchase, trial included.
  Duration get entitlement => trial + period;

  /// Percent saved against [reference] per week, or null when it isn't a
  /// meaningful saving. Drives the "75% OFF" flag on the tile.
  int? savingsPercentVersus(PlusPlan reference) {
    final saving =
        1 - (pricePerWeekTND / reference.pricePerWeekTND);
    final percent = (saving * 100).round();
    return percent >= 5 ? percent : null;
  }

  @override
  List<Object?> get props => [id, priceTND, period, trial];
}
