import '../models/neighborhood.dart';
import '../models/user_stats.dart';

/// Why a promo code was refused. Each maps to copy the user can act on — a bare
/// "invalid code" is the most annoying possible answer when the real reason is
/// "you need one more order in Carthage".
enum PromoRejection {
  /// No neighborhood carries this code.
  unknown,

  /// The code exists but its stamps aren't collected yet.
  notEarned,

  /// The deal's maxRedemptions is used up.
  exhausted,

  /// The deal applies but is worth nothing here — e.g. free delivery on an
  /// order whose delivery is already free with Plus.
  noValue,
}

/// Outcome of applying a code to a cart.
sealed class PromoOutcome {
  const PromoOutcome();
}

class PromoAccepted extends PromoOutcome {
  const PromoAccepted({
    required this.zone,
    required this.discountTND,
  });

  final PassportNeighborhood zone;
  final double discountTND;
}

class PromoRejected extends PromoOutcome {
  const PromoRejected(this.reason, {this.zone});

  final PromoRejection reason;

  /// Set when the code was recognised, so the UI can name the zone.
  final PassportNeighborhood? zone;
}

/// Resolves a typed promo code against what the user has actually earned.
///
/// Pure on purpose: this decides how much money comes off an order, and it is
/// the only place that decision is made. It's also the *only* enforcement of a
/// deal's redemption cap — firestore.rules can bound the discount but cannot
/// count a user's past redemptions, because stamps and redemptions are both
/// derived by folding orders and rules cannot fold a list.
PromoOutcome resolvePromo({
  required String code,
  required List<PassportNeighborhood> zones,
  required UserStats stats,
  required double subtotal,
  required double deliveryFee,
}) {
  final normalized = code.trim().toUpperCase();

  PassportNeighborhood? match;
  for (final zone in zones) {
    if (zone.deal.code.toUpperCase() == normalized) {
      match = zone;
      break;
    }
  }
  if (match == null) return const PromoRejected(PromoRejection.unknown);

  final deal = match.deal;

  if (stats.stampsIn(match.id) < match.requiredStamps) {
    return PromoRejected(PromoRejection.notEarned, zone: match);
  }

  if (!deal.isUnlimited &&
      stats.redemptionsOf(deal.code) >= deal.maxRedemptions) {
    return PromoRejected(PromoRejection.exhausted, zone: match);
  }

  final discount =
      deal.discountFor(subtotal: subtotal, deliveryFee: deliveryFee);
  if (discount <= 0) {
    return PromoRejected(PromoRejection.noValue, zone: match);
  }

  return PromoAccepted(zone: match, discountTND: discount);
}

// User-facing refusal copy lives in promoRejectionMessage (core/l10n/l10n.dart)
// so this resolver stays pure Dart and the messages are translated.
