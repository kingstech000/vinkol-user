import 'package:flutter/material.dart';

/// Vinkol color tokens. Source of truth: `.claude/design/04-tokens.md`.
///
/// These raw ramps are the only place in the app allowed to hold color literals.
/// Screens read semantic colors from [VinkolColors] via `context.vinkol`, never from here
/// directly — the ramp has no light/dark awareness.
abstract final class VinkolPalette {
  // Brand. 500 is the existing Vinkol blue and must never change (see 02-do-not-lose.md).
  static const brand50 = Color(0xFFEDF5FE);
  static const brand100 = Color(0xFFD3E7FD);
  static const brand200 = Color(0xFFA8CEFA);
  static const brand300 = Color(0xFF74B0F5); // dark-mode text/icon, 8.47:1 on canvas
  static const brand400 = Color(0xFF3B90EC); // dark-mode fill, 5.83:1 on canvas
  static const brand500 = Color(0xFF0E74D8); // the brand. 4.66:1 on white
  static const brand600 = Color(0xFF0B5EB4); // brand text on white, 6.41:1
  static const brand700 = Color(0xFF0A4C92); // focus rings, 8.53:1
  static const brand800 = Color(0xFF0B3D73);
  static const brand900 = Color(0xFF0C2F56);
  static const brand950 = Color(0xFF081E38);

  // Neutral, cooled to sit with the blue. Replaces every Colors.grey* in the app.
  static const white = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF4F6F8);
  static const neutral100 = Color(0xFFE9ECF0);
  static const neutral200 = Color(0xFFDCE0E6);
  static const neutral300 = Color(0xFFC3C9D2);
  static const neutral400 = Color(0xFF99A1AE);
  static const neutral500 = Color(0xFF6E7784); // 4.53:1 on white — smallest usable for text
  static const neutral600 = Color(0xFF545C68);
  static const neutral700 = Color(0xFF3D444E);
  static const neutral800 = Color(0xFF272C34);
  static const neutral900 = Color(0xFF171A20);
  static const neutral950 = Color(0xFF0D0F13);
  static const black = Color(0xFF000000);

  // State. `text` and `fill` differ deliberately — see the contrast table in 04-tokens.md.
  static const successText = Color(0xFF0A6B4A); // 6.53:1 on white, 5.86:1 on its ground
  static const successFill = Color(0xFF0E8A5F);
  static const successGround = Color(0xFFE7F6F0);
  static const successDark = Color(0xFF3DBA8C);

  static const warningText = Color(0xFF8A5200); // 6.39:1 on white
  static const warningFill = Color(0xFFF0A202); // 2.13:1 with white — never carries white text
  static const warningGround = Color(0xFFFEF4E0);
  static const warningDark = Color(0xFFFFB020);

  static const dangerText = Color(0xFFC4362B); // 5.37:1 on white
  static const dangerFill = Color(0xFFD93B2E);
  static const dangerGround = Color(0xFFFDECEA);
  static const dangerDark = Color(0xFFFF8A80);

  // Shadow tints, pre-multiplied so no call site needs withOpacity.
  static const shadow06 = Color(0x0F0D0F13);
  static const shadow18 = Color(0x2E0D0F13);
  static const shadow24 = Color(0x3D0D0F13);
}

/// The delivery, payment and verification states the product can be in.
///
/// Status is always rendered as a triple — label + shape + color, in that priority order
/// (decision D-05). [VinkolStatusStyle] carries all three so no call site can render color
/// alone. `cancelled` is deliberately neutral: cancellation is an outcome, not an error.
enum VinkolStatus {
  draft,
  awaitingPayment,
  findingRider,
  riderAssigned,
  atPickup,
  inTransit,
  delivered,
  cancelled,
  failed,
  refunded,
}

/// The shape half of the status triple. Rendering lives in the status component; this names
/// the intent so it survives grayscale and screen readers.
enum VinkolStatusShape {
  hollow,
  halfFilled,
  pulsingRing,
  filled,
  filledTick,
  hollowSlash,
  filledAlert,
  hollowArrow
}

class VinkolStatusStyle {
  const VinkolStatusStyle({
    required this.label,
    required this.shape,
    required this.color,
    required this.ground,
  });

  /// The primary signal. Never omit it in favour of the color.
  final String label;
  final VinkolStatusShape shape;
  final Color color;
  final Color ground;
}

