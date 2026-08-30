// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navEco => 'Eco';

  @override
  String get navPassport => 'Passport';

  @override
  String get navProfile => 'Profile';

  @override
  String get verticalFastFood => 'Fast Food';

  @override
  String get verticalGroceries => 'Groceries';

  @override
  String get verticalPharmacy => 'Pharmacy';

  @override
  String get verticalCoffee => 'Coffee & Drinks';

  @override
  String get taglineFastFood => 'Burgers, pizza, tacos & more';

  @override
  String get taglineGroceries => 'Fresh produce & daily essentials';

  @override
  String get taglinePharmacy => 'Medicine & care, delivered';

  @override
  String get taglineCoffee => 'Coffee, juice & pastries';

  @override
  String get headingFastFood => 'Fast food near you';

  @override
  String get headingGroceries => 'Grocery stores near you';

  @override
  String get headingPharmacy => 'Pharmacies near you';

  @override
  String get headingCoffee => 'Cafés near you';

  @override
  String get searchHintFastFood => 'Search for food';

  @override
  String get searchHintGroceries => 'Search for groceries';

  @override
  String get searchHintPharmacy => 'Search for medicine';

  @override
  String get searchHintCoffee => 'Search for drinks';

  @override
  String get emptyFastFood => 'No restaurants here yet';

  @override
  String get emptyGroceries => 'No grocery stores here yet';

  @override
  String get emptyPharmacy => 'No pharmacies here yet';

  @override
  String get emptyCoffee => 'No cafés here yet';

  @override
  String get shoppingFor => 'Shopping for';

  @override
  String get chooseStoreType => 'Choose a store type';

  @override
  String get storeTypeSubtitle => 'Each one has its own selection.';

  @override
  String get deliverTo => 'Deliver to';

  @override
  String greeting(String name) {
    return 'Hi, $name 👋';
  }

  @override
  String get greetingFallbackName => 'there';

  @override
  String get orderAgain => 'Order again';

  @override
  String get reorder => 'Reorder';

  @override
  String itemsSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0 · $total TND';
  }

  @override
  String get groupBannerTag => 'Order together';

  @override
  String get groupBannerTitle => 'Start a group order';

  @override
  String get groupBannerSubtitle => 'Share a cart, split one delivery fee';

  @override
  String get startNow => 'Start now';

  @override
  String get viewCart => 'View cart';

  @override
  String searchNoResults(String query) {
    return 'No results for “$query”';
  }

  @override
  String get searchTryDifferent => 'Try a different name or type of item.';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSystem => 'Follow system';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get cartTitle => 'Your cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get ecoBundle => 'Eco Bundle';

  @override
  String get ecoLocked => 'Unlock with Plus to bundle and cut CO₂';

  @override
  String get ecoIdle => 'Bundle nearby orders, save on delivery';

  @override
  String ecoActive(int count, String grams) {
    return 'Bundled with $count nearby orders · saves ${grams}g CO₂';
  }

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get deliveryFeePlus => 'Delivery fee (Plus)';

  @override
  String get ecoDiscount => 'Eco discount';

  @override
  String get total => 'Total';

  @override
  String get freeLabel => 'FREE';

  @override
  String goToCheckout(String total) {
    return 'Go to checkout · $total TND';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get noAddress => 'No address set';

  @override
  String get payment => 'Payment';

  @override
  String get payCash => 'Cash on delivery';

  @override
  String get payCashHint => 'Pay the driver in cash';

  @override
  String get payCard => 'Card on delivery';

  @override
  String get payCardHint => 'The driver brings a card terminal';

  @override
  String get passportDeal => 'Passport deal';

  @override
  String get orderSummary => 'Order summary';

  @override
  String placeOrder(String total) {
    return 'Place order · $total TND';
  }

  @override
  String orderFailed(String error) {
    return 'Could not place order: $error';
  }

  @override
  String get promoHint => 'Passport deal code';

  @override
  String get apply => 'Apply';

  @override
  String get removeDeal => 'Remove deal';

  @override
  String get promoCheckFailed => 'Could not check that code. Try again.';

  @override
  String get promoUnknown => 'That code doesn\'t exist.';

  @override
  String promoNotEarned(String zone) {
    return 'Not unlocked yet — collect your $zone stamps first.';
  }

  @override
  String get promoExhausted => 'You have already used this deal.';

  @override
  String get promoNoValue => 'Nothing to discount — delivery is already free.';

  @override
  String get freshItems => 'Fresh items';

  @override
  String get noFilterMatches => 'Nothing matches those filters';

  @override
  String cartItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortRecommended => 'Recommended';

  @override
  String get sortPriceAsc => 'Price: low to high';

  @override
  String get sortPriceDesc => 'Price: high to low';

  @override
  String get priceAscShort => 'Price ↑';

  @override
  String get priceDescShort => 'Price ↓';

  @override
  String get categoryLabel => 'Category';

  @override
  String get allCategories => 'All categories';

  @override
  String get offers => 'Offers';

  @override
  String get aboutProduct => 'About this product';

  @override
  String get whyYoullLoveIt => 'Why you\'ll love it';

  @override
  String get addToCart => 'Add to cart';

  @override
  String mrp(String price) {
    return 'MRP $price';
  }

  @override
  String addedToCart(int count, String name) {
    return 'Added $count × $name to cart';
  }

  @override
  String minsChip(int minutes) {
    return '$minutes MINS';
  }

  @override
  String minFeeDelivery(int minutes, String fee) {
    return '$minutes min · $fee TND delivery';
  }

  @override
  String deliveredToDoor(int minutes) {
    return '$minutes min · delivered to your door';
  }

  @override
  String get recommendation => 'Recommendation';

  @override
  String get noItemsYet => 'No items yet';

  @override
  String get noMatchesTryPhoto => 'No matches — try the photo request above';

  @override
  String get cantFindMedicine => 'Can\'t find your medicine?';

  @override
  String get requestBannerSubtitle =>
      'Send us a photo and a pharmacist will source it';

  @override
  String get cantFindNeed => 'Can\'t find what you need?';

  @override
  String get requestTileSubtitle => 'Send a photo and we\'ll source it';

  @override
  String get description => 'Description';

  @override
  String get requestSheetBody =>
      'Send a photo of the item or your prescription and a pharmacist will source it for you.';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get noteHint => 'Dosage, brand, quantity…';

  @override
  String get sendRequest => 'Send request';

  @override
  String get attachToContinue => 'Attach a photo to continue';

  @override
  String get demoNoUpload => 'Demo — no photo is uploaded or stored';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get addPhotoSubtitle => 'Prescription or a picture of the item';

  @override
  String get photoAttached => 'Photo attached · tap to remove';

  @override
  String get requestSent =>
      'Request sent — a pharmacist will confirm availability.';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get orderHistory => 'Order history';

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesSubtitle => 'Tap one to open its store.';

  @override
  String get favoritesEmpty => 'Nothing hearted yet — tap ♡ on any product.';

  @override
  String get removeLabel => 'Remove';

  @override
  String get savedAddresses => 'Saved addresses';

  @override
  String get logOut => 'Log out';

  @override
  String get statOrders => 'Orders';

  @override
  String get statCo2 => 'CO₂ saved';

  @override
  String get statStamps => 'Stamps';

  @override
  String get swiftdropUser => 'SwiftDrop user';

  @override
  String get plusActive => 'SwiftDrop Plus is active';

  @override
  String plusRenews(String plan, String date) {
    return '$plan · renews $date';
  }

  @override
  String get plusPitch => 'Free delivery, Eco Bundle and group hosting';

  @override
  String get planWeekly => 'Weekly';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planYearly => 'Yearly';

  @override
  String get popularBadge => 'POPULAR';

  @override
  String get bestDealBadge => 'BEST DEAL';

  @override
  String trialBadge(int days) {
    return '$days DAYS\nFREE TRIAL';
  }

  @override
  String percentOffBadge(int percent) {
    return '$percent% OFF';
  }

  @override
  String perWeek(String price) {
    return '$price/week';
  }

  @override
  String get restore => 'Restore';

  @override
  String get plusNoLimits => 'with no limits';

  @override
  String get perkDeliveryTitle => 'Free delivery, every order';

  @override
  String get perkDeliverySubtitle =>
      'No delivery fee at checkout — on any store.';

  @override
  String get perkEcoTitle => 'Eco Bundle Mode';

  @override
  String get perkEcoSubtitle =>
      'Bundle nearby orders, cut CO₂ and save on every drop.';

  @override
  String get perkGroupTitle => 'Host group orders';

  @override
  String get perkGroupSubtitle =>
      'Start a shared cart and split one fee. Joining stays free.';

  @override
  String tryTrial(int days) {
    return 'TRY $days-DAY FREE TRIAL';
  }

  @override
  String getPlus(String price) {
    return 'GET PLUS · $price TND';
  }

  @override
  String get trialStarted => 'Trial started — SwiftDrop Plus is active.';

  @override
  String get plusActivated => 'SwiftDrop Plus is active.';

  @override
  String plusFailed(String error) {
    return 'Could not start Plus: $error';
  }

  @override
  String renewalTrial(int days, String price, int period) {
    return 'Free for $days days, then $price TND every $period days. Cancel anytime.';
  }

  @override
  String renewalPlain(String price, int period) {
    return '$price TND every $period days. Cancel anytime.';
  }

  @override
  String get testPurchaseNote => 'Test purchase — no payment is taken';

  @override
  String get termsPrivacy => 'Terms of Service · Privacy Policy';
}
