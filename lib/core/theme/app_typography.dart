import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// SwiftDrop's type system.
///
///   Headings & body — DM Sans
///   Numerals        — DM Mono (prices, ETAs, distances, CO₂, timers)
///
/// Inter is gone. It and DM Sans are near-identical grotesques, so carrying both
/// bought a second font download and nothing else; DM Sans covers body text at
/// 400/500 perfectly well.
///
/// Display sizes are tracked tighter than before (-0.035em against the old
/// -0.02em). Tight display tracking is most of what separates a branded food app
/// from a default Material one — all three reference apps set headlines this way.
abstract final class AppTypography {
  /// Builds the text theme against [p] so every colour follows the active
  /// theme. Colours are still baked into the styles (rather than left null) so
  /// that a widget lifting a style out of the theme and using it off-tree —
  /// inside a `TextSpan`, say — still gets a legible colour.
  static TextTheme forPalette(AppPalette p) {
    TextStyle sans({
      required double size,
      required FontWeight weight,
      double tracking = 0,
      double height = 1.25,
      Color? color,
    }) =>
        GoogleFonts.dmSans(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: tracking,
          height: height,
          color: color ?? p.ink,
        );

    return TextTheme(
      // Display — the greeting, the delivered banner. Poster lines, not labels.
      displayLarge: sans(
          size: 34, weight: FontWeight.w800, tracking: -1.19, height: 1.05),
      headlineLarge: sans(
          size: 28, weight: FontWeight.w800, tracking: -0.98, height: 1.08),
      // Screen titles — store name, sheet headings.
      headlineMedium: sans(
          size: 22, weight: FontWeight.w800, tracking: -0.77, height: 1.12),
      // Section headings — "Near you in Lac 2".
      titleLarge:
          sans(size: 18, weight: FontWeight.w700, tracking: -0.45, height: 1.2),
      // Card titles, list-row names.
      titleMedium:
          sans(size: 15, weight: FontWeight.w700, tracking: -0.3, height: 1.25),
      titleSmall:
          sans(size: 13, weight: FontWeight.w700, tracking: -0.16, height: 1.3),

      bodyLarge: sans(size: 15, weight: FontWeight.w400, height: 1.45),
      bodyMedium:
          sans(size: 13.5, weight: FontWeight.w400, height: 1.45, color: p.inkSoft),
      bodySmall:
          sans(size: 12, weight: FontWeight.w400, height: 1.4, color: p.inkSoft),

      // Button labels. 15/w700 clears the WCAG large-text threshold, which is
      // what lets white sit on an `ember` fill — see AppPalette's class doc.
      labelLarge: sans(size: 15, weight: FontWeight.w700, tracking: -0.15),
      labelMedium:
          sans(size: 12, weight: FontWeight.w600, color: p.inkSoft, height: 1.3),
      // Uppercase eyebrows and tab labels — the one place tracking opens up.
      labelSmall: sans(
          size: 10.5, weight: FontWeight.w700, tracking: 0.6, color: p.inkSoft),
    );
  }

  /// DM Mono — prices, ETAs, distances, timers, CO₂ counters.
  ///
  /// [color] defaults to null so the style inherits from its surroundings; pass
  /// one only when the number needs to differ from the text around it. Figures
  /// are tabular so any column of prices lines up on the decimal.
  static TextStyle mono({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double letterSpacing = -0.2,
  }) =>
      GoogleFonts.dmMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
