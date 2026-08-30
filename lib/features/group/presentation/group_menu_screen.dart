import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/order.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/food_image.dart';
import '../../../data/repositories/group_order_repository.dart';
import '../../../data/repositories/restaurant_repository.dart';
import '../../menu/presentation/item_detail_sheet.dart';

/// Arguments for [GroupMenuScreen] (passed via go_router `extra`).
class GroupMenuArgs {
  const GroupMenuArgs({
    required this.groupId,
    required this.restaurant,
    required this.userId,
    required this.initialItems,
  });

  final String groupId;
  final Restaurant restaurant;
  final String userId;
  final List<OrderItem> initialItems;
}

/// Lets a participant add their own items; each change writes their items array
/// to the group doc so everyone sees it update live.
class GroupMenuScreen extends StatefulWidget {
  const GroupMenuScreen({super.key, required this.args});

  final GroupMenuArgs args;

  @override
  State<GroupMenuScreen> createState() => _GroupMenuScreenState();
}

class _GroupMenuScreenState extends State<GroupMenuScreen> {
  late List<OrderItem> _myItems = List.of(widget.args.initialItems);

  int get _count => _myItems.fold(0, (sum, i) => sum + i.quantity);
  double get _subtotal => _myItems.fold(0, (sum, i) => sum + i.lineTotal);

  Future<void> _sync() => sl<GroupOrderRepository>().updateParticipantItems(
        groupId: widget.args.groupId,
        userId: widget.args.userId,
        items: _myItems,
      );

  void _addItem(OrderItem item) {
    setState(() => _myItems = [..._myItems, item]);
    _sync();
  }

  void _removeAt(int index) {
    setState(() => _myItems = [..._myItems]..removeAt(index));
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    final repo = sl<RestaurantRepository>();
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.args.restaurant.name)),
      body: StreamBuilder<List<MenuItem>>(
        stream: repo.watchMenu(widget.args.restaurant.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: context.colors.ember));
          }
          final items = snapshot.data ?? [];
          final byCategory = <String, List<MenuItem>>{};
          for (final item in items) {
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              if (_myItems.isNotEmpty) _myItemsSection(text),
              for (final category in byCategory.keys) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(category, style: text.titleLarge),
                ),
                ...byCategory[category]!.map((item) => _MenuRow(
                      item: item,
                      onTap: () => showItemDetailSheet(
                        context,
                        widget.args.restaurant,
                        item,
                        onAdd: _addItem,
                      ),
                    )),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_count == 0
                ? 'Done'
                : 'Done · $_count item${_count > 1 ? 's' : ''} · '
                    '${_subtotal.toStringAsFixed(1)} TND'),
          ),
        ),
      ),
    );
  }

  Widget _myItemsSection(TextTheme text) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your items', style: text.titleMedium),
          const SizedBox(height: 8),
          ..._myItems.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('${e.value.quantity}×',
                        style: AppTypography.mono(
                            fontSize: 13, color: context.colors.inkSoft)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(e.value.name, style: text.bodyLarge)),
                    Text('${e.value.lineTotal.toStringAsFixed(1)} TND',
                        style: AppTypography.mono(fontSize: 12)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _removeAt(e.key),
                      icon: Icon(Icons.close_rounded,
                          size: 18, color: context.colors.inkSoft),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.onTap});

  final MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: item.isAvailable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: text.titleMedium),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(item.description,
                        style: text.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  Text('${item.priceTND.toStringAsFixed(1)} TND',
                      style: AppTypography.mono(
                          fontSize: 13, color: context.colors.ember)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: FoodImage.menuItem(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
