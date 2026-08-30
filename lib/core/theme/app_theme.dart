import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_typography.dart';

/// Assembles both Material 3 themes from an [AppPalette].
///
/// One builder, two palettes — light and dark differ only in their token
/// values, never in their structure. If a component needs a per-theme branch,
/// that branch belongs in [AppPalette], not here.
abstract final class AppTheme {
  /// Chips, badges, meta pills, steppers, small inputs.
  static const double radiusControl = 9;

  /// Cards, list rows, dish tiles, text fields, buttons.
  static const double radiusCard = 15;

  /// Hero banners, bottom sheets, the nav bar, docked bars, modals.
  static const double radiusSurface = 22;

  /// Fully-rounded. Deliberately rare now — the CTA inside a hero banner, the
  /// location pill, avatars. Everything else uses [radiusCard], which is what
  /// gives the layout its hierarchy: three radii instead of one.
  static const double radiusPill = 999;

  static ThemeData get light => _build(AppPalette.light);
  static ThemeData get dark => _build(AppPalette.dark);

  static ThemeData _build(AppPalette p) {
    final text = AppTypography.forPalette(p);
    final isDark = p.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      scaffoldBackgroundColor: p.background,
      // The palette is the single source of colour; ColorScheme exists for the
      // Material widgets that read it directly (Switch, Slider, TextField…).
      colorScheme: ColorScheme(
        brightness: p.brightness,
        primary: p.ember,
        onPrimary: p.onEmber,
        secondary: p.eco,
        onSecondary: isDark ? const Color(0xFF06210F) : Colors.white,
        error: p.error,
        onError: Colors.white,
        surface: p.surface,
        onSurface: p.ink,
        surfaceContainerHighest: p.surfaceHigh,
        outline: p.line,
      ),
      extensions: [p],
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: p.ink,
        titleTextStyle: text.headlineMedium,
      ),

      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: p.line),
        ),
      ),

      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),

      // A flat ember fill with a white label. The label style is labelLarge
      // (15/w700) so it clears the WCAG large-text threshold — see AppPalette.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.ember,
          foregroundColor: p.onEmber,
          disabledBackgroundColor: p.surfaceHigh,
          disabledForegroundColor: p.inkSoft,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: p.line, width: 1.5),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
          ),
        ),
      ),

      // emberText, not ember: a text button is a *word*, so it takes the
      // AA-safe role.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.emberText,
          textStyle: text.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: text.bodyMedium,
        contentPadding:
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: BorderSide(color: p.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: BorderSide(color: p.ember, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: BorderSide(color: p.error),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceHigh,
        selectedColor: p.emberSoft,
        side: BorderSide.none,
        showCheckmark: false,
        labelStyle: text.labelMedium,
        secondaryLabelStyle: text.labelMedium?.copyWith(color: p.emberText),
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : p.inkSoft,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.ember : p.surfaceHigh,
        ),
        trackOutlineColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(radiusSurface + 4)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSurface),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surfaceHigh,
        contentTextStyle: text.bodyLarge,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: p.ember,
        thumbColor: p.ember,
        inactiveTrackColor: p.surfaceHigh,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.ember),
      iconTheme: IconThemeData(color: p.ink),
      listTileTheme: ListTileThemeData(
        iconColor: p.inkSoft,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodySmall,
      ),
    );
  }
}