/// Semantic colors, resolved for the active theme. Read with `context.vinkol`.
@immutable
class VinkolColors extends ThemeExtension<VinkolColors> {
  const VinkolColors({
    required this.brand,
    required this.brandHover,
    required this.brandPressed,
    required this.brandSubtle,
    required this.onBrand,
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceInverse,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.focusRing,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textInverse,
    required this.textBrand,
    required this.success,
    required this.successFill,
    required this.successGround,
    required this.warning,
    required this.warningFill,
    required this.warningGround,
    required this.danger,
    required this.dangerFill,
    required this.dangerGround,
    required this.info,
    required this.infoGround,
    required this.shadowE1,
    required this.shadowE2,
    required this.shadowE3,
    required this.isDark,
  });

  final Color brand;
  final Color brandHover;
  final Color brandPressed;
  final Color brandSubtle;
  final Color onBrand;

  final Color canvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color surfaceInverse;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color focusRing;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textInverse;

  /// Brand-colored *text*. Deliberately darker than [brand]: brand500 is only 4.30:1 on the
  /// canvas, so brand text uses the 600 step.
  final Color textBrand;

  final Color success;
  final Color successFill;
  final Color successGround;
  final Color warning;
  final Color warningFill;
  final Color warningGround;
  final Color danger;
  final Color dangerFill;
  final Color dangerGround;
  final Color info;
  final Color infoGround;

  final Color shadowE1;
  final Color shadowE2;
  final Color shadowE3;

  final bool isDark;

  static const light = VinkolColors(
    brand: VinkolPalette.brand500,
    brandHover: VinkolPalette.brand600,
    brandPressed: VinkolPalette.brand700,
    brandSubtle: VinkolPalette.brand50,
    onBrand: VinkolPalette.white,
    canvas: VinkolPalette.neutral50,
    surface: VinkolPalette.white,
    surfaceRaised: VinkolPalette.white,
    surfaceSunken: VinkolPalette.neutral100,
    surfaceInverse: VinkolPalette.neutral900,
    borderSubtle: VinkolPalette.neutral200,
    borderDefault: VinkolPalette.neutral300,
    borderStrong: VinkolPalette.neutral400,
    focusRing: VinkolPalette.brand700,
    textPrimary: VinkolPalette.neutral900,
    textSecondary: VinkolPalette.neutral600,
    textTertiary: VinkolPalette.neutral500,
    textDisabled: VinkolPalette.neutral400,
    textInverse: VinkolPalette.white,
    textBrand: VinkolPalette.brand600,
    success: VinkolPalette.successText,
    successFill: VinkolPalette.successFill,
    successGround: VinkolPalette.successGround,
    warning: VinkolPalette.warningText,
    warningFill: VinkolPalette.warningFill,
    warningGround: VinkolPalette.warningGround,
    danger: VinkolPalette.dangerText,
    dangerFill: VinkolPalette.dangerFill,
    dangerGround: VinkolPalette.dangerGround,
    info: VinkolPalette.brand600,
    infoGround: VinkolPalette.brand50,
    shadowE1: VinkolPalette.shadow06,
    shadowE2: VinkolPalette.shadow18,
    shadowE3: VinkolPalette.shadow24,
    isDark: false,
  );

  static const dark = VinkolColors(
    brand: VinkolPalette.brand400,
    brandHover: VinkolPalette.brand300,
    brandPressed: VinkolPalette.brand500,
    brandSubtle: VinkolPalette.brand900,
    onBrand: VinkolPalette.neutral950,
    canvas: VinkolPalette.neutral950,
    surface: VinkolPalette.neutral900,
    surfaceRaised: VinkolPalette.neutral800,
    surfaceSunken: VinkolPalette.black,
    surfaceInverse: VinkolPalette.white,
    borderSubtle: VinkolPalette.neutral800,
    borderDefault: VinkolPalette.neutral700,
    borderStrong: VinkolPalette.neutral600,
    focusRing: VinkolPalette.brand300,
    textPrimary: VinkolPalette.neutral100,
    textSecondary: VinkolPalette.neutral400,
    textTertiary: VinkolPalette.neutral500,
    textDisabled: VinkolPalette.neutral600,
    textInverse: VinkolPalette.neutral900,
    textBrand: VinkolPalette.brand300,
    success: VinkolPalette.successDark,
    successFill: VinkolPalette.successFill,
    successGround: Color(0xFF0B2A20),
    warning: VinkolPalette.warningDark,
    warningFill: VinkolPalette.warningFill,
    warningGround: Color(0xFF2E2005),
    danger: VinkolPalette.dangerDark,
    dangerFill: VinkolPalette.dangerFill,
    dangerGround: Color(0xFF2E1310),
    info: VinkolPalette.brand300,
    infoGround: VinkolPalette.brand950,
    shadowE1: VinkolPalette.black,
    shadowE2: VinkolPalette.black,
    shadowE3: VinkolPalette.black,
    isDark: true,
  );

