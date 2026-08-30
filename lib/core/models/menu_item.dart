import 'package:equatable/equatable.dart';

/// A single selectable choice within a [MenuOption] (e.g. "Large +2 TND").
class MenuChoice extends Equatable {
  const MenuChoice({required this.name, this.extraPriceTND = 0});

  final String name;
  final double extraPriceTND;

  Map<String, dynamic> toMap() => {'name': name, 'extraPriceTND': extraPriceTND};

  factory MenuChoice.fromMap(Map<String, dynamic> map) => MenuChoice(
        name: map['name'] as String? ?? '',
        extraPriceTND: (map['extraPriceTND'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [name, extraPriceTND];
}

/// A customization group on a menu item (e.g. "Size", "Extras").
class MenuOption extends Equatable {
  const MenuOption({required this.label, required this.choices});

  final String label;
  final List<MenuChoice> choices;

  Map<String, dynamic> toMap() => {
        'label': label,
        'choices': choices.map((c) => c.toMap()).toList(),
      };

  factory MenuOption.fromMap(Map<String, dynamic> map) => MenuOption(
        label: map['label'] as String? ?? '',
        choices: (map['choices'] as List<dynamic>? ?? [])
            .map((e) => MenuChoice.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  @override
  List<Object?> get props => [label, choices];
}

/// A menu item under /restaurants/{id}/menuItems/{id}.
class MenuItem extends Equatable {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.category,
    required this.name,
    required this.priceTND,
    this.mrpTND = 0,
    this.description = '',
    this.imageUrl = '',
    this.unit = '',
    this.highlights = const [],
    this.rating = 0,
    this.options = const [],
    this.isAvailable = true,
  });

  final String id;
  final String restaurantId;
  final String category;
  final String name;
  final String description;
  final String imageUrl;
  final double priceTND;

  /// Original ("MRP") price before a sale. 0 means no sale — [priceTND] stands
  /// alone. Display-only: the amount actually charged is always [priceTND].
  /// Drives the strikethrough on the grocery cards.
  final double mrpTND;

  /// Pack size shown as a chip on the product page, e.g. "500g". Empty when the
  /// size is already in the name (Milk 1L) or not applicable.
  final String unit;

  /// "Why you'll love it" selling points. Empty hides that section rather than
  /// inventing claims for items that have none.
  final List<String> highlights;

  /// Product rating out of 5. 0 hides the stars (grocery produce carries none).
  final double rating;

  final List<MenuOption> options;
  final bool isAvailable;

  /// True when a genuine sale price is set (MRP above the current price).
  bool get isOnSale => mrpTND > priceTND;

  /// Whole-percent saving vs MRP, e.g. 25 for ₹30 off ₹40. 0 when not on sale.
  int get discountPercent =>
      isOnSale ? (((mrpTND - priceTND) / mrpTND) * 100).round() : 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'restaurantId': restaurantId,
        'category': category,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'priceTND': priceTND,
        'mrpTND': mrpTND,
        'unit': unit,
        'highlights': highlights,
        'rating': rating,
        'options': options.map((o) => o.toMap()).toList(),
        'isAvailable': isAvailable,
      };

  factory MenuItem.fromMap(Map<String, dynamic> map) => MenuItem(
        id: map['id'] as String? ?? '',
        restaurantId: map['restaurantId'] as String? ?? '',
        category: map['category'] as String? ?? '',
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        priceTND: (map['priceTND'] as num?)?.toDouble() ?? 0,
        mrpTND: (map['mrpTND'] as num?)?.toDouble() ?? 0,
        unit: map['unit'] as String? ?? '',
        highlights: List<String>.from(map['highlights'] as List? ?? const []),
        rating: (map['rating'] as num?)?.toDouble() ?? 0,
        options: (map['options'] as List<dynamic>? ?? [])
            .map((e) => MenuOption.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        isAvailable: map['isAvailable'] as bool? ?? true,
      );

  @override
  List<Object?> get props =>
      [id, restaurantId, name, priceTND, mrpTND, unit, highlights, rating];
}
