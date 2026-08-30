/// How the customer settles up with the driver.
///
/// Both options are *on delivery* — SwiftDrop takes no money in-app, and there
/// is no gateway. That's the honest shape of the feature rather than a
/// limitation to paper over: card-on-delivery (the driver carries a POS
/// terminal) is standard in Tunis, so "Card" can be offered truthfully without
/// pretending to charge anyone. Checkout used to let a user pick Card and then
/// silently record the order as cash.
enum PaymentMethod {
  cash,
  card;

  String get wire => name;

  static PaymentMethod fromWire(String? value) =>
      value == 'card' ? PaymentMethod.card : PaymentMethod.cash;

  // Display copy lives in the PaymentMethodCopy l10n extension
  // (core/l10n/l10n.dart) so this model stays pure and translatable.
}
