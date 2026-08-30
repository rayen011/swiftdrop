import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/models/store_vertical.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/skeletons.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../group/presentation/group_entry_sheet.dart';
import 'widgets/order_again_row.dart';
import 'widgets/restaurant_card.dart';
import 'widgets/store_picker.dart';

/// Central hub — browse stores from Firestore, one vertical at a time.
///
/// The old Food/Grocery/Pharmacy chips are gone: the shopper now picks a store
/// type from [StoreSelectorBar] at the top, and the list below filters to that
/// vertical. Each vertical will grow its own screen design later; today they
/// share this store-list layout, differing by heading, tagline and search hint.
///
/// The catalog is seeded out-of-band by an admin (see README), not from here.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = sl<RestaurantRepository>();

  StoreVertical _vertical = StoreVertical.fastFood;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = storeVerticalAccent(context, _vertical);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        // Pull-to-refresh forces a server round trip; the stream then re-emits.
        // Mostly reassurance — the list is live — but it recovers visibly after
        // a connectivity drop.
        child: RefreshIndicator.adaptive(
          color: context.colors.ember,
          onRefresh: () => _repo.fetchRestaurants(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            SliverToBoxAdapter(
              // Accent wash behind the header. AnimatedContainer cross-fades the
              // colour when the vertical changes, so switching store type visibly
              // recolours the top of the screen — the "I changed mode" cue.
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent.withValues(alpha: 0.16),
                      accent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topRow(),
                    const SizedBox(height: 18),
                    _greeting(text),
                    const SizedBox(height: 20),
                    _SearchBar(
                      hint: _vertical.searchHint(context.l10n),
                      accent: accent,
                      onTap: () =>
                          context.push(Routes.search, extra: _vertical),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, auth) {
                        final uid = auth.user?.uid;
                        if (uid == null) return const SizedBox.shrink();
                        // Keyed by uid so a sign-in swap rebinds the stream.
                        return OrderAgainRow(key: ValueKey(uid), uid: uid);
                      },
                    ),
                    const _GroupOrderBanner(),
                    const SizedBox(height: 26),
                    // Keyed AnimatedSwitcher: the heading + tagline fade/slide as
                    // the vertical changes, reinforcing the mode switch.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SizeTransition(
                          sizeFactor: anim,
                          axisAlignment: -1,
                          child: child,
                        ),
                      ),
                      child: Column(
                        key: ValueKey(_vertical),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_vertical.listHeading(context.l10n),
                              style: text.titleLarge
                                  ?.copyWith(color: accent)),
                          const SizedBox(height: 2),
                          Text(_vertical.tagline(context.l10n),
                              style: text.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
              _restaurantList(),
              // Clears the floating nav bar (MainShell sets extendBody: true).
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  /// Store-type picker + notification bell — the top of the screen.
  Widget _topRow() {
    return Row(
      children: [
        Expanded(
          child: StoreSelectorBar(
            vertical: _vertical,
            onChanged: (v) => setState(() => _vertical = v),
          ),
        ),
        const SizedBox(width: 12),
        const AppCircleButton(icon: Icons.notifications_none_rounded),
      ],
    );
  }

  Widget _greeting(TextTheme text) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final name = state.user?.name ?? '';
        final zone = state.user?.defaultAddress?.label ?? 'Lac 2';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: context.colors.ember, size: 16),
                const SizedBox(width: 4),
                Text('${context.l10n.deliverTo} · $zone',
                    style: AppTypography.mono(
                        fontSize: 12, color: context.colors.inkSoft)),
              ],
            ),
            const SizedBox(height: 10),
            // The name carries the ember accent — the greeting reads as a
            // display line rather than a label. Localized as one template
            // ("Hi, {name} 👋") and split on the name so the accent colour
            // lands on it wherever the translation places it.
            _AccentedGreeting(
              template: context.l10n.greeting(
                  name.isEmpty ? context.l10n.greetingFallbackName : name),
              accented:
                  name.isEmpty ? context.l10n.greetingFallbackName : name,
              style: text.displayLarge,
            ),
          ],
        );
      },
    );
  }

  Widget _restaurantList() {
    return StreamBuilder<List<Restaurant>>(
      stream: _repo.watchRestaurants(category: _vertical.category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: StoreListSkeleton()),
          );
        }
        final restaurants = snapshot.data ?? [];
        if (restaurants.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child:
                  Center(child: Text(_vertical.emptyLabel(context.l10n))),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: restaurants.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final r = restaurants[i];
              return RestaurantCard(
                restaurant: r,
                onTap: () =>
                    context.push('${Routes.restaurant}/${r.id}', extra: r),
              );
            },
          ),
        );
      },
    );
  }
}

/// Renders a localized greeting template with the name in the accent colour,
/// wherever the translation happens to place it.
class _AccentedGreeting extends StatelessWidget {
  const _AccentedGreeting({
    required this.template,
    required this.accented,
    this.style,
  });

  final String template;
  final String accented;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final index = template.indexOf(accented);
    if (index < 0) return Text(template, style: style);
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: template.substring(0, index)),
          TextSpan(
            text: accented,
            style: TextStyle(color: context.colors.ember),
          ),
          TextSpan(text: template.substring(index + accented.length)),
        ],
      ),
    );
  }
}

/// Looks like a search field but is a button: tapping opens the focused search
/// screen for the current vertical. (A live field on Home would fight the
/// scroll; a dedicated screen is the friendlier pattern.)
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.hint,
    required this.accent,
    required this.onTap,
  });

  final String hint;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(color: context.colors.line),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: context.colors.inkSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Text(hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.tune_rounded, color: accent, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupOrderBanner extends StatelessWidget {
  const _GroupOrderBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showGroupEntrySheet(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: context.colors.hero,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: context.colors.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.ember.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.groups_rounded,
                            color: context.colors.ember, size: 12),
                        const SizedBox(width: 5),
                        Text(context.l10n.groupBannerTag,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: context.colors.emberText)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(context.l10n.groupBannerTitle,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(context.l10n.groupBannerSubtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 132,
                    child: AppPrimaryButton(
                      height: 40,
                      onPressed: () => showGroupEntrySheet(context),
                      child: Text(context.l10n.startNow,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: context.colors.onEmber)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.groups_rounded,
              size: 74,
              color: context.colors.ember.withValues(alpha: 0.22),
            ),
          ],
        ),
      ),
    );
  }
}
