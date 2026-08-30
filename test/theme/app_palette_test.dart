import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/theme/app_palette.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';

/// WCAG 2.1 relative luminance.
double _luminance(Color c) {
  double channel(double v) {
    v = v / 255.0;
    return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
  }

  return 0.2126 * channel((c.r * 255).roundToDouble()) +
      0.7152 * channel((c.g * 255).roundToDouble()) +
      0.0722 * channel((c.b * 255).roundToDouble());
}

/// WCAG 2.1 contrast ratio between two opaque colours (1.0 – 21.0).
double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Contrast is the load-bearing property of the whole two-theme system: the
/// original brand orange was tuned against a near-black ground and silently
/// fails on cream, which is the entire reason [AppPalette.ember] and
/// [AppPalette.emberText] are separate roles.
///
/// These thresholds come from WCAG 2.1 AA:
///   * 4.5:1 — body text and any label under 18.66px bold / 24px regular
///   * 3.0:1 — large text, icons, and UI component boundaries
///
/// If someone re-tunes a colour later, this fails rather than shipping an
/// unreadable screen.
void main() {
  const palettes = {'light': AppPalette.light, 'dark': AppPalette.dark};

  for (final entry in palettes.entries) {
    final name = entry.key;
    final p = entry.value;

    group('$name palette', () {
      test('primary text clears AA on both grounds', () {
        expect(contrast(p.ink, p.background), greaterThanOrEqualTo(4.5));
        expect(contrast(p.ink, p.surface), greaterThanOrEqualTo(4.5));
      });

      test('secondary text clears AA — it carries real content, not decoration',
          () {
        expect(contrast(p.inkSoft, p.background), greaterThanOrEqualTo(4.5));
        expect(contrast(p.inkSoft, p.surface), greaterThanOrEqualTo(4.5));
      });

      test('emberText clears AA as small text on both grounds', () {
        expect(contrast(p.emberText, p.background), greaterThanOrEqualTo(4.5));
        expect(contrast(p.emberText, p.surface), greaterThanOrEqualTo(4.5));
      });

      test('a label on an ember fill clears AA', () {
        // AppTheme sets button labels to labelLarge (15px/w700), which is below
        // the large-text threshold — so this is the strict 4.5, not 3.0.
        expect(contrast(p.onEmber, p.ember), greaterThanOrEqualTo(4.5));
      });

      test('ember is distinguishable as a UI component on both grounds', () {
        expect(contrast(p.ember, p.background), greaterThanOrEqualTo(3.0));
        expect(contrast(p.ember, p.surface), greaterThanOrEqualTo(3.0));
      });

      test('semantic colours read against their own ground', () {
        expect(contrast(p.eco, p.background), greaterThanOrEqualTo(4.5));
        expect(contrast(p.error, p.background), greaterThanOrEqualTo(4.5));
        // Stars are graphics, not text.
        expect(contrast(p.star, p.background), greaterThanOrEqualTo(3.0));
      });

      test('text on a soft tint clears AA', () {
        expect(contrast(p.emberText, p.emberSoft), greaterThanOrEqualTo(4.5));
        expect(contrast(p.eco, p.ecoSoft), greaterThanOrEqualTo(4.5));
      });

      test('surfaces are distinguishable from the ground', () {
        // A hairline needs to be visible without being a rule.
        expect(contrast(p.line, p.background), greaterThan(1.05));
      });
    });
  }

  group('theme wiring', () {
    // Asserted through a real tree rather than off the ThemeData getter: the
    // contract that matters is that `context.colors` resolves inside a widget,
    // and building a theme outside a pump makes google_fonts throw on the
    // missing font cache rather than telling us anything about the palette.
    Future<AppPalette> resolve(WidgetTester tester, ThemeData theme) async {
      late AppPalette seen;
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Builder(builder: (context) {
          seen = context.colors;
          return const SizedBox.shrink();
        }),
      ));
      return seen;
    }

    testWidgets('context.colors resolves the light palette', (tester) async {
      expect(await resolve(tester, AppTheme.light), same(AppPalette.light));
    });

    testWidgets('context.colors resolves the dark palette', (tester) async {
      expect(await resolve(tester, AppTheme.dark), same(AppPalette.dark));
    });

    // One pump per test: pumping both themes in a single tester leaves
    // google_fonts' in-flight font request pending across the swap.
    testWidgets('the light theme reports light brightness', (tester) async {
      expect(
          (await resolve(tester, AppTheme.light)).brightness, Brightness.light);
    });

    testWidgets('the dark theme reports dark brightness', (tester) async {
      expect(
          (await resolve(tester, AppTheme.dark)).brightness, Brightness.dark);
    });

    test('the two palettes are actually different', () {
      expect(AppPalette.light.background,
          isNot(equals(AppPalette.dark.background)));
      expect(AppPalette.light.isDark, isFalse);
      expect(AppPalette.dark.isDark, isTrue);
    });

    test('lerp snaps brightness rather than reporting a state neither is in',
        () {
      final quarter = AppPalette.light.lerp(AppPalette.dark, 0.25);
      final threeQuarter = AppPalette.light.lerp(AppPalette.dark, 0.75);
      expect(quarter.brightness, Brightness.light);
      expect(threeQuarter.brightness, Brightness.dark);
    });

    test('the ambient glow is inert in light mode', () {
      // AppBackdrop paints it unconditionally; light mode relies on the glow
      // token being transparent rather than on a branch in the widget.
      expect(AppPalette.light.glow.a, 0);
    });
  });
}
