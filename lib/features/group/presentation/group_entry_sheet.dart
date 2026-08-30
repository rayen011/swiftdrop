import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../auth/cubit/auth_cubit.dart';

/// Bottom sheet from the Home banner: start a new group or join one by code.
///
/// Hosting is a SwiftDrop Plus perk; joining deliberately is not. An invite has
/// to work for whoever receives it, and a guest who joins a group is exactly the
/// person most likely to subscribe later — gating the invite would strangle the
/// loop that grows the feature.
void showGroupEntrySheet(BuildContext context) {
  final isPlus = context.read<AuthCubit>().state.user?.isPlus() ?? false;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('Group order',
                style: Theme.of(sheetContext).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Order together, split one delivery fee.',
                style: Theme.of(sheetContext).textTheme.bodyMedium),
            const SizedBox(height: 20),
            _Action(
              icon: isPlus
                  ? Icons.add_circle_outline_rounded
                  : Icons.lock_outline_rounded,
              title: 'Start a group',
              subtitle: isPlus
                  ? 'Pick a restaurant and invite friends'
                  : 'Hosting is a Plus perk — tap to unlock',
              locked: !isPlus,
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push(isPlus ? Routes.groupStart : Routes.plus);
              },
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.group_add_outlined,
              title: 'Join with a code',
              subtitle: 'Enter a 6-character invite code',
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push(Routes.groupJoin);
              },
            ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.locked = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: locked ? context.colors.inkSoft : context.colors.ember,
                size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      if (locked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: context.colors.cta,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('PLUS',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                color: context.colors.onEmber,
                                fontSize: 9,
                                letterSpacing: 0.4,
                              )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: context.colors.inkSoft, size: 16),
          ],
        ),
      ),
    );
  }
}
