import 'package:equatable/equatable.dart';

/// A saved delivery address (embedded in the user document and copied onto orders).
class Address extends Equatable {
  const Address({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    required this.fullAddress,
  });

  final String id;
  final String label; // "Home", "Work", custom
  final double lat;
  final double lng;
  final String fullAddress;

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'lat': lat,
        'lng': lng,
        'fullAddress': fullAddress,
      };

  factory Address.fromMap(Map<String, dynamic> map) => Address(
        id: map['id'] as String? ?? '',
        label: map['label'] as String? ?? 'Address',
        lat: (map['lat'] as num?)?.toDouble() ?? 0,
        lng: (map['lng'] as num?)?.toDouble() ?? 0,
        fullAddress: map['fullAddress'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, label, lat, lng, fullAddress];
}