  /// The full triple for a status. Callers must render [VinkolStatusStyle.label] and
  /// [VinkolStatusStyle.shape], not just the color.
  VinkolStatusStyle statusStyle(VinkolStatus status) {
    switch (status) {
      case VinkolStatus.draft:
        return VinkolStatusStyle(
            label: 'Draft',
            shape: VinkolStatusShape.hollow,
            color: textTertiary,
            ground: surfaceSunken);
      case VinkolStatus.awaitingPayment:
        return VinkolStatusStyle(
            label: 'Awaiting payment',
            shape: VinkolStatusShape.halfFilled,
            color: warning,
            ground: warningGround);
      case VinkolStatus.findingRider:
        return VinkolStatusStyle(
            label: 'Finding a rider',
            shape: VinkolStatusShape.pulsingRing,
            color: brand,
            ground: infoGround);
      case VinkolStatus.riderAssigned:
        return VinkolStatusStyle(
            label: 'Rider assigned',
            shape: VinkolStatusShape.filled,
            color: info,
            ground: infoGround);
      case VinkolStatus.atPickup:
        return VinkolStatusStyle(
            label: 'At pickup',
            shape: VinkolStatusShape.filledTick,
            color: info,
            ground: infoGround);
      case VinkolStatus.inTransit:
        return VinkolStatusStyle(
            label: 'In transit', shape: VinkolStatusShape.filled, color: brand, ground: infoGround);
      case VinkolStatus.delivered:
        return VinkolStatusStyle(
            label: 'Delivered',
            shape: VinkolStatusShape.filledTick,
            color: success,
            ground: successGround);
      case VinkolStatus.cancelled:
        // Neutral, not red. Cancellation is an outcome, not an error.
        return VinkolStatusStyle(
            label: 'Cancelled',
            shape: VinkolStatusShape.hollowSlash,
            color: textDisabled,
            ground: surfaceSunken);
      case VinkolStatus.failed:
        return VinkolStatusStyle(
            label: 'Failed',
            shape: VinkolStatusShape.filledAlert,
            color: danger,
            ground: dangerGround);
      case VinkolStatus.refunded:
        return VinkolStatusStyle(
            label: 'Refunded',
            shape: VinkolStatusShape.hollowArrow,
            color: textSecondary,
            ground: surfaceSunken);
    }
  }

  @override
  VinkolColors copyWith({Color? brand, Color? canvas, Color? surface, Color? textPrimary}) {
    return VinkolColors(
      brand: brand ?? this.brand,
      brandHover: brandHover,
      brandPressed: brandPressed,
      brandSubtle: brandSubtle,
      onBrand: onBrand,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised,
      surfaceSunken: surfaceSunken,
      surfaceInverse: surfaceInverse,
      borderSubtle: borderSubtle,
      borderDefault: borderDefault,
      borderStrong: borderStrong,
      focusRing: focusRing,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      textDisabled: textDisabled,
      textInverse: textInverse,
      textBrand: textBrand,
      success: success,
      successFill: successFill,
      successGround: successGround,
      warning: warning,
      warningFill: warningFill,
      warningGround: warningGround,
      danger: danger,
      dangerFill: dangerFill,
      dangerGround: dangerGround,
      info: info,
      infoGround: infoGround,
      shadowE1: shadowE1,
      shadowE2: shadowE2,
      shadowE3: shadowE3,
      isDark: isDark,
    );
  }

  @override
  VinkolColors lerp(ThemeExtension<VinkolColors>? other, double t) {
    // Theme changes are a discrete swap, not a crossfade; interpolating semantic colors
    // produces mid-transition values that pass no contrast check.
    if (other is! VinkolColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension VinkolColorsX on BuildContext {
  /// The active Vinkol semantic palette. Falls back to light rather than throwing, so a widget
  /// rendered outside the app theme (a test, a preview) still paints something legible.
  VinkolColors get vinkol => Theme.of(this).extension<VinkolColors>() ?? VinkolColors.light;
}
