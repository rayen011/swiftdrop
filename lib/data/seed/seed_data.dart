import '../../core/models/menu_item.dart';
import '../../core/models/neighborhood.dart';
import '../../core/models/restaurant.dart';

/// Static seed content (resolves SPEC §4 + §5). Written to Firestore once.

/// The SPEC §4 deal table, made computable (see [DealType]).
///
/// Two entries needed a judgement call to become real discounts:
///  * "20% off a partner resto" (El Menzah) — there is no partner-restaurant
///    concept in the schema, so it applies to any order and the copy now says so
///    rather than promising a scope the code can't honour.
///  * "Free dessert" (La Marsa) — granting an item means picking one from a
///    restaurant the user may not be ordering from. It's a 4 TND credit instead,
///    which is honest about what actually happens at checkout.
///
/// The `xN` in the SPEC's free-delivery deals is [PassportDeal.maxRedemptions].
/// These caps are load-bearing: free delivery is the headline SwiftDrop Plus
/// perk, so an uncapped free-delivery code would undercut the subscription.
const seedNeighborhoods = <PassportNeighborhood>[
  PassportNeighborhood(id: 'centre_ville', name: 'Centre Ville', city: 'Tunis', iconEmoji: '🏙️',
      deal: PassportDeal(type: DealType.percentOff, value: 15, code: 'CV15', description: '15% off any order')),
  PassportNeighborhood(id: 'lac1', name: 'Les Berges du Lac 1', city: 'Tunis', iconEmoji: '🌊',
      deal: PassportDeal(type: DealType.freeDelivery, value: 0, code: 'LAC1FREE', description: 'Free delivery, once')),
  PassportNeighborhood(id: 'lac2', name: 'Lac 2', city: 'Tunis', iconEmoji: '🛥️',
      deal: PassportDeal(type: DealType.percentOff, value: 20, code: 'LAC2-20', description: '20% off any order')),
  PassportNeighborhood(id: 'el_menzah', name: 'El Menzah', city: 'Tunis', iconEmoji: '🌿',
      deal: PassportDeal(type: DealType.percentOff, value: 20, code: 'MENZAH20', description: '20% off any order')),
  PassportNeighborhood(id: 'la_marsa', name: 'La Marsa', city: 'Tunis', iconEmoji: '🏖️',
      deal: PassportDeal(type: DealType.fixedOff, value: 4, code: 'MARSADESS', description: "4 TND off — dessert's on us")),
  PassportNeighborhood(id: 'carthage', name: 'Carthage', city: 'Tunis', iconEmoji: '🏛️',
      deal: PassportDeal(type: DealType.percentOff, value: 15, code: 'CARTH15', description: '15% off any order')),
  PassportNeighborhood(id: 'bardo', name: 'Le Bardo', city: 'Tunis', iconEmoji: '🕌',
      deal: PassportDeal(type: DealType.freeDelivery, value: 0, code: 'BARDOFREE', description: 'Free delivery, twice', maxRedemptions: 2)),
  PassportNeighborhood(id: 'beb_bhar', name: 'Beb Bhar', city: 'Tunis', iconEmoji: '🚪',
      deal: PassportDeal(type: DealType.percentOff, value: 10, code: 'BEB10', description: '10% off any order')),
  PassportNeighborhood(id: 'ariana', name: 'Ariana', city: 'Tunis', iconEmoji: '🌳',
      deal: PassportDeal(type: DealType.percentOff, value: 15, code: 'ARIANA15', description: '15% off any order')),
  PassportNeighborhood(id: 'el_manar', name: 'El Manar', city: 'Tunis', iconEmoji: '🎓',
      deal: PassportDeal(type: DealType.freeDelivery, value: 0, code: 'MANARFREE', description: 'Free delivery, once')),
];

