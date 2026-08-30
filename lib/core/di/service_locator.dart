import 'package:get_it/get_it.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/group_order_repository.dart';
import '../../data/repositories/neighborhood_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../data/seed/firestore_seeder.dart';

/// Global service locator. Called from main() after Firebase is initialized.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl
    ..registerLazySingleton<AuthRepository>(AuthRepository.new)
    ..registerLazySingleton<RestaurantRepository>(RestaurantRepository.new)
    ..registerLazySingleton<OrderRepository>(OrderRepository.new)
    ..registerLazySingleton<GroupOrderRepository>(GroupOrderRepository.new)
    ..registerLazySingleton<NeighborhoodRepository>(NeighborhoodRepository.new)
    ..registerLazySingleton<FirestoreSeeder>(FirestoreSeeder.new);
}
