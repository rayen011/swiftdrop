import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navEco.
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get navEco;

  /// No description provided for @navPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get navPassport;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @verticalFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast Food'**
  String get verticalFastFood;

  /// No description provided for @verticalGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get verticalGroceries;

  /// No description provided for @verticalPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get verticalPharmacy;

  /// No description provided for @verticalCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee & Drinks'**
  String get verticalCoffee;

  /// No description provided for @taglineFastFood.
  ///
  /// In en, this message translates to:
  /// **'Burgers, pizza, tacos & more'**
  String get taglineFastFood;

  /// No description provided for @taglineGroceries.
  ///
  /// In en, this message translates to:
  /// **'Fresh produce & daily essentials'**
  String get taglineGroceries;

  /// No description provided for @taglinePharmacy.
  ///
  /// In en, this message translates to:
  /// **'Medicine & care, delivered'**
  String get taglinePharmacy;

  /// No description provided for @taglineCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee, juice & pastries'**
  String get taglineCoffee;

  /// No description provided for @headingFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast food near you'**
  String get headingFastFood;

  /// No description provided for @headingGroceries.
  ///
  /// In en, this message translates to:
  /// **'Grocery stores near you'**
  String get headingGroceries;

  /// No description provided for @headingPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies near you'**
  String get headingPharmacy;

  /// No description provided for @headingCoffee.
  ///
  /// In en, this message translates to:
  /// **'Cafés near you'**
  String get headingCoffee;

  /// No description provided for @searchHintFastFood.
  ///
  /// In en, this message translates to:
  /// **'Search for food'**
  String get searchHintFastFood;

  /// No description provided for @searchHintGroceries.
  ///
  /// In en, this message translates to:
  /// **'Search for groceries'**
  String get searchHintGroceries;

  /// No description provided for @searchHintPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Search for medicine'**
  String get searchHintPharmacy;

  /// No description provided for @searchHintCoffee.
  ///
  /// In en, this message translates to:
  /// **'Search for drinks'**
  String get searchHintCoffee;

  /// No description provided for @emptyFastFood.
  ///
  /// In en, this message translates to:
  /// **'No restaurants here yet'**
  String get emptyFastFood;

  /// No description provided for @emptyGroceries.
  ///
  /// In en, this message translates to:
  /// **'No grocery stores here yet'**
  String get emptyGroceries;

  /// No description provided for @emptyPharmacy.
  ///
  /// In en, this message translates to:
  /// **'No pharmacies here yet'**
  String get emptyPharmacy;

  /// No description provided for @emptyCoffee.
  ///
  /// In en, this message translates to:
  /// **'No cafés here yet'**
  String get emptyCoffee;

  /// No description provided for @shoppingFor.
  ///
  /// In en, this message translates to:
  /// **'Shopping for'**
  String get shoppingFor;

  /// No description provided for @chooseStoreType.
  ///
  /// In en, this message translates to:
  /// **'Choose a store type'**
  String get chooseStoreType;

  /// No description provided for @storeTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each one has its own selection.'**
  String get storeTypeSubtitle;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name} 👋'**
  String greeting(String name);

  /// No description provided for @greetingFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get greetingFallbackName;

  /// No description provided for @orderAgain.
  ///
  /// In en, this message translates to:
  /// **'Order again'**
  String get orderAgain;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @itemsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}} · {total} TND'**
  String itemsSummary(int count, String total);

  /// No description provided for @groupBannerTag.
  ///
  /// In en, this message translates to:
  /// **'Order together'**
  String get groupBannerTag;

  /// No description provided for @groupBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a group order'**
  String get groupBannerTitle;

  /// No description provided for @groupBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a cart, split one delivery fee'**
  String get groupBannerSubtitle;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get startNow;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String searchNoResults(String query);

  /// No description provided for @searchTryDifferent.
  ///
  /// In en, this message translates to:
  /// **'Try a different name or type of item.'**
  String get searchTryDifferent;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @ecoBundle.
  ///
  /// In en, this message translates to:
  /// **'Eco Bundle'**
  String get ecoBundle;

  /// No description provided for @ecoLocked.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Plus to bundle and cut CO₂'**
  String get ecoLocked;

  /// No description provided for @ecoIdle.
  ///
  /// In en, this message translates to:
  /// **'Bundle nearby orders, save on delivery'**
  String get ecoIdle;

  /// No description provided for @ecoActive.
  ///
  /// In en, this message translates to:
  /// **'Bundled with {count} nearby orders · saves {grams}g CO₂'**
  String ecoActive(int count, String grams);

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @deliveryFeePlus.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee (Plus)'**
  String get deliveryFeePlus;

  /// No description provided for @ecoDiscount.
  ///
  /// In en, this message translates to:
  /// **'Eco discount'**
  String get ecoDiscount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @freeLabel.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get freeLabel;

  /// No description provided for @goToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Go to checkout · {total} TND'**
  String goToCheckout(String total);

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No address set'**
  String get noAddress;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @payCash.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get payCash;

  /// No description provided for @payCashHint.
  ///
  /// In en, this message translates to:
  /// **'Pay the driver in cash'**
  String get payCashHint;

  /// No description provided for @payCard.
  ///
  /// In en, this message translates to:
  /// **'Card on delivery'**
  String get payCard;

  /// No description provided for @payCardHint.
  ///
  /// In en, this message translates to:
  /// **'The driver brings a card terminal'**
  String get payCardHint;

  /// No description provided for @passportDeal.
  ///
  /// In en, this message translates to:
  /// **'Passport deal'**
  String get passportDeal;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order · {total} TND'**
  String placeOrder(String total);

  /// No description provided for @orderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not place order: {error}'**
  String orderFailed(String error);

  /// No description provided for @promoHint.
  ///
  /// In en, this message translates to:
  /// **'Passport deal code'**
  String get promoHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @removeDeal.
  ///
  /// In en, this message translates to:
  /// **'Remove deal'**
  String get removeDeal;

  /// No description provided for @promoCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check that code. Try again.'**
  String get promoCheckFailed;

  /// No description provided for @promoUnknown.
  ///
  /// In en, this message translates to:
  /// **'That code doesn\'t exist.'**
  String get promoUnknown;

  /// No description provided for @promoNotEarned.
  ///
  /// In en, this message translates to:
  /// **'Not unlocked yet — collect your {zone} stamps first.'**
  String promoNotEarned(String zone);

  /// No description provided for @promoExhausted.
  ///
  /// In en, this message translates to:
  /// **'You have already used this deal.'**
  String get promoExhausted;

  /// No description provided for @promoNoValue.
  ///
  /// In en, this message translates to:
  /// **'Nothing to discount — delivery is already free.'**
  String get promoNoValue;

  /// No description provided for @freshItems.
  ///
  /// In en, this message translates to:
  /// **'Fresh items'**
  String get freshItems;

  /// No description provided for @noFilterMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches those filters'**
  String get noFilterMatches;

  /// No description provided for @cartItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String cartItemCount(int count);

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @sortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceDesc;

  /// No description provided for @priceAscShort.
  ///
  /// In en, this message translates to:
  /// **'Price ↑'**
  String get priceAscShort;

  /// No description provided for @priceDescShort.
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
  String get priceDescShort;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @aboutProduct.
  ///
  /// In en, this message translates to:
  /// **'About this product'**
  String get aboutProduct;

  /// No description provided for @whyYoullLoveIt.
  ///
  /// In en, this message translates to:
  /// **'Why you\'ll love it'**
  String get whyYoullLoveIt;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @mrp.
  ///
  /// In en, this message translates to:
  /// **'MRP {price}'**
  String mrp(String price);

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added {count} × {name} to cart'**
  String addedToCart(int count, String name);

  /// No description provided for @minsChip.
  ///
  /// In en, this message translates to:
  /// **'{minutes} MINS'**
  String minsChip(int minutes);

  /// No description provided for @minFeeDelivery.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · {fee} TND delivery'**
  String minFeeDelivery(int minutes, String fee);

  /// No description provided for @deliveredToDoor.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · delivered to your door'**
  String deliveredToDoor(int minutes);

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @noMatchesTryPhoto.
  ///
  /// In en, this message translates to:
  /// **'No matches — try the photo request above'**
  String get noMatchesTryPhoto;

  /// No description provided for @cantFindMedicine.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find your medicine?'**
  String get cantFindMedicine;

  /// No description provided for @requestBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send us a photo and a pharmacist will source it'**
  String get requestBannerSubtitle;

  /// No description provided for @cantFindNeed.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find what you need?'**
  String get cantFindNeed;

  /// No description provided for @requestTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a photo and we\'ll source it'**
  String get requestTileSubtitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @requestSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Send a photo of the item or your prescription and a pharmacist will source it for you.'**
  String get requestSheetBody;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Dosage, brand, quantity…'**
  String get noteHint;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @attachToContinue.
  ///
  /// In en, this message translates to:
  /// **'Attach a photo to continue'**
  String get attachToContinue;

  /// No description provided for @demoNoUpload.
  ///
  /// In en, this message translates to:
  /// **'Demo — no photo is uploaded or stored'**
  String get demoNoUpload;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @addPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prescription or a picture of the item'**
  String get addPhotoSubtitle;

  /// No description provided for @photoAttached.
  ///
  /// In en, this message translates to:
  /// **'Photo attached · tap to remove'**
  String get photoAttached;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent — a pharmacist will confirm availability.'**
  String get requestSent;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orderHistory;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap one to open its store.'**
  String get favoritesSubtitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing hearted yet — tap ♡ on any product.'**
  String get favoritesEmpty;

  /// No description provided for @removeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLabel;

  /// No description provided for @savedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get savedAddresses;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @statOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get statOrders;

  /// No description provided for @statCo2.
  ///
  /// In en, this message translates to:
  /// **'CO₂ saved'**
  String get statCo2;

  /// No description provided for @statStamps.
  ///
  /// In en, this message translates to:
  /// **'Stamps'**
  String get statStamps;

  /// No description provided for @swiftdropUser.
  ///
  /// In en, this message translates to:
  /// **'SwiftDrop user'**
  String get swiftdropUser;

  /// No description provided for @plusActive.
  ///
  /// In en, this message translates to:
  /// **'SwiftDrop Plus is active'**
  String get plusActive;

  /// No description provided for @plusRenews.
  ///
  /// In en, this message translates to:
  /// **'{plan} · renews {date}'**
  String plusRenews(String plan, String date);

  /// No description provided for @plusPitch.
  ///
  /// In en, this message translates to:
  /// **'Free delivery, Eco Bundle and group hosting'**
  String get plusPitch;

  /// No description provided for @planWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get planWeekly;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @popularBadge.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popularBadge;

  /// No description provided for @bestDealBadge.
  ///
  /// In en, this message translates to:
  /// **'BEST DEAL'**
  String get bestDealBadge;

  /// No description provided for @trialBadge.
  ///
  /// In en, this message translates to:
  /// **'{days} DAYS\nFREE TRIAL'**
  String trialBadge(int days);

  /// No description provided for @percentOffBadge.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String percentOffBadge(int percent);

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'{price}/week'**
  String perWeek(String price);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @plusNoLimits.
  ///
  /// In en, this message translates to:
  /// **'with no limits'**
  String get plusNoLimits;

  /// No description provided for @perkDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Free delivery, every order'**
  String get perkDeliveryTitle;

  /// No description provided for @perkDeliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No delivery fee at checkout — on any store.'**
  String get perkDeliverySubtitle;

  /// No description provided for @perkEcoTitle.
  ///
  /// In en, this message translates to:
  /// **'Eco Bundle Mode'**
  String get perkEcoTitle;

  /// No description provided for @perkEcoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bundle nearby orders, cut CO₂ and save on every drop.'**
  String get perkEcoSubtitle;

  /// No description provided for @perkGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Host group orders'**
  String get perkGroupTitle;

  /// No description provided for @perkGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a shared cart and split one fee. Joining stays free.'**
  String get perkGroupSubtitle;

  /// No description provided for @tryTrial.
  ///
  /// In en, this message translates to:
  /// **'TRY {days}-DAY FREE TRIAL'**
  String tryTrial(int days);

  /// No description provided for @getPlus.
  ///
  /// In en, this message translates to:
  /// **'GET PLUS · {price} TND'**
  String getPlus(String price);

  /// No description provided for @trialStarted.
  ///
  /// In en, this message translates to:
  /// **'Trial started — SwiftDrop Plus is active.'**
  String get trialStarted;

  /// No description provided for @plusActivated.
  ///
  /// In en, this message translates to:
  /// **'SwiftDrop Plus is active.'**
  String get plusActivated;

  /// No description provided for @plusFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start Plus: {error}'**
  String plusFailed(String error);

  /// No description provided for @renewalTrial.
  ///
  /// In en, this message translates to:
  /// **'Free for {days} days, then {price} TND every {period} days. Cancel anytime.'**
  String renewalTrial(int days, String price, int period);

  /// No description provided for @renewalPlain.
  ///
  /// In en, this message translates to:
  /// **'{price} TND every {period} days. Cancel anytime.'**
  String renewalPlain(String price, int period);

  /// No description provided for @testPurchaseNote.
  ///
  /// In en, this message translates to:
  /// **'Test purchase — no payment is taken'**
  String get testPurchaseNote;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service · Privacy Policy'**
  String get termsPrivacy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
