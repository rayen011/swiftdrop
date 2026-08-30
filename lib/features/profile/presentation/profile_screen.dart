import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/constants/plus_config.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/favorite_item.dart';
import '../../../core/models/user_stats.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../favorites/cubit/favorites_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent so MainShell's ambient backdrop shows through.
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(context.l10n.navProfile)),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, auth) {
          final uid = auth.user?.uid;
          if (uid == null) {
            return Center(child: Text(context.l10n.notSignedIn));
          }
          return StreamBuilder<AppUser?>(
            stream: sl<AuthRepository>().watchUser(uid),
            initialData: auth.user,
            builder: (context, snapshot) {
              final user = snapshot.data ?? auth.user!;
              return ListView(
                // Bottom inset clears the floating nav bar.
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                children: [
                  _Header(user: user),
                  const SizedBox(height: 24),
                  _StatsRow(uid: uid),
                  const SizedBox(height: 20),
                  _PlusCard(user: user),
                  const SizedBox(height: 20),
                  _MenuTile(
                    icon: Icons.receipt_long_rounded,
                    label: context.l10n.orderHistory,
                    onTap: () => context.push(Routes.orderHistory),
                  ),
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, favs) => _MenuTile(
                      icon: Icons.favorite_rounded,
                      label: context.l10n.favorites,
                      trailing: '${favs.count}',
                      onTap: () => _showFavorites(context),
                    ),
                  ),
                  _MenuTile(
                    icon: Icons.location_on_rounded,
                    label: context.l10n.savedAddresses,
                    trailing: '${user.savedAddresses.length}',
                    onTap: () => _showAddresses(context, user),
                  ),
                  _MenuTile(
                    icon: Icons.brightness_6_rounded,
                    label: context.l10n.appearance,
                    trailing: _appearanceLabel(context, user.themeMode),
                    onTap: () =>
                        _showAppearancePicker(context, user.themeMode),
                  ),
                  _MenuTile(
                    icon: Icons.language_rounded,
                    label: context.l10n.language,
                    trailing: user.locale.isEmpty
                        ? null
                        : user.locale.toUpperCase(),
                    onTap: () => _showLanguagePicker(context, user.locale),
                  ),
                  const SizedBox(height: 12),
                  _MenuTile(
                    icon: Icons.logout_rounded,
                    label: context.l10n.logOut,
                    danger: true,
                    onTap: () => context.read<AuthCubit>().signOut(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// The wire values are '', 'light' and 'dark' — the same shape as [locale],
  /// and validated by the same `hasOnly` allowlist in firestore.rules.
  static String _appearanceLabel(BuildContext context, String mode) =>
      switch (mode) {
        'light' => context.l10n.appearanceLight,
        'dark' => context.l10n.appearanceDark,
        _ => context.l10n.appearanceSystem,
      };

  void _showAppearancePicker(BuildContext context, String current) {
    final cubit = context.read<AuthCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.appearance,
                  style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final (value, label, icon) in [
                ('', context.l10n.appearanceSystem, Icons.brightness_auto_rounded),
                ('light', context.l10n.appearanceLight, Icons.light_mode_rounded),
                ('dark', context.l10n.appearanceDark, Icons.dark_mode_rounded),
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    cubit.saveThemeMode(value);
                  },
                  leading: Icon(icon, color: context.colors.inkSoft),
                  title: Text(label),
                  trailing: Icon(
                    current == value
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: current == value
                        ? context.colors.ember
                        : context.colors.inkSoft,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, String current) {
    final cubit = context.read<AuthCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.language,
                  style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final (code, label) in [
                ('en', context.l10n.languageEnglish),
                ('fr', context.l10n.languageFrench),
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    cubit.saveLocale(code);
                  },
                  title: Text(label),
                  trailing: Icon(
                    (current.isEmpty ? 'en' : current) == code
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: (current.isEmpty ? 'en' : current) == code
                        ? context.colors.ember
                        : context.colors.inkSoft,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // BlocProvider.value: the sheet lives on the root navigator, outside this
      // screen's provider scope.
      builder: (_) => BlocProvider.value(
        value: context.read<FavoritesCubit>(),
        child: const _FavoritesSheet(),
      ),
    );
  }

  void _showAddresses(BuildContext context, AppUser user) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      // Scroll-safe: a user with many saved addresses shouldn't overflow the
      // sheet on a short screen.
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.savedAddresses,
                    style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 16),
                ...user.savedAddresses.map((a) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.location_on_rounded,
                          color: context.colors.ember),
                      title: Text(a.label),
                      subtitle: Text(a.fullAddress),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hearted products, with remove and a shortcut into their store.
class _FavoritesSheet extends StatelessWidget {
  const _FavoritesSheet();

  Future<void> _openStore(BuildContext context, FavoriteItem fav) async {
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    final restaurant =
        await sl<RestaurantRepository>().fetchRestaurant(fav.restaurantId);
    if (restaurant == null) return;
    navigator.pop();
    router.push('${Routes.restaurant}/${restaurant.id}', extra: restaurant);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favs) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.favorites, style: text.titleLarge),
                const SizedBox(height: 4),
                Text(context.l10n.favoritesSubtitle, style: text.bodySmall),
                const SizedBox(height: 12),
                if (favs.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(context.l10n.favoritesEmpty,
                          style: text.bodyMedium),
                    ),
                  )
                else
                  ...favs.items.map((fav) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => _openStore(context, fav),
                        leading: Icon(Icons.favorite_rounded,
                            color: context.colors.error),
                        title: Text(fav.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(fav.restaurantName,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${fav.priceTND.toStringAsFixed(1)} TND',
                                style: AppTypography.mono(fontSize: 12)),
                            IconButton(
                              tooltip: context.l10n.removeLabel,
                              icon: Icon(Icons.close_rounded,
                                  size: 18, color: context.colors.inkSoft),
                              onPressed: () =>
                                  context.read<FavoritesCubit>().toggle(fav),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final initials = user.name.isNotEmpty
        ? user.name.trim()[0].toUpperCase()
        : '👤';
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: context.colors.ember,
          child: Text(initials,
              style: AppTypography.mono(
                  fontSize: 24, color: context.colors.onEmber)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name.isEmpty ? context.l10n.swiftdropUser : user.name,
                style: text.titleLarge),
            const SizedBox(height: 2),
            Text(user.phone,
                style: AppTypography.mono(
                    fontSize: 13, color: context.colors.inkSoft)),
          ],
        ),
      ],
    );
  }
}

/// Upsell when Plus is inactive, status card when it's live.
class _PlusCard extends StatelessWidget {
  const _PlusCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final active = user.isPlus();
    final plan = PlusConfig.byId(user.activePlan);

    return InkWell(
      onTap: () => context.push(Routes.plus),
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: context.colors.hero,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
            color: active
                ? context.colors.ember.withValues(alpha: 0.5)
                : context.colors.line,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: context.colors.cta,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.bolt_rounded,
                  color: context.colors.onEmber, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      active
                          ? context.l10n.plusActive
                          : 'SwiftDrop Plus',
                      style: text.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    active
                        ? context.l10n.plusRenews(
                            plan?.label(context.l10n) ?? '',
                            _formatDate(user.plusUntil!))
                        : context.l10n.plusPitch,
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: context.colors.inkSoft, size: 14),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserStats>(
      stream: sl<OrderRepository>().watchUserStats(uid),
      initialData: UserStats.empty,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? UserStats.empty;
        return Row(
          children: [
            _stat(context, '${stats.totalOrders}', context.l10n.statOrders,
                context.colors.ember),
            const SizedBox(width: 12),
            _stat(
              context,
              _formatCo2(stats.totalCo2Saved),
              context.l10n.statCo2,
              context.colors.eco,
            ),
            const SizedBox(width: 12),
            _stat(context, '${stats.totalStamps}', context.l10n.statStamps,
                context.colors.star),
          ],
        );
      },
    );
  }

  String _formatCo2(double grams) =>
      grams >= 1000 ? '${(grams / 1000).toStringAsFixed(1)}kg' : '${grams.toStringAsFixed(0)}g';

  Widget _stat(BuildContext context, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.mono(fontSize: 20, color: color)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? context.colors.error : context.colors.ink;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: danger ? context.colors.error : context.colors.ember),
      title: Text(label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color)),
      trailing: trailing != null
          ? Text(trailing!, style: AppTypography.mono(fontSize: 13))
          : Icon(Icons.chevron_right_rounded,
              color: context.colors.inkSoft),
      onTap: onTap,
    );
  }
}