const seedRestaurants = <Restaurant>[
  Restaurant(id: 'dar_el_pizza', name: 'Dar El Pizza', category: 'food', neighborhood: 'lac2', rating: 4.7, deliveryFeeTND: 2.5, estimatedMinutes: 25, isEcoEligible: true, menuCategories: ['Pizza', 'Sides', 'Drinks']),
  Restaurant(id: 'tacos_tunis', name: 'Tacos Tunis', category: 'food', neighborhood: 'el_menzah', rating: 4.5, deliveryFeeTND: 2.0, estimatedMinutes: 20, isEcoEligible: false, menuCategories: ['Tacos', 'Sides', 'Drinks']),
  Restaurant(id: 'lablabi_house', name: 'Lablabi House', category: 'food', neighborhood: 'beb_bhar', rating: 4.8, deliveryFeeTND: 1.5, estimatedMinutes: 18, isEcoEligible: true, menuCategories: ['Lablabi', 'Sides']),
  Restaurant(id: 'sushi_lac', name: 'Sushi Lac', category: 'food', neighborhood: 'lac1', rating: 4.6, deliveryFeeTND: 3.5, estimatedMinutes: 30, isEcoEligible: false, menuCategories: ['Rolls', 'Nigiri', 'Drinks']),
  Restaurant(id: 'burger_marsa', name: 'Burger Marsa', category: 'food', neighborhood: 'la_marsa', rating: 4.4, deliveryFeeTND: 2.5, estimatedMinutes: 28, isEcoEligible: true, menuCategories: ['Burgers', 'Sides', 'Drinks']),
  Restaurant(id: 'monoprix_express', name: 'Monoprix Express', category: 'grocery', neighborhood: 'ariana', rating: 4.3, deliveryFeeTND: 1.0, estimatedMinutes: 35, isEcoEligible: true, menuCategories: ['Fresh', 'Pantry', 'Drinks']),
  Restaurant(id: 'pharmacie_centrale', name: 'Pharmacie Centrale', category: 'pharmacy', neighborhood: 'centre_ville', rating: 4.9, deliveryFeeTND: 1.5, estimatedMinutes: 22, isEcoEligible: false, menuCategories: ['Care', 'Essentials']),
  Restaurant(id: 'cafe_de_tunis', name: 'Café de Tunis', category: 'coffee', neighborhood: 'la_marsa', rating: 4.7, deliveryFeeTND: 2.0, estimatedMinutes: 15, isEcoEligible: true, menuCategories: ['Coffee', 'Cold', 'Bakery']),
];

