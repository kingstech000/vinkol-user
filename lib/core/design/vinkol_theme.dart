import 'package:flutter/material.dart';

import 'vinkol_color.dart';
import 'vinkol_space.dart';
import 'vinkol_type.dart';

/// Wires the Vinkol tokens into a real [ThemeData] for both brightnesses.
///
/// The app previously built its theme inline in `main.dart` and never referenced
/// `lib/core/theme/{light,dark}_theme.dart` at all, so `Theme.of(context)` returned Material
/// defaults everywhere. These replace that: `context.vinkol` resolves through the
/// [VinkolColors] extension attached here.
abstract final class VinkolTheme {
  static ThemeData light() => _build(VinkolColors.light, Brightness.light);
  static ThemeData dark() => _build(VinkolColors.dark, Brightness.dark);

  static ThemeData _build(VinkolColors v, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[v],
      scaffoldBackgroundColor: v.canvas,
      canvasColor: v.canvas,
      dividerColor: v.borderSubtle,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: v.brand,
        onPrimary: v.onBrand,
        secondary: v.brand,
        onSecondary: v.onBrand,
        error: v.dangerFill,
        onError: VinkolPalette.white,
        surface: v.surface,
        onSurface: v.textPrimary,
        surfaceContainerHighest: v.surfaceSunken,
        outline: v.borderDefault,
        outlineVariant: v.borderSubtle,
        shadow: v.shadowE2,
      ),
      textTheme: _textTheme(v),
      dividerTheme: DividerThemeData(color: v.borderSubtle, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: v.canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: v.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: VinkolType.h3.copyWith(color: v.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: v.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: VinkolRadius.brSheet),
        showDragHandle: true,
        dragHandleColor: v.borderDefault,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: v.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: VinkolRadius.brMd),
        titleTextStyle: VinkolType.h3.copyWith(color: v.textPrimary),
        contentTextStyle: VinkolType.body.copyWith(color: v.textSecondary),
      ),
      // e0 by default: a hairline border and no shadow.
      cardTheme: CardThemeData(
        color: v.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: VinkolRadius.brMd,
          side: BorderSide(color: v.borderSubtle),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: v.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: VinkolSpace.md,
          vertical: VinkolSpace.md,
        ),
        border: _inputBorder(v.borderDefault),
        enabledBorder: _inputBorder(v.borderDefault),
        focusedBorder: _inputBorder(v.focusRing, width: 2),
        errorBorder: _inputBorder(v.dangerFill),
        focusedErrorBorder: _inputBorder(v.dangerFill, width: 2),
        disabledBorder: _inputBorder(v.borderSubtle),
        hintStyle: VinkolType.body.copyWith(color: v.textTertiary),
        labelStyle: VinkolType.label.copyWith(color: v.textSecondary),
        errorStyle: VinkolType.bodyS.copyWith(color: v.danger),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: v.surfaceInverse,
        contentTextStyle: VinkolType.body.copyWith(color: v.textInverse),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: VinkolRadius.brSm),
        elevation: 0,
      ),
      // No bounce anywhere: the platform default page transition is replaced with a fade
      // through, matching VinkolMotion.emphasized in feel.
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) => OutlineInputBorder(
        borderRadius: VinkolRadius.brSm,
        borderSide: BorderSide(color: color, width: width),
      );

  /// Maps the Vinkol scale onto Material's slots so third-party and Material widgets inherit
  /// the right face and size. Colors come from [VinkolColors]; app code should prefer
  /// `VinkolType.*` directly over these slots.
  static TextTheme _textTheme(VinkolColors v) {
    final primary = v.textPrimary;
    final secondary = v.textSecondary;
    return TextTheme(
      displayLarge: VinkolType.displayL.copyWith(color: primary),
      displayMedium: VinkolType.displayS.copyWith(color: primary),
      headlineLarge: VinkolType.h1.copyWith(color: primary),
      headlineMedium: VinkolType.h2.copyWith(color: primary),
      headlineSmall: VinkolType.h3.copyWith(color: primary),
      titleLarge: VinkolType.h2.copyWith(color: primary),
      titleMedium: VinkolType.h3.copyWith(color: primary),
      titleSmall: VinkolType.h4.copyWith(color: primary),
      bodyLarge: VinkolType.bodyL.copyWith(color: primary),
      bodyMedium: VinkolType.body.copyWith(color: primary),
      bodySmall: VinkolType.bodyS.copyWith(color: secondary),
      labelLarge: VinkolType.button.copyWith(color: primary),
      labelMedium: VinkolType.label.copyWith(color: secondary),
      labelSmall: VinkolType.labelS.copyWith(color: secondary),
    );
  }
}
