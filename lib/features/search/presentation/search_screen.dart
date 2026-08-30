import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/models/store_vertical.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/skeletons.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../home/presentation/widgets/restaurant_card.dart';
import '../../home/presentation/widgets/store_picker.dart' show storeVerticalAccent;

/// Whether a store matches a query — by name or by what it sells
/// (menuCategories), so "pizza" finds Dar El Pizza. Case-insensitive; an empty
/// query matches everything (the screen doubles as a filterable browse).
bool storeMatchesQuery(Restaurant r, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  if (r.name.toLowerCase().contains(q)) return true;
  return r.menuCategories.any((c) => c.toLowerCase().contains(q));
}

/// Focused search over the active vertical's stores. Opened from the home
/// search bar; results reuse the home [RestaurantCard] and route into a store.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.vertical, this.repo});

  final StoreVertical vertical;

  /// Injectable for tests; defaults to the registered repository.
  final RestaurantRepository? repo;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final RestaurantRepository _repo =
      widget.repo ?? sl<RestaurantRepository>();
  final _controller = TextEditingController();
  String _query = '';

  /// Subscribed once, not in build: setState on every keystroke would otherwise
  /// tear down and recreate the Firestore stream per character, flickering the
  /// list back to its loading state as the user types.
  late final Stream<List<Restaurant>> _stores =
      _repo.watchRestaurants(category: widget.vertical.category);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = storeVerticalAccent(context, widget.vertical);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  AppCircleButton(
                    icon: Icons.arrow_back_rounded,
                    size: 42,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _field(accent)),
                ],
              ),
            ),
            Expanded(child: _results(accent)),
          ],
        ),
      ),
    );
  }

  Widget _field(Color accent) {
    return TextField(
      controller: _controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onChanged: (v) => setState(() => _query = v),
      decoration: InputDecoration(
        hintText: widget.vertical.searchHint(context.l10n),
        prefixIcon: Icon(Icons.search_rounded, color: accent),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close_rounded,
                    color: context.colors.inkSoft),
                onPressed: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }

  Widget _results(Color accent) {
    return StreamBuilder<List<Restaurant>>(
      stream: _stores,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: StoreListSkeleton(),
          );
        }
        final all = snapshot.data ?? [];
        final results =
            all.where((r) => storeMatchesQuery(r, _query)).toList();

        if (results.isEmpty) {
          return _Empty(query: _query, vertical: widget.vertical);
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, i) {
            final r = results[i];
            return RestaurantCard(
              restaurant: r,
              onTap: () =>
                  context.push('${Routes.restaurant}/${r.id}', extra: r),
            );
          },
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.query, required this.vertical});
  final String query;
  final StoreVertical vertical;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final searching = query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(searching ? Icons.search_off_rounded : Icons.storefront_outlined,
                size: 48, color: context.colors.inkSoft),
            const SizedBox(height: 16),
            Text(
              searching
                  ? context.l10n.searchNoResults(query.trim())
                  : vertical.emptyLabel(context.l10n),
              textAlign: TextAlign.center,
              style: text.titleMedium,
            ),
            if (searching) ...[
              const SizedBox(height: 6),
              Text(context.l10n.searchTryDifferent,
                  textAlign: TextAlign.center, style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
