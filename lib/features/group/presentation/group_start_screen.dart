import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/repositories/group_order_repository.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../home/presentation/widgets/restaurant_card.dart';

/// Step 1 of hosting a group: choose the restaurant everyone orders from.
class GroupStartScreen extends StatefulWidget {
  const GroupStartScreen({super.key});

  @override
  State<GroupStartScreen> createState() => _GroupStartScreenState();
}

class _GroupStartScreenState extends State<GroupStartScreen> {
  bool _creating = false;

  Future<void> _create(Restaurant restaurant) async {
    final auth = context.read<AuthCubit>().state.user;
    if (auth == null || _creating) return;
    setState(() => _creating = true);
    final router = GoRouter.of(context);
    try {
      final group = await sl<GroupOrderRepository>().createGroup(
        hostUserId: auth.uid,
        hostName: auth.name.isEmpty ? 'Host' : auth.name,
        restaurant: restaurant,
      );
      router.pushReplacement('${Routes.groupLobby}/${group.id}', extra: group);
    } catch (e) {
      if (!mounted) return;
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start group: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = sl<RestaurantRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a restaurant')),
      body: Stack(
        children: [
          StreamBuilder<List<Restaurant>>(
            stream: repo.watchRestaurants(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child:
                        CircularProgressIndicator(color: context.colors.ember));
              }
              final restaurants = snapshot.data ?? [];
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: restaurants.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, i) => RestaurantCard(
                  restaurant: restaurants[i],
                  onTap: () => _create(restaurants[i]),
                ),
              );
            },
          ),
          if (_creating)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                  child: CircularProgressIndicator(color: context.colors.ember)),
            ),
        ],
      ),
    );
  }
}
