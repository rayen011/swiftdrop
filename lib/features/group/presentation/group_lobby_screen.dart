import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/group_order.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/group_order_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'group_menu_screen.dart';

/// Shared lobby: invite code, live participant list, host lock & checkout.
class GroupLobbyScreen extends StatelessWidget {
  const GroupLobbyScreen({super.key, required this.groupId, this.initial});

  final String groupId;
  final GroupOrder? initial;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().state.user?.uid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Group order')),
      body: StreamBuilder<GroupOrder?>(
        stream: sl<GroupOrderRepository>().watchGroup(groupId),
        initialData: initial,
        builder: (context, snapshot) {
          final group = snapshot.data;
          if (group == null) {
            return Center(
                child: CircularProgressIndicator(color: context.colors.ember));
          }
          final isHost = group.hostUserId == uid;
          return _LobbyBody(group: group, uid: uid, isHost: isHost);
        },
      ),
    );
  }
}

class _LobbyBody extends StatelessWidget {
  const _LobbyBody({
    required this.group,
    required this.uid,
    required this.isHost,
  });

  final GroupOrder group;
  final String uid;
  final bool isHost;

  Future<void> _editMyItems(BuildContext context) async {
    final restaurant =
        await sl<RestaurantRepository>().fetchRestaurant(group.restaurantId);
    if (restaurant == null || !context.mounted) return;
    final mine = group.participant(uid);
    context.push(
      Routes.groupMenu,
      extra: GroupMenuArgs(
        groupId: group.id,
        restaurant: restaurant,
        userId: uid,
        initialItems: mine?.items ?? const [],
      ),
    );
  }

  Future<void> _trackOrder(BuildContext context) async {
    final id = group.placedOrderId;
    if (id == null) return;
    final router = GoRouter.of(context);
    final order = await sl<OrderRepository>().fetchOrder(id);
    if (order == null || !context.mounted) return;
    router.go('${Routes.tracking}/${order.id}', extra: order);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ordered = group.status == GroupStatus.ordered;
    final locked = group.status == GroupStatus.locked;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _ShareCodeCard(code: group.shareCode),
              const SizedBox(height: 20),
              Text(group.restaurantName, style: text.titleLarge),
              Text('${group.participantCount} participant'
                  '${group.participantCount > 1 ? 's' : ''} · '
                  'fee split ${group.feeSharePerPerson.toStringAsFixed(2)} TND each',
                  style: text.bodySmall),
              const SizedBox(height: 16),
              ...group.participants.map((p) => _ParticipantTile(
                    participant: p,
                    isMe: p.userId == uid,
                  )),
              const SizedBox(height: 16),
              if (!ordered)
                OutlinedButton.icon(
                  onPressed: locked ? null : () => _editMyItems(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    (group.participant(uid)?.items.isEmpty ?? true)
                        ? 'Add my items'
                        : 'Edit my items',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.ink,
                    side: BorderSide(color: context.colors.line),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              const SizedBox(height: 8),
              _Totals(group: group),
            ],
          ),
        ),
        _BottomAction(
          group: group,
          isHost: isHost,
          onCheckout: () => _checkout(context),
          onTrack: () => _trackOrder(context),
        ),
      ],
    );
  }

  Future<void> _checkout(BuildContext context) async {
    // Host locks the group, then proceeds to the split checkout.
    await sl<GroupOrderRepository>().lockGroup(group.id);
    if (!context.mounted) return;
    context.push(Routes.groupCheckout, extra: group);
  }
}

class _ShareCodeCard extends StatelessWidget {
  const _ShareCodeCard({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: context.colors.hero,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: context.colors.line),
      ),
      child: Column(
        children: [
          Text('Invite code',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            code,
            style: AppTypography.mono(
                fontSize: 36, color: context.colors.ember)
                .copyWith(letterSpacing: 6),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code copied')),
                );
              }
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy code'),
            style: TextButton.styleFrom(foregroundColor: context.colors.ink),
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant, required this.isMe});

  final GroupParticipant participant;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.colors.surfaceHigh,
            child: Text(
              participant.name.isNotEmpty
                  ? participant.name[0].toUpperCase()
                  : '?',
              style: AppTypography.mono(fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(isMe ? '${participant.name} (you)' : participant.name,
                        style: text.titleMedium),
                    if (participant.isHost) ...[
                      const SizedBox(width: 6),
                      _hostBadge(context),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                if (participant.items.isEmpty)
                  Text('No items yet', style: text.bodySmall)
                else
                  ...participant.items.map((i) => Text(
                        '${i.quantity}× ${i.name}',
                        style: text.bodySmall,
                      )),
              ],
            ),
          ),
          Text('${participant.subtotal.toStringAsFixed(1)} TND',
              style: AppTypography.mono(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _hostBadge(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: context.colors.ember.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('HOST',
            style: AppTypography.mono(fontSize: 9, color: context.colors.emberText)),
      );
}

class _Totals extends StatelessWidget {
  const _Totals({required this.group});
  final GroupOrder group;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 24),
        _row(context, 'Items subtotal', group.itemsSubtotal),
        _row(context, 'Delivery fee (one, split)', group.deliveryFeeTND),
        const Divider(height: 16),
        _row(context, 'Group total', group.grandTotal, bold: true),
      ],
    );
  }

  Widget _row(BuildContext context, String label, double value,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text('${value.toStringAsFixed(1)} TND',
              style: AppTypography.mono(
                fontSize: bold ? 16 : 13,
                color: bold ? context.colors.ink : context.colors.inkSoft,
              )),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.group,
    required this.isHost,
    required this.onCheckout,
    required this.onTrack,
  });

  final GroupOrder group;
  final bool isHost;
  final VoidCallback onCheckout;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (group.status == GroupStatus.ordered) {
      child = ElevatedButton.icon(
        onPressed: onTrack,
        icon: const Icon(Icons.local_shipping_outlined),
        label: const Text('Track order'),
      );
    } else if (isHost) {
      final canCheckout = group.itemsSubtotal > 0;
      child = ElevatedButton(
        onPressed: canCheckout ? onCheckout : null,
        child: const Text('Lock & checkout'),
      );
    } else {
      child = Text(
        group.status == GroupStatus.locked
            ? 'Host is checking out…'
            : 'Waiting for the host to lock the order',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
