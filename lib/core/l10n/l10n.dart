import 'package:flutter/widgets.dart';

import '../../l10n/gen/app_localizations.dart';
import '../constants/plus_config.dart';
import '../models/payment_method.dart';
import '../models/plus_plan.dart';
import '../models/store_vertical.dart';
import '../utils/promo.dart';

export '../../l10n/gen/app_localizations.dart';

/// Shorthand: `context.l10n.viewCart` instead of `AppLocalizations.of(context)`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Localized copy for a [StoreVertical]. Lives in the widget layer so the model
/// stays pure Dart; the mapping is exhaustive, so adding a vertical without its
/// strings is a compile error here rather than a blank label at runtime.
extension StoreVerticalCopy on StoreVertical {
  String label(AppLocalizations l10n) => switch (this) {
        StoreVertical.fastFood => l10n.verticalFastFood,
        StoreVertical.groceries => l10n.verticalGroceries,
        StoreVertical.pharmacy => l10n.verticalPharmacy,
        StoreVertical.coffee => l10n.verticalCoffee,
      };

  String tagline(AppLocalizations l10n) => switch (this) {
        StoreVertical.fastFood => l10n.taglineFastFood,
        StoreVertical.groceries => l10n.taglineGroceries,
        StoreVertical.pharmacy => l10n.taglinePharmacy,
        StoreVertical.coffee => l10n.taglineCoffee,
      };

  String listHeading(AppLocalizations l10n) => switch (this) {
        StoreVertical.fastFood => l10n.headingFastFood,
        StoreVertical.groceries => l10n.headingGroceries,
        StoreVertical.pharmacy => l10n.headingPharmacy,
        StoreVertical.coffee => l10n.headingCoffee,
      };

  String searchHint(AppLocalizations l10n) => switch (this) {
        StoreVertical.fastFood => l10n.searchHintFastFood,
        StoreVertical.groceries => l10n.searchHintGroceries,
        StoreVertical.pharmacy => l10n.searchHintPharmacy,
        StoreVertical.coffee => l10n.searchHintCoffee,
      };

  String emptyLabel(AppLocalizations l10n) => switch (this) {
        StoreVertical.fastFood => l10n.emptyFastFood,
        StoreVertical.groceries => l10n.emptyGroceries,
        StoreVertical.pharmacy => l10n.emptyPharmacy,
        StoreVertical.coffee => l10n.emptyCoffee,
      };
}

/// Localized copy for [PaymentMethod] (the model stays pure Dart).
extension PaymentMethodCopy on PaymentMethod {
  String label(AppLocalizations l10n) => switch (this) {
        PaymentMethod.cash => l10n.payCash,
        PaymentMethod.card => l10n.payCard,
      };

  String hint(AppLocalizations l10n) => switch (this) {
        PaymentMethod.cash => l10n.payCashHint,
        PaymentMethod.card => l10n.payCardHint,
      };
}

/// Localized copy for a [PlusPlan].
extension PlusPlanCopy on PlusPlan {
  String label(AppLocalizations l10n) => switch (id) {
        PlusPlanId.weekly => l10n.planWeekly,
        PlusPlanId.monthly => l10n.planMonthly,
        PlusPlanId.yearly => l10n.planYearly,
      };

  /// Merchandising badge above the tile: trial wins, then the fixed labels.
  /// Null means no badge.
  String? badgeText(AppLocalizations l10n) {
    if (hasTrial) return l10n.trialBadge(trial.inDays);
    return switch (id) {
      PlusPlanId.monthly => l10n.popularBadge,
      PlusPlanId.yearly => l10n.bestDealBadge,
      PlusPlanId.weekly => null,
    };
  }
}

/// The paywall's perk list, built localized.
List<PlusPerk> plusPerks(AppLocalizations l10n) => [
      PlusPerk(
          title: l10n.perkDeliveryTitle, subtitle: l10n.perkDeliverySubtitle),
      PlusPerk(title: l10n.perkEcoTitle, subtitle: l10n.perkEcoSubtitle),
      PlusPerk(title: l10n.perkGroupTitle, subtitle: l10n.perkGroupSubtitle),
    ];

/// User-facing copy for a promo refusal. Lives here rather than in promo.dart
/// so the resolver stays pure Dart and every reason is guaranteed a string in
/// every language.
String promoRejectionMessage(AppLocalizations l10n, PromoRejected rejection) =>
    switch (rejection.reason) {
      PromoRejection.unknown => l10n.promoUnknown,
      PromoRejection.notEarned =>
        l10n.promoNotEarned(rejection.zone?.name ?? ''),
      PromoRejection.exhausted => l10n.promoExhausted,
      PromoRejection.noValue => l10n.promoNoValue,
    };
