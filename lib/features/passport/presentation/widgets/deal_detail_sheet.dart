import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/neighborhood.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';

/// Deal Detail modal — shows the zone's reward and, once unlocked, its code.
///
/// [redemptionsUsed] comes from the user's order history (see [UserStats]); a
/// spent deal shows as spent rather than handing over a code checkout will
/// refuse.
void showDealDetailSheet(
  BuildContext context,
  PassportNeighborhood zone,
  int stamps, {
  int redemptionsUsed = 0,
}) {
  final deal = zone.deal;
  final earned = stamps >= zone.requiredStamps;
  final spent =
      !deal.isUnlimited && redemptionsUsed >= deal.maxRedemptions;
  final unlocked = earned && !spent;
  final remaining = (zone.requiredStamps - stamps).clamp(0, zone.requiredStamps);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    // Scroll-safe: on a short screen (unlocked deal = header + reward + code +
    // copy button) the column is taller than the default sheet, so it must be
    // able to scroll and be height-capped rather than overflow.
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final text = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Text(zone.iconEmoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(zone.name, style: text.titleLarge),
                        Text(zone.city, style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reward', style: text.bodySmall),
                    const SizedBox(height: 4),
                    Text(deal.description, style: text.titleMedium),
                    if (!deal.isUnlimited) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Used $redemptionsUsed of ${deal.maxRedemptions}',
                        style: AppTypography.mono(
                          fontSize: 11,
                          color: spent
                              ? context.colors.inkSoft
                              : context.colors.ember,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (unlocked)
                _UnlockedCode(code: deal.code)
              else if (spent)
                const _SpentDeal()
              else
                _LockedProgress(
                  stamps: stamps,
                  required: zone.requiredStamps,
                  remaining: remaining,
                ),
            ],
            ),
          ),
        ),
      );
    },
  );
}

class _UnlockedCode extends StatelessWidget {
  const _UnlockedCode({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: context.colors.eco, size: 18),
            const SizedBox(width: 6),
            // Expanded so the label wraps on a narrow screen instead of
            // overflowing the row.
            Expanded(
              child: Text('Unlocked — use this code at checkout',
                  style: text.bodyMedium
                      ?.copyWith(color: context.colors.eco)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: context.colors.eco.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: context.colors.eco.withValues(alpha: 0.4)),
          ),
          alignment: Alignment.center,
          child: Text(code,
              style: AppTypography.mono(fontSize: 24, color: context.colors.eco)
                  .copyWith(letterSpacing: 3)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
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
            style:
                TextButton.styleFrom(foregroundColor: context.colors.ink),
          ),
        ),
      ],
    );
  }
}

/// The stamps were collected and the reward already spent.
class _SpentDeal extends StatelessWidget {
  const _SpentDeal();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.line),
      ),
      child: Row(
        children: [
          Icon(Icons.task_alt_rounded,
              color: context.colors.inkSoft, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Reward claimed — thanks for exploring this zone.',
                style: text.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _LockedProgress extends StatelessWidget {
  const _LockedProgress({
    required this.stamps,
    required this.required,
    required this.remaining,
  });

  final int stamps;
  final int required;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$stamps of $required stamps', style: text.titleMedium),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: required == 0 ? 0 : stamps / required,
            minHeight: 10,
            backgroundColor: context.colors.surfaceHigh,
            valueColor:
                AlwaysStoppedAnimation<Color>(context.colors.ember),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Order $remaining more time${remaining == 1 ? '' : 's'} in this '
          'neighborhood to unlock the reward.',
          style: text.bodyMedium,
        ),
      ],
    );
  }
}
