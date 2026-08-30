/// Fake driver pool for the mock delivery simulation (resolves SPEC §1).
class MockDriver {
  const MockDriver({
    required this.id,
    required this.name,
    required this.rating,
    required this.vehicle,
  });

  final String id;
  final String name;
  final double rating;
  final String vehicle;

  String get initials => name
      .split(' ')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0])
      .take(2)
      .join();
}

const mockDrivers = <MockDriver>[
  MockDriver(id: 'drv_mehdi', name: 'Mehdi K.', rating: 4.9, vehicle: 'Scooter'),
  MockDriver(id: 'drv_yassine', name: 'Yassine B.', rating: 4.7, vehicle: 'Scooter'),
  MockDriver(id: 'drv_sami', name: 'Sami T.', rating: 4.8, vehicle: 'Motorbike'),
  MockDriver(id: 'drv_oussama', name: 'Oussama R.', rating: 4.6, vehicle: 'Car'),
];
