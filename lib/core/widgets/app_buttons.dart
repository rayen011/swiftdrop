import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// The app's primary call-to-action: a full-width ember-gradient pill.
///
/// A gradient can't be expressed through [ElevatedButtonThemeData], so CTAs that
/// want the ramp use this instead of a plain [ElevatedButton]. Disabled falls
/// back to a flat elevated surface so it reads as inert rather than dimmed-brand.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.child,
    this.onPressed,
    this.height = 56,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled ? context.colors.cta : null,
        color: enabled ? null : context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: context.colors.emberDeep.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: SizedBox(
            height: height,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // scaleDown rather than ellipsis: a CTA truncated to
                // "Add to C…" is worse than one rendered a few points smaller.
                // On a narrow device (or at a large text scale) the whole label
                // shrinks proportionally and stays readable.
                //
                // NOTE: FittedBox hands `child` unbounded width, so a Row passed
                // in here must use MainAxisSize.min and must not contain
                // Flexible/Expanded.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: enabled
                          ? context.colors.onEmber
                          : context.colors.inkSoft,
                    ),
                    child: IconTheme(
                      data: IconThemeData(
                        color: enabled
                            ? context.colors.onEmber
                            : context.colors.inkSoft,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular icon button used for back / favourite / call affordances.
///
/// [filled] paints the ember ramp (the "+" on a card); otherwise it's a muted
/// translucent disc that sits over photography without hiding it.
class AppCircleButton extends StatelessWidget {
  const AppCircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.filled = false,
    this.iconColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool filled;
  final Color? iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        gradient: filled ? context.colors.cta : null,
        color: filled ? null : context.colors.surface.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: filled
            ? null
            : Border.all(color: context.colors.line.withValues(alpha: 0.8)),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: size * 0.45,
              color: iconColor ??
                  (filled ? context.colors.onEmber : context.colors.ink),
            ),
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
