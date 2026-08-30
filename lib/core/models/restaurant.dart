import 'package:equatable/equatable.dart';

/// A restaurant/store at /restaurants/{id}. Schema is identical for seeded fakes
/// and real partners, so partners swap in with no migration.
class Restaurant extends Equatable {
  const Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.neighborhood,
    this.imageUrl = '',
    this.rating = 0,
    this.deliveryFeeTND = 0,
    this.estimatedMinutes = 0,
    this.isEcoEligible = false,
    this.isOpen = true,
    this.menuCategories = const [],
  });

  final String id;
  final String name;
  final String imageUrl;
  final String category; // food / grocery / pharmacy
  final double rating;
  final double deliveryFeeTND;
  final int estimatedMinutes;
  final String neighborhood; // maps to a /neighborhoods id (Passport zone)
  final bool isEcoEligible;
  final bool isOpen;
  final List<String> menuCategories;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'category': category,
        'rating': rating,
        'deliveryFeeTND': deliveryFeeTND,
        'estimatedMinutes': estimatedMinutes,
        'neighborhood': neighborhood,
        'isEcoEligible': isEcoEligible,
        'isOpen': isOpen,
        'menuCategories': menuCategories,
      };

  factory Restaurant.fromMap(Map<String, dynamic> map) => Restaurant(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        category: map['category'] as String? ?? 'food',
        rating: (map['rating'] as num?)?.toDouble() ?? 0,
        deliveryFeeTND: (map['deliveryFeeTND'] as num?)?.toDouble() ?? 0,
        estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt() ?? 0,
        neighborhood: map['neighborhood'] as String? ?? '',
        isEcoEligible: map['isEcoEligible'] as bool? ?? false,
        isOpen: map['isOpen'] as bool? ?? true,
        menuCategories: List<String>.from(map['menuCategories'] as List? ?? []),
      );

  @override
  List<Object?> get props => [id, name, category, neighborhood];
}