/// menuItems keyed by restaurantId.
const seedMenus = <String, List<MenuItem>>{
  'dar_el_pizza': [
    MenuItem(id: 'dp_margh', restaurantId: 'dar_el_pizza', category: 'Pizza', name: 'Margherita', description: 'Tomato, mozzarella, basil', priceTND: 12.0, options: [
      MenuOption(label: 'Size', choices: [MenuChoice(name: 'Small'), MenuChoice(name: 'Large', extraPriceTND: 4)]),
    ]),
    MenuItem(id: 'dp_pep', restaurantId: 'dar_el_pizza', category: 'Pizza', name: 'Pepperoni', description: 'Double pepperoni, mozzarella', priceTND: 15.0, options: [
      MenuOption(label: 'Size', choices: [MenuChoice(name: 'Small'), MenuChoice(name: 'Large', extraPriceTND: 4)]),
    ]),
    MenuItem(id: 'dp_fries', restaurantId: 'dar_el_pizza', category: 'Sides', name: 'Fries', description: 'Crispy fries', priceTND: 4.0),
    MenuItem(id: 'dp_cola', restaurantId: 'dar_el_pizza', category: 'Drinks', name: 'Cola', description: '33cl can', priceTND: 2.5),
  ],
  'tacos_tunis': [
    MenuItem(id: 'tt_chick', restaurantId: 'tacos_tunis', category: 'Tacos', name: 'Chicken Tacos', description: 'Grilled chicken, cheese sauce', priceTND: 9.0, options: [
      MenuOption(label: 'Size', choices: [MenuChoice(name: 'Medium'), MenuChoice(name: 'XL', extraPriceTND: 3)]),
    ]),
    MenuItem(id: 'tt_beef', restaurantId: 'tacos_tunis', category: 'Tacos', name: 'Beef Tacos', description: 'Minced beef, cheddar', priceTND: 10.5),
    MenuItem(id: 'tt_nug', restaurantId: 'tacos_tunis', category: 'Sides', name: 'Nuggets x6', description: 'Chicken nuggets', priceTND: 5.0),
    MenuItem(id: 'tt_water', restaurantId: 'tacos_tunis', category: 'Drinks', name: 'Water', description: '50cl', priceTND: 1.0),
  ],
  'lablabi_house': [
    MenuItem(id: 'lh_class', restaurantId: 'lablabi_house', category: 'Lablabi', name: 'Lablabi Classic', description: 'Chickpeas, harissa, egg, bread', priceTND: 5.5, options: [
      MenuOption(label: 'Egg', choices: [MenuChoice(name: 'One egg'), MenuChoice(name: 'Two eggs', extraPriceTND: 1)]),
    ]),
    MenuItem(id: 'lh_tuna', restaurantId: 'lablabi_house', category: 'Lablabi', name: 'Lablabi + Tuna', description: 'With tuna topping', priceTND: 7.0),
    MenuItem(id: 'lh_harissa', restaurantId: 'lablabi_house', category: 'Sides', name: 'Extra Harissa', description: 'Spicy side', priceTND: 1.0),
  ],
  'sushi_lac': [
    MenuItem(id: 'sl_cali', restaurantId: 'sushi_lac', category: 'Rolls', name: 'California Roll x8', description: 'Crab, avocado, cucumber', priceTND: 16.0),
    MenuItem(id: 'sl_salmon', restaurantId: 'sushi_lac', category: 'Nigiri', name: 'Salmon Nigiri x4', description: 'Fresh salmon', priceTND: 14.0),
    MenuItem(id: 'sl_green', restaurantId: 'sushi_lac', category: 'Drinks', name: 'Green Tea', description: 'Hot', priceTND: 3.0),
  ],
  'burger_marsa': [
    MenuItem(id: 'bm_classic', restaurantId: 'burger_marsa', category: 'Burgers', name: 'Classic Burger', description: 'Beef, cheddar, lettuce, sauce', priceTND: 11.0, options: [
      MenuOption(label: 'Extras', choices: [MenuChoice(name: 'None'), MenuChoice(name: 'Bacon', extraPriceTND: 2), MenuChoice(name: 'Double patty', extraPriceTND: 4)]),
    ]),
    MenuItem(id: 'bm_chick', restaurantId: 'burger_marsa', category: 'Burgers', name: 'Crispy Chicken', description: 'Fried chicken, slaw', priceTND: 10.0),
    MenuItem(id: 'bm_fries', restaurantId: 'burger_marsa', category: 'Sides', name: 'Loaded Fries', description: 'Cheese & onions', priceTND: 6.0),
    MenuItem(id: 'bm_lemon', restaurantId: 'burger_marsa', category: 'Drinks', name: 'Lemonade', description: 'Fresh', priceTND: 3.5),
  ],
  'monoprix_express': [
    MenuItem(id: 'mp_oranges', restaurantId: 'monoprix_express', category: 'Fresh', name: 'Sweet Oranges', description: 'Naturally sweet, juicy and handpicked at peak ripeness. Perfect for snacking, juicing or adding a refreshing touch to your meals.', priceTND: 3.0, mrpTND: 4.0, unit: '500g', highlights: ['100% natural, no chemicals', 'Handpicked at peak ripeness', 'Rich in vitamin C']),
    MenuItem(id: 'mp_apples', restaurantId: 'monoprix_express', category: 'Fresh', name: 'Fresh Apples', description: 'Crisp and crunchy red apples, cold-stored to lock in freshness.', priceTND: 5.5, mrpTND: 7.0, unit: '1kg', highlights: ['Crisp and sweet', 'Great for snacking & baking']),
    MenuItem(id: 'mp_tomatoes', restaurantId: 'monoprix_express', category: 'Fresh', name: 'Fresh Tomatoes', description: 'Vine-ripened tomatoes, farm fresh.', priceTND: 2.0, mrpTND: 3.0, unit: '500g', highlights: ['Vine-ripened', 'Perfect for salads & sauces']),
    MenuItem(id: 'mp_lettuce', restaurantId: 'monoprix_express', category: 'Fresh', name: 'Organic Lettuce', description: 'Crisp organic leaves, washed and ready to use.', priceTND: 2.5, mrpTND: 3.0, unit: '250g', highlights: ['Certified organic', 'Washed & ready to use']),
    MenuItem(id: 'mp_corn', restaurantId: 'monoprix_express', category: 'Fresh', name: 'Sweet Corn', description: 'Tender golden cobs, freshly husked.', priceTND: 2.0, unit: '2 pcs', highlights: ['Tender & sweet', 'Freshly husked']),
    MenuItem(id: 'mp_milk', restaurantId: 'monoprix_express', category: 'Fresh', name: 'Milk 1L', description: 'Semi-skimmed', priceTND: 1.6),
    MenuItem(id: 'mp_eggs', restaurantId: 'monoprix_express', category: 'Fresh', name: 'Eggs x12', description: 'Free-range', priceTND: 4.2, mrpTND: 5.0),
    MenuItem(id: 'mp_pasta', restaurantId: 'monoprix_express', category: 'Pantry', name: 'Pasta 500g', description: 'Penne', priceTND: 2.0),
    MenuItem(id: 'mp_water', restaurantId: 'monoprix_express', category: 'Drinks', name: 'Water 6x1.5L', description: 'Pack', priceTND: 3.6),
  ],
  'pharmacie_centrale': [
    MenuItem(id: 'pc_para', restaurantId: 'pharmacie_centrale', category: 'Pain relief', name: 'Paracetamol 500mg', description: 'Fast-acting relief for headaches, fever and mild pain. 16 tablets per pack.', priceTND: 2.8, mrpTND: 3.5, rating: 4.6),
    MenuItem(id: 'pc_vitc', restaurantId: 'pharmacie_centrale', category: 'Vitamins', name: 'Vitamin C Effervescent', description: 'Supports immunity and reduces tiredness. 20 effervescent tablets, orange flavour.', priceTND: 9.0, rating: 4.8),
    MenuItem(id: 'pc_mask', restaurantId: 'pharmacie_centrale', category: 'Essentials', name: 'Surgical Face Masks', description: '3-ply protective masks, box of 10.', priceTND: 3.5, mrpTND: 5.0, rating: 4.7),
    MenuItem(id: 'pc_syrup', restaurantId: 'pharmacie_centrale', category: 'Cold & flu', name: 'Cough Syrup 125ml', description: 'Soothes dry and tickly coughs. Non-drowsy formula.', priceTND: 7.5, rating: 4.4),
    MenuItem(id: 'pc_facewash', restaurantId: 'pharmacie_centrale', category: 'Skin care', name: 'Foaming Face Wash', description: 'Gentle yet powerful cleanser ideal for oily and combination skin. Creates a luxurious, airy foam that deeply cleanses.', priceTND: 18.0, mrpTND: 22.0, rating: 4.7),
    MenuItem(id: 'pc_plasters', restaurantId: 'pharmacie_centrale', category: 'Essentials', name: 'Adhesive Plasters x20', description: 'Assorted waterproof plasters.', priceTND: 4.0, rating: 4.5),
  ],
  'cafe_de_tunis': [
    MenuItem(id: 'ct_espresso', restaurantId: 'cafe_de_tunis', category: 'Coffee', name: 'Espresso', description: 'Single shot, Arabica', priceTND: 2.5, options: [
      MenuOption(label: 'Size', choices: [MenuChoice(name: 'Single'), MenuChoice(name: 'Double', extraPriceTND: 1)]),
    ]),
    MenuItem(id: 'ct_cappuccino', restaurantId: 'cafe_de_tunis', category: 'Coffee', name: 'Cappuccino', description: 'Espresso, steamed milk, foam', priceTND: 3.5),
    MenuItem(id: 'ct_latte', restaurantId: 'cafe_de_tunis', category: 'Coffee', name: 'Café Latte', description: 'Smooth espresso with milk', priceTND: 4.0),
    MenuItem(id: 'ct_juice', restaurantId: 'cafe_de_tunis', category: 'Cold', name: 'Fresh Orange Juice', description: 'Squeezed to order', priceTND: 4.5),
    MenuItem(id: 'ct_croissant', restaurantId: 'cafe_de_tunis', category: 'Bakery', name: 'Butter Croissant', description: 'Baked this morning', priceTND: 2.0),
  ],
};
