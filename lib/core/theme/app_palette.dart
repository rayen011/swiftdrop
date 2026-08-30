import 'package:flutter/material.dart';

/// Every colour in SwiftDrop, resolved from the active theme.
///
/// This replaces the old `AppColors` constants. A `const Color` cannot respond
/// to a theme, so as long as widgets referenced them directly the app could only
/// ever have one appearance. Tokens are read through [BuildContext.colors]:
///
/// ```dart
/// final c = context.colors;
/// Container(color: c.surface, child: Text('...', style: TextStyle(color: c.ink)));
/// ```
///
/// ## The two embers
///
/// [ember] and [emberText] are not a light/dark pair — they are two *roles*, and
/// both exist in both themes. The brand orange `#FF8A3D` was tuned against a
/// near-black ground; on the light theme's cream it measures 2.4:1 against
/// [background], which fails WCAG AA for text by a wide margin. So:
///
///   * [ember]     paints fills, icons, indicators and graphics — and carries
///                 an [onEmber] label. Light mode deepens it to `#D24405` so a
///                 15px/w700 button label clears 4.5:1, not merely the 3:1
///                 large-text threshold.
///   * [emberText] paints any ember-*coloured word* sitting on [background],
///                 [surface] or [emberSoft].
///
/// In dark mode the brand orange stays exactly as it was (8.1:1 on
/// [background]) and [emberText] is a lighter tint for optical balance, so the
/// app you have today is visually untouched.
///
/// Every ratio above is asserted in `test/theme/app_palette_test.dart`, so
/// re-tuning a colour fails the suite rather than shipping an unreadable
/// screen.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.line,
    required this.ember,
    required this.emberText,
    required this.emberSoft,
    required this.emberDeep,
    required this.ink,
    required this.inkSoft,
    required this.eco,
    required this.ecoSoft,
    required this.star,
    required this.error,
    required this.onEmber,
    required this.shadow,
    required this.glow,
  });

  final Brightness brightness;

  /// Page ground. Warm cream in light, warm near-black in dark — never neutral
  /// grey, so it sits with the food photography rather than under it.
  final Color background;

  /// Cards, sheets, the nav bar. Lifts off [background].
  final Color surface;

  /// Chips, steppers, inset wells — one step further from [background].
  final Color surfaceHigh;

  /// Hairline borders and dividers.
  final Color line;

  /// Fills, icons, graphics, active indicators. Not for text on [background].
  final Color ember;

  /// Ember-coloured *text*. AA-safe on [background] and [surface].
  final Color emberText;

  /// Tinted ember wash for selected chips and highlight blocks.
  final Color emberSoft;

  /// Deep end of the ember ramp — gradient stops only.
  final Color emberDeep;

  /// Primary text.
  final Color ink;

  /// Secondary text, metadata, placeholder copy.
  final Color inkSoft;

  /// Eco / savings / success. Reserved so it keeps its meaning.
  final Color eco;

  /// Tinted eco wash.
  final Color ecoSoft;

  /// Rating stars.
  final Color star;

  /// Destructive actions and error states.
  final Color error;

  /// Text and icons on an [ember] fill.
  ///
  /// Not white in both themes. White on the dark theme's `#FF8A3D` measures
  /// 2.3:1 — the existing app's primary button has always failed here. Dark
  /// warm ink on that same orange measures 7.8:1 and is the look the reference
  /// apps use for a bright fill anyway.
  final Color onEmber;

  /// Card and nav-bar drop shadow. Much softer in light mode — a dark-mode
  /// shadow on cream reads as dirt rather than elevation.
  final Color shadow;

  /// Ambient bloom painted behind a page by `AppBackdrop`. Transparent in light
  /// mode: the glow exists to keep large *dark* areas from going flat, and on
  /// cream it only muddies the ground.
  final Color glow;

  bool get isDark => brightness == Brightness.dark;

  // ---------------------------------------------------------------- palettes

  /// Light — the default. Cream ground, white cards, deepened ember.
  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFFBF7F2),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF5EFE7),
    line: Color(0xFFECE2D7),
    ember: Color(0xFFD24405),
    emberText: Color(0xFFA83A07),
    emberSoft: Color(0xFFFFEEE0),
    emberDeep: Color(0xFFA82F04),
    ink: Color(0xFF1A1512),
    inkSoft: Color(0xFF7C6E65),
    eco: Color(0xFF166B42),
    ecoSoft: Color(0xFFE3F3EA),
    star: Color(0xFFC77A05),
    error: Color(0xFFC0392B),
    onEmber: Color(0xFFFFFFFF),
    shadow: Color(0x141A1512),
    glow: Color(0x00000000),
  );

  /// Dark — the existing "warm dark + ember" identity, unchanged in feel.
  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF141110),
    surface: Color(0xFF1E1917),
    surfaceHigh: Color(0xFF2B2421),
    line: Color(0xFF302825),
    ember: Color(0xFFFF8A3D),
    emberText: Color(0xFFFFA469),
    emberSoft: Color(0xFF3A2416),
    emberDeep: Color(0xFFE85D04),
    ink: Color(0xFFF8F3EF),
    inkSoft: Color(0xFF9C8D84),
    eco: Color(0xFF3DDC84),
    ecoSoft: Color(0xFF12291C),
    star: Color(0xFFFFC542),
    error: Color(0xFFFF5A5A),
    onEmber: Color(0xFF241005),
    shadow: Color(0x66000000),
    glow: Color(0xFF6B3A16),
  );

  // --------------------------------------------------------------- gradients

  /// Primary call-to-action ramp. Used by the hero banner CTA and nothing else —
  /// ordinary buttons are a flat [ember] fill.
  LinearGradient get cta => LinearGradient(
        colors: [ember, emberDeep],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Hero promo banner wash (group order, Plus, passport deals).
  LinearGradient get hero => LinearGradient(
        colors: isDark
            ? const [Color(0xFFB4470C), Color(0xFF7A2E06)]
            : const [Color(0xFFF27A17), Color(0xFFDC4C0B)],
        begin: const Alignment(-0.8, -1),
        end: const Alignment(0.8, 1),
      );

  /// Scrim over food photography so overlaid text stays legible. Always dark —
  /// it darkens the *photo*, not the page, so it does not flip with the theme.
  LinearGradient get imageScrim => const LinearGradient(
        colors: [Color(0x00000000), Color(0xCC120F0E)],
        begin: Alignment.center,
        end: Alignment.bottomCenter,
      );

  /// Ambient bloom, top-right. Renders as nothing in light mode ([glow] is
  /// transparent there), so `AppBackdrop` needs no branch of its own.
  RadialGradient get ambientGlow => RadialGradient(
        center: const Alignment(0.85, -0.85),
        radius: 1.1,
        colors: [glow.withValues(alpha: isDark ? 0.40 : 0), background.withValues(alpha: 0)],
      );

  /// Second, weaker bloom from the upper left.
  RadialGradient get ambientGlowSecondary => RadialGradient(
        center: const Alignment(-0.9, -0.55),
        radius: 0.9,
        colors: [glow.withValues(alpha: isDark ? 0.24 : 0), background.withValues(alpha: 0)],
      );

  /// The standard card lift. One definition so every card sits at one height.
  List<BoxShadow> get cardShadow => [
        BoxShadow(color: shadow, blurRadius: 18, offset: const Offset(0, 8)),
      ];

  /// A heavier lift for the floating nav bar and docked bars.
  List<BoxShadow> get barShadow => [
        BoxShadow(color: shadow, blurRadius: 26, offset: const Offset(0, -4)),
      ];

  /// Coloured glow under a primary CTA. Skipped in light mode, where a coloured
  /// shadow on cream reads as a printing error.
  List<BoxShadow> get emberGlow => [
        BoxShadow(
          color: ember.withValues(alpha: isDark ? 0.34 : 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // ------------------------------------------------------ ThemeExtension API

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? line,
    Color? ember,
    Color? emberText,
    Color? emberSoft,
    Color? emberDeep,
    Color? ink,
    Color? inkSoft,
    Color? eco,
    Color? ecoSoft,
    Color? star,
    Color? error,
    Color? onEmber,
    Color? shadow,
    Color? glow,
  }) =>
      AppPalette(
        brightness: brightness ?? this.brightness,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceHigh: surfaceHigh ?? this.surfaceHigh,
        line: line ?? this.line,
        ember: ember ?? this.ember,
        emberText: emberText ?? this.emberText,
        emberSoft: emberSoft ?? this.emberSoft,
        emberDeep: emberDeep ?? this.emberDeep,
        ink: ink ?? this.ink,
        inkSoft: inkSoft ?? this.inkSoft,
        eco: eco ?? this.eco,
        ecoSoft: ecoSoft ?? this.ecoSoft,
        star: star ?? this.star,
        error: error ?? this.error,
        onEmber: onEmber ?? this.onEmber,
        shadow: shadow ?? this.shadow,
        glow: glow ?? this.glow,
      );

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      // Brightness is discrete; snap at the midpoint rather than interpolating
      // so `isDark` never reports a state neither palette is in.
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      line: Color.lerp(line, other.line, t)!,
      ember: Color.lerp(ember, other.ember, t)!,
      emberText: Color.lerp(emberText, other.emberText, t)!,
      emberSoft: Color.lerp(emberSoft, other.emberSoft, t)!,
      emberDeep: Color.lerp(emberDeep, other.emberDeep, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      eco: Color.lerp(eco, other.eco, t)!,
      ecoSoft: Color.lerp(ecoSoft, other.ecoSoft, t)!,
      star: Color.lerp(star, other.star, t)!,
      error: Color.lerp(error, other.error, t)!,
      onEmber: Color.lerp(onEmber, other.onEmber, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

/// Reads the active [AppPalette]. Falls back to [AppPalette.dark] rather than
/// throwing, so a widget pumped in a bare `MaterialApp` in a test still renders.
extension AppPaletteX on BuildContext {
  AppPalette get colors =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
