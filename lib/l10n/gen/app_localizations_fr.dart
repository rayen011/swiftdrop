// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navHome => 'Accueil';

  @override
  String get navEco => 'Éco';

  @override
  String get navPassport => 'Passeport';

  @override
  String get navProfile => 'Profil';

  @override
  String get verticalFastFood => 'Fast Food';

  @override
  String get verticalGroceries => 'Épicerie';

  @override
  String get verticalPharmacy => 'Pharmacie';

  @override
  String get verticalCoffee => 'Café & Boissons';

  @override
  String get taglineFastFood => 'Burgers, pizzas, tacos et plus';

  @override
  String get taglineGroceries => 'Produits frais et essentiels du quotidien';

  @override
  String get taglinePharmacy => 'Médicaments et soins, livrés';

  @override
  String get taglineCoffee => 'Café, jus et pâtisseries';

  @override
  String get headingFastFood => 'Fast food près de chez vous';

  @override
  String get headingGroceries => 'Épiceries près de chez vous';

  @override
  String get headingPharmacy => 'Pharmacies près de chez vous';

  @override
  String get headingCoffee => 'Cafés près de chez vous';

  @override
  String get searchHintFastFood => 'Rechercher à manger';

  @override
  String get searchHintGroceries => 'Rechercher des produits';

  @override
  String get searchHintPharmacy => 'Rechercher un médicament';

  @override
  String get searchHintCoffee => 'Rechercher des boissons';

  @override
  String get emptyFastFood => 'Pas encore de restaurants ici';

  @override
  String get emptyGroceries => 'Pas encore d\'épiceries ici';

  @override
  String get emptyPharmacy => 'Pas encore de pharmacies ici';

  @override
  String get emptyCoffee => 'Pas encore de cafés ici';

  @override
  String get shoppingFor => 'Vous cherchez';

  @override
  String get chooseStoreType => 'Choisir un type de magasin';

  @override
  String get storeTypeSubtitle => 'Chacun a sa propre sélection.';

  @override
  String get deliverTo => 'Livrer à';

  @override
  String greeting(String name) {
    return 'Salut, $name 👋';
  }

  @override
  String get greetingFallbackName => 'toi';

  @override
  String get orderAgain => 'Commander à nouveau';

  @override
  String get reorder => 'Recommander';

  @override
  String itemsSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0 · $total TND';
  }

  @override
  String get groupBannerTag => 'Commandez ensemble';

  @override
  String get groupBannerTitle => 'Lancer une commande groupée';

  @override
  String get groupBannerSubtitle => 'Un panier partagé, une seule livraison';

  @override
  String get startNow => 'Commencer';

  @override
  String get viewCart => 'Voir le panier';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get searchTryDifferent => 'Essayez un autre nom ou type d\'article.';

  @override
  String get appearance => 'Apparence';

  @override
  String get appearanceSystem => 'Suivre le système';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get language => 'Langue';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get cartTitle => 'Votre panier';

  @override
  String get cartEmpty => 'Votre panier est vide';

  @override
  String get ecoBundle => 'Éco Bundle';

  @override
  String get ecoLocked =>
      'Débloquez avec Plus pour regrouper et réduire le CO₂';

  @override
  String get ecoIdle =>
      'Regroupez les commandes proches, économisez sur la livraison';

  @override
  String ecoActive(int count, String grams) {
    return 'Groupée avec $count commandes proches · ${grams}g de CO₂ économisés';
  }

  @override
  String get subtotal => 'Sous-total';

  @override
  String get deliveryFee => 'Frais de livraison';

  @override
  String get deliveryFeePlus => 'Frais de livraison (Plus)';

  @override
  String get ecoDiscount => 'Remise éco';

  @override
  String get total => 'Total';

  @override
  String get freeLabel => 'OFFERT';

  @override
  String goToCheckout(String total) {
    return 'Passer au paiement · $total TND';
  }

  @override
  String get checkoutTitle => 'Paiement';

  @override
  String get noAddress => 'Aucune adresse enregistrée';

  @override
  String get payment => 'Paiement';

  @override
  String get payCash => 'Espèces à la livraison';

  @override
  String get payCashHint => 'Payez le livreur en espèces';

  @override
  String get payCard => 'Carte à la livraison';

  @override
  String get payCardHint => 'Le livreur apporte un terminal de paiement';

  @override
  String get passportDeal => 'Offre Passeport';

  @override
  String get orderSummary => 'Récapitulatif';

  @override
  String placeOrder(String total) {
    return 'Commander · $total TND';
  }

  @override
  String orderFailed(String error) {
    return 'Échec de la commande : $error';
  }

  @override
  String get promoHint => 'Code d\'offre Passeport';

  @override
  String get apply => 'Appliquer';

  @override
  String get removeDeal => 'Retirer l\'offre';

  @override
  String get promoCheckFailed => 'Impossible de vérifier ce code. Réessayez.';

  @override
  String get promoUnknown => 'Ce code n\'existe pas.';

  @override
  String promoNotEarned(String zone) {
    return 'Pas encore débloqué — collectionnez d\'abord vos tampons $zone.';
  }

  @override
  String get promoExhausted => 'Vous avez déjà utilisé cette offre.';

  @override
  String get promoNoValue => 'Rien à réduire — la livraison est déjà offerte.';

  @override
  String get freshItems => 'Produits frais';

  @override
  String get noFilterMatches => 'Aucun produit ne correspond à ces filtres';

  @override
  String cartItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get sortBy => 'Trier';

  @override
  String get sortRecommended => 'Recommandé';

  @override
  String get sortPriceAsc => 'Prix : croissant';

  @override
  String get sortPriceDesc => 'Prix : décroissant';

  @override
  String get priceAscShort => 'Prix ↑';

  @override
  String get priceDescShort => 'Prix ↓';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get offers => 'Promos';

  @override
  String get aboutProduct => 'À propos de ce produit';

  @override
  String get whyYoullLoveIt => 'Pourquoi vous allez l\'adorer';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String mrp(String price) {
    return 'au lieu de $price';
  }

  @override
  String addedToCart(int count, String name) {
    return '$count × $name ajouté au panier';
  }

  @override
  String minsChip(int minutes) {
    return '$minutes MIN';
  }

  @override
  String minFeeDelivery(int minutes, String fee) {
    return '$minutes min · livraison $fee TND';
  }

  @override
  String deliveredToDoor(int minutes) {
    return '$minutes min · livré chez vous';
  }

  @override
  String get recommendation => 'Recommandations';

  @override
  String get noItemsYet => 'Pas encore d\'articles';

  @override
  String get noMatchesTryPhoto =>
      'Aucun résultat — essayez la demande photo ci-dessus';

  @override
  String get cantFindMedicine => 'Vous ne trouvez pas votre médicament ?';

  @override
  String get requestBannerSubtitle =>
      'Envoyez une photo et un pharmacien le trouvera';

  @override
  String get cantFindNeed => 'Vous ne trouvez pas ce qu\'il vous faut ?';

  @override
  String get requestTileSubtitle => 'Envoyez une photo et on le trouve';

  @override
  String get description => 'Description';

  @override
  String get requestSheetBody =>
      'Envoyez une photo de l\'article ou de votre ordonnance et un pharmacien le trouvera pour vous.';

  @override
  String get noteOptional => 'Note (facultatif)';

  @override
  String get noteHint => 'Dosage, marque, quantité…';

  @override
  String get sendRequest => 'Envoyer la demande';

  @override
  String get attachToContinue => 'Ajoutez une photo pour continuer';

  @override
  String get demoNoUpload => 'Démo — aucune photo n\'est envoyée ni conservée';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get addPhotoSubtitle => 'Ordonnance ou photo de l\'article';

  @override
  String get photoAttached => 'Photo ajoutée · touchez pour retirer';

  @override
  String get requestSent =>
      'Demande envoyée — un pharmacien confirmera la disponibilité.';

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get orderHistory => 'Historique des commandes';

  @override
  String get favorites => 'Favoris';

  @override
  String get favoritesSubtitle => 'Touchez-en un pour ouvrir sa boutique.';

  @override
  String get favoritesEmpty => 'Aucun favori — touchez ♡ sur un produit.';

  @override
  String get removeLabel => 'Retirer';

  @override
  String get savedAddresses => 'Adresses enregistrées';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get statOrders => 'Commandes';

  @override
  String get statCo2 => 'CO₂ économisé';

  @override
  String get statStamps => 'Tampons';

  @override
  String get swiftdropUser => 'Utilisateur SwiftDrop';

  @override
  String get plusActive => 'SwiftDrop Plus est actif';

  @override
  String plusRenews(String plan, String date) {
    return '$plan · renouvellement le $date';
  }

  @override
  String get plusPitch => 'Livraison offerte, Éco Bundle et commandes groupées';

  @override
  String get planWeekly => 'Hebdo';

  @override
  String get planMonthly => 'Mensuel';

  @override
  String get planYearly => 'Annuel';

  @override
  String get popularBadge => 'POPULAIRE';

  @override
  String get bestDealBadge => 'MEILLEURE OFFRE';

  @override
  String trialBadge(int days) {
    return '$days JOURS\nESSAI GRATUIT';
  }

  @override
  String percentOffBadge(int percent) {
    return '-$percent %';
  }

  @override
  String perWeek(String price) {
    return '$price/sem.';
  }

  @override
  String get restore => 'Restaurer';

  @override
  String get plusNoLimits => 'sans limites';

  @override
  String get perkDeliveryTitle => 'Livraison offerte, à chaque commande';

  @override
  String get perkDeliverySubtitle =>
      'Aucun frais de livraison — sur toutes les boutiques.';

  @override
  String get perkEcoTitle => 'Mode Éco Bundle';

  @override
  String get perkEcoSubtitle =>
      'Regroupez les commandes proches, réduisez le CO₂ et économisez.';

  @override
  String get perkGroupTitle => 'Créez des commandes groupées';

  @override
  String get perkGroupSubtitle =>
      'Lancez un panier partagé et divisez les frais. Rejoindre reste gratuit.';

  @override
  String tryTrial(int days) {
    return 'ESSAI GRATUIT DE $days JOURS';
  }

  @override
  String getPlus(String price) {
    return 'OBTENIR PLUS · $price TND';
  }

  @override
  String get trialStarted => 'Essai lancé — SwiftDrop Plus est actif.';

  @override
  String get plusActivated => 'SwiftDrop Plus est actif.';

  @override
  String plusFailed(String error) {
    return 'Impossible d\'activer Plus : $error';
  }

  @override
  String renewalTrial(int days, String price, int period) {
    return 'Gratuit pendant $days jours, puis $price TND tous les $period jours. Annulable à tout moment.';
  }

  @override
  String renewalPlain(String price, int period) {
    return '$price TND tous les $period jours. Annulable à tout moment.';
  }

  @override
  String get testPurchaseNote => 'Achat test — aucun paiement n\'est effectué';

  @override
  String get termsPrivacy => 'Conditions d\'utilisation · Confidentialité';
}
