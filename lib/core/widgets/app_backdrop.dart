import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Paints the ambient bloom behind a page.
///
/// Large flat dark areas look dead; two offset radials read as light falling
/// from the top of the screen and give the dark theme its depth. In light mode
/// the palette's glow is fully transparent, so both gradients render as nothing
/// and this collapses to a plain background fill — no branch needed here.
///
/// Purely decorative: it sits under [child] and never intercepts input.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(color: c.background),
              child: DecoratedBox(
                decoration:
                    BoxDecoration(gradient: c.ambientGlowSecondary),
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: c.ambientGlow),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
