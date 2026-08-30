import 'package:flutter/material.dart';

import '../../../../core/constants/plus_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/models/plus_plan.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';

/// One selectable plan on the paywall.
///
/// The badge overhangs the top edge, so the tile reserves headroom via
/// [badgeHeadroom] and the parent Row must give every tile the same height —
/// otherwise a tile without a badge sits taller than its neighbours.
class PlanTile extends StatelessWidget {
  const PlanTile({
    super.key,
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final PlusPlan plan;
  final bool selected;
  final VoidCallback onTap;

  static const double badgeHeadroom = 14;

  @override
  Widget build(BuildContext context) {
    final savings = plan.savingsPercentVersus(PlusConfig.anchor);
    final badge = plan.badgeText(context.l10n);

    return Semantics(
      selected: selected,
      button: true,
      label:
          '${plan.label(context.l10n)}, ${plan.priceTND.toStringAsFixed(2)} TND',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: badgeHeadroom),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.fromLTRB(10, 22, 10, 14),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? context.colors.ember : context.colors.line,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: context.colors.ember.withValues(alpha: 0.28),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      plan.label(context.l10n),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${plan.priceTND.toStringAsFixed(2)} TND',
                        style: AppTypography.mono(
                          fontSize: 15,
                          color: context.colors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.l10n
                            .perWeek(plan.pricePerWeekTND.toStringAsFixed(2)),
                        style: AppTypography.mono(
                          fontSize: 12,
                          color: selected
                              ? context.colors.ember
                              : context.colors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (badge != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(child: _Badge(text: badge, accent: selected)),
              ),
            if (savings != null)
              Positioned(
                top: 6,
                right: -4,
                child: _SavingsFlag(percent: savings),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.accent});

  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: accent ? context.colors.cta : null,
        color: accent ? null : context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent ? Colors.transparent : context.colors.line,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accent ? context.colors.onEmber : context.colors.ink,
          fontSize: 9,
          height: 1.15,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// The "-75% OFF" corner flag. Derived from the plan's real per-week price, so
/// it can't advertise a discount the plan doesn't actually give.
class _SavingsFlag extends StatelessWidget {
  const _SavingsFlag({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: context.colors.cta,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        context.l10n.percentOffBadge(percent),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.colors.onEmber,
          fontSize: 8,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
