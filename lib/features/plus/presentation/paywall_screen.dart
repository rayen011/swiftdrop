import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/plus_config.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/plus_plan.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/app_backdrop.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'widgets/plan_tile.dart';

/// The SwiftDrop Plus paywall.
///
/// The purchase is a stub — [AuthRepository.activatePlus] just writes an expiry.
/// Nothing is charged, which is why this screen says so plainly instead of
/// showing a store trust badge it hasn't earned.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  PlusPlan _selected = PlusConfig.defaultPlan;
  bool _purchasing = false;

  Future<void> _purchase() async {
    final uid = context.read<AuthCubit>().state.user?.uid;
    if (uid == null || _purchasing) return;

    setState(() => _purchasing = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await sl<AuthRepository>()
          .activatePlus(uid: uid, plan: _selected);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(_selected.hasTrial
              ? context.l10n.trialStarted
              : context.l10n.plusActivated),
        ),
      );
      router.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _purchasing = false);
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.plusFailed('$e'))),
      );
    }
  }

  String _ctaLabel(AppLocalizations l10n) => _selected.hasTrial
      ? l10n.tryTrial(_selected.trial.inDays)
      : l10n.getPlus(_selected.priceTND.toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onRestore: _purchasing ? null : _purchase),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    const _Hero(),
                    const SizedBox(height: 24),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: text.displayLarge,
                        children: [
                          // Brand name stays untranslated; the tagline doesn't.
                          const TextSpan(text: 'SwiftDrop Plus\n'),
                          TextSpan(
                            text: context.l10n.plusNoLimits,
                            style:
                                TextStyle(color: context.colors.emberText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    ...plusPerks(context.l10n).map((p) => _PerkRow(perk: p)),
                    const SizedBox(height: 24),
                    _PlanRow(
                      selected: _selected,
                      onSelect: (p) => setState(() => _selected = p),
                    ),
                    const SizedBox(height: 16),
                    const _TestPurchaseNote(),
                  ],
                ),
              ),
              _Footer(
                label: _ctaLabel(context.l10n),
                subtitle: _renewalCopy(context.l10n),
                purchasing: _purchasing,
                onPurchase: _purchasing ? null : _purchase,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _renewalCopy(AppLocalizations l10n) {
    final price = _selected.priceTND.toStringAsFixed(2);
    if (_selected.hasTrial) {
      return l10n.renewalTrial(
          _selected.trial.inDays, price, _selected.period.inDays);
    }
    return l10n.renewalPlain(price, _selected.period.inDays);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onRestore});
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          AppCircleButton(
            icon: Icons.close_rounded,
            size: 38,
            tooltip: 'Close',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          TextButton(
            onPressed: onRestore,
            child: Text(context.l10n.restore),
          ),
        ],
      ),
    );
  }
}

/// Stands in for the reference's screenshot collage: an ember-lit badge over the
/// ambient glow. No bundled artwork, so this is drawn rather than shipped.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            gradient: context.colors.cta,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: context.colors.emberDeep.withValues(alpha: 0.5),
                blurRadius: 44,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(Icons.bolt_rounded,
              size: 58, color: context.colors.onEmber),
        ),
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  const _PerkRow({required this.perk});
  final PlusPerk perk;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.colors.ember.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded,
                size: 14, color: context.colors.ember),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(perk.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(perk.subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.selected, required this.onSelect});

  final PlusPlan selected;
  final void Function(PlusPlan) onSelect;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final plan in PlusConfig.plans) ...[
            Expanded(
              child: PlanTile(
                plan: plan,
                selected: plan.id == selected.id,
                onTap: () => onSelect(plan),
              ),
            ),
            if (plan != PlusConfig.plans.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

/// Deliberately not a store trust badge. The reference shows "Secured with App
/// Store"; nothing here is secured or charged, and implying otherwise would
/// mislead a real user into thinking they had paid.
class _TestPurchaseNote extends StatelessWidget {
  const _TestPurchaseNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.science_outlined,
            size: 14, color: context.colors.inkSoft),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            context.l10n.testPurchaseNote,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.label,
    required this.subtitle,
    required this.purchasing,
    required this.onPurchase,
  });

  final String label;
  final String subtitle;
  final bool purchasing;
  final VoidCallback? onPurchase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPrimaryButton(
            onPressed: onPurchase,
            child: purchasing
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: context.colors.onEmber),
                  )
                : Text(label),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.termsPrivacy,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: context.colors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
