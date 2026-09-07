import 'package:flutter/material.dart';

/// Vinkol color tokens — **Direction A · Midnight** (decision D-07).
///
/// Source of truth: `prototype/public/app/css/app.css`. Every constant below carries the CSS
/// custom property it mirrors; the two files must change together in the same commit
/// (`.claude/design/09-prototype.md`). `.claude/design/04-tokens.md` §1 holds the verified
/// contrast ratios.
///
/// Midnight is dark-first: depth reads as surface *lightness*, not shadow, and exactly one
/// saturated blue object appears per screen — always the live thing. Light mode is a full
/// peer, not a tint.
///
/// These raw ramps are the only place in the app allowed to hold color literals. Screens read
/// semantic colors from [VinkolColors] via `context.vinkol`, never from here directly — the
/// ramp has no light/dark awareness.
abstract final class VinkolPalette {
  // ---------------------------------------------------------------------------------------
  // Brand ramp. 500 is the existing Vinkol blue and must never change (02-do-not-lose.md).
  // Midnight lifts the dark-mode accent to `darkAccent` below; the ramp survives for tints,
  // focus rings and the legacy AppColors shim.
  // ---------------------------------------------------------------------------------------
  static const brand50 = Color(0xFFEDF5FE);
  static const brand100 = Color(0xFFD3E7FD);
  static const brand200 = Color(0xFFA8CEFA);
  static const brand300 =
      Color(0xFF74B0F5); // dark-mode text/icon, 8.47:1 on canvas
  static const brand400 = Color(0xFF3B90EC); // dark-mode fill, 5.83:1 on canvas
  static const brand500 = Color(0xFF0E74D8); // the brand. 4.66:1 on white
  static const brand600 = Color(0xFF0B5EB4); // brand text on white, 6.41:1
  static const brand700 = Color(0xFF0A4C92); // focus rings, 8.53:1
  static const brand800 = Color(0xFF0B3D73);
  static const brand900 = Color(0xFF0C2F56);
  static const brand950 = Color(0xFF081E38);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // ---------------------------------------------------------------------------------------
  // Dark register — app.css `[data-theme='dark']`. The primary register.
  // Surfaces ascend in lightness: bg -> surf -> surf2 -> surf3, separated by a hairline.
  // ---------------------------------------------------------------------------------------
  static const darkBg = Color(0xFF0B0B0D); // --bg
  static const darkSurface = Color(0xFF16181C); // --surf
  static const darkSurfaceAlt = Color(0xFF1F2127); // --surf2
  static const darkSurfaceStrong = Color(0xFF262930); // --surf3
  static const darkLine = Color(0xFF282B32); // --line
  static const darkLine2 = Color(0xFF34383F); // --line2

  static const darkText = white; // --txt
  static const darkText2 = Color(0xFF99A1AE); // --txt2
  static const darkText3 = Color(0xFF676E79); // --txt3

  static const darkAccent = Color(0xFF2E8BEF); // --acc
  static const darkAccentDeep = brand500; // --acc-deep #0e74d8
  static const darkAccentDim =
      Color(0x242E8BEF); // --acc-dim  rgba(46,139,239,.14)
  static const darkAccentRing =
      Color(0x332E8BEF); // --acc-ring rgba(46,139,239,.20)
  static const darkAccentHalo =
      Color(0x2E2E8BEF); // --acc-halo rgba(46,139,239,.18)

  static const darkOk = Color(0xFF34C77B); // --ok
  static const darkOkDim = Color(0x2134C77B); // --ok-dim   rgba(52,199,123,.13)
  static const darkWarn = Color(0xFFF5A524); // --warn
  static const darkWarnDim =
      Color(0x24F5A524); // --warn-dim rgba(245,165,36,.14)
  static const darkBad = Color(0xFFF2545B); // --bad
  static const darkBadDim = Color(0x24F2545B); // --bad-dim  rgba(242,84,91,.14)

  static const darkMapGround = Color(0xFF101215); // --map-ground
  static const darkMapRoad = Color(0xFF20242A); // --map-road
  static const darkMapWater = Color(0xFF0C1319); // --map-water

  static const darkPod = Color(0xFF16181C); // --pod
  static const darkPodLine = Color(0xFF2C3038); // --pod-line
  static const darkPodText = Color(0xFF808894); // --pod-txt

  /// Batch-order hues, tuned for contrast on the dark ground. Mirrors `--o1`..`--o5`, which in
  /// turn replace the ad-hoc `_orderColors` list in `multi_map_with_quote_screen.dart`.
  static const darkOrderHues = <Color>[
    Color(0xFF7C74FF),
    Color(0xFF26C6AD),
    Color(0xFFFF7B7B),
    Color(0xFFFFB84D),
    Color(0xFF4FD6B8),
  ];

  // ---------------------------------------------------------------------------------------
  // Light register — app.css `[data-theme='light']`. A peer, not a tint: surf2/surf3 recede
  // below the white surface here, where in dark they rise above it.
  // ---------------------------------------------------------------------------------------
  static const lightBg = Color(0xFFF2F4F7); // --bg
  static const lightSurface = white; // --surf
  static const lightSurfaceAlt = Color(0xFFF5F7FA); // --surf2
  static const lightSurfaceStrong = Color(0xFFE9EDF2); // --surf3
  static const lightLine = Color(0xFFE3E8EE); // --line
  static const lightLine2 = Color(0xFFD3DAE3); // --line2

  static const lightText = Color(0xFF0F1419); // --txt
  static const lightText2 = Color(0xFF5A6472); // --txt2
  static const lightText3 = Color(0xFF8B95A3); // --txt3

  static const lightAccent = brand500; // --acc      #0e74d8
  static const lightAccentDeep = brand700; // --acc-deep #0a4c92
  static const lightAccentDim = Color(0xFFE8F1FD); // --acc-dim  (opaque here)
  static const lightAccentRing =
      Color(0x380E74D8); // --acc-ring rgba(14,116,216,.22)
  static const lightAccentHalo =
      Color(0x290E74D8); // --acc-halo rgba(14,116,216,.16)

  static const lightOk = Color(0xFF0A6B4A); // --ok      6.53:1 on white
  static const lightOkDim = Color(0xFFE6F5EF); // --ok-dim
  static const lightWarn = Color(0xFF8A5200); // --warn    6.39:1 on white
  static const lightWarnDim = Color(0xFFFDF2DF); // --warn-dim
  static const lightBad = Color(0xFFC4362B); // --bad     5.37:1 on white
  static const lightBadDim = Color(0xFFFDECEB); // --bad-dim

  static const lightMapGround = Color(0xFFE6EBF1); // --map-ground
  static const lightMapRoad = white; // --map-road
  static const lightMapWater = Color(0xFFD5E2EC); // --map-water

  /// The pod stays dark in light mode — it is the one constant object across both themes
  /// (D-08, 02-do-not-lose.md #2).
  static const lightPod = Color(0xFF14181E); // --pod
  static const lightPodLine =
      Color(0x1AFFFFFF); // --pod-line rgba(255,255,255,.1)
  static const lightPodText = Color(0xFF8B95A3); // --pod-txt

  static const lightOrderHues = <Color>[
    Color(0xFF5B52E0),
    Color(0xFF0F8F7C),
    Color(0xFFD34848),
    Color(0xFFA86A00),
    Color(0xFF1F9C85),
  ];

  // ---------------------------------------------------------------------------------------
  // Solid state fills. Not in app.css — the prototype never renders a solid success or
  // warning surface — but a filled success button needs one, and `text` is not usable as a
  // `fill` (04-tokens.md §1). `warningFill` cannot carry white text at 2.13:1; put
  // [lightText] on it or use the ground+text pair instead.
  // ---------------------------------------------------------------------------------------
  static const successFill = Color(0xFF0E8A5F); // 4.36:1 with white
  static const warningFill =
      Color(0xFFF0A202); // 2.13:1 with white — never white text
  static const dangerFill = Color(0xFFD93B2E); // 4.55:1 with white

  // ---------------------------------------------------------------------------------------
  // Shadow tints, pre-multiplied so no call site needs withOpacity. Light mode only.
  // ---------------------------------------------------------------------------------------
  static const shadowSoft = Color(0x0F101828); // rgba(16,24,40,.06) — --sh
  static const shadowLift = Color(0x4D101828); // rgba(16,24,40,.30) — --sh2
}

/// The delivery states the product can actually be in.
///
/// This is the **closed set of six** from `delivery_item.dart` (decision D-10). Nothing else
/// exists; a status the backend cannot return is a status the app must not draw.
///
/// Status always renders as a triple — label + shape + color, in that priority order
/// (D-05). [VinkolStatusStyle] carries all three so no call site can render color alone.
/// `cancelled` is deliberately neutral: cancellation is an outcome, not an error.
enum VinkolStatus {
  pending,
  withRider,
  withShopper,
  delivered,
  cancelled,
  unattended,
}

/// The shape half of the status triple. Rendering lives in the status component; this names
/// the intent so it survives grayscale and screen readers.
/// Six statuses, six **distinct** shapes.
///
/// This is what makes D-05 mean anything: the shape alone has to identify the status in a
/// greyscale screenshot, to a colourblind user, and in a screen reader's reading of the
/// label. Two statuses sharing a shape would leave colour doing the work.
enum VinkolStatusShape {
  /// Half-filled circle — waiting on someone else.
  halfFilled,

  /// Open ring, pulsing — in motion right now.
  pulsingRing,

  /// Filled ring with a hole — held, but not moving.
  donut,

  /// Filled circle with a tick — finished well.
  filledTick,

  /// Hollow circle with a slash — stopped, not failed.
  hollowSlash,

  /// Filled circle with an exclamation — needs attention.
  filledAlert,
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
///
/// Field names track app.css's custom properties rather than Material's vocabulary, so the
/// two token layers can be diffed by eye when either changes.
@immutable
class VinkolColors extends ThemeExtension<VinkolColors> {
  const VinkolColors({
    required this.brand,
    required this.brandDeep,
    required this.brandSubtle,
    required this.brandRing,
    required this.brandHalo,
    required this.onBrand,
    required this.textBrand,
    required this.canvas,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceStrong,
    required this.surfaceInverse,
    required this.borderSubtle,
    required this.borderStrong,
    required this.focusRing,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
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
    required this.mapGround,
    required this.mapRoad,
    required this.mapWater,
    required this.podSurface,
    required this.podBorder,
    required this.podText,
    required this.podOn,
    required this.orderHues,
    required this.shadowSoft,
    required this.shadowLift,
    required this.isDark,
  });

  /// The saturated blue. **One object per screen may wear it**, and it is always the live
  /// thing — the open order, the balance, the earned reward (D-07).
  final Color brand;

  /// The deep end of the brand gradient on the saturated hero, and the pressed state of
  /// [brand].
  final Color brandDeep;

  /// The quiet brand tint: selected rows, accent icon wells, info grounds.
  final Color brandSubtle;

  /// Translucent ring around a live node on the progress track.
  final Color brandRing;

  /// Translucent halo behind a focused input, the current-location dot and the active
  /// reward stop.
  final Color brandHalo;

  final Color onBrand;

  /// Brand-colored *text* and links. On light this is the accent itself (6.41:1 territory);
  /// on dark it is the lifted accent, which reads at 8.47:1 on the canvas.
  final Color textBrand;

  final Color canvas;

  /// The default card and row ground.
  final Color surface;

  /// One step off [surface]: pressed rows, icon wells, field fills. Rises above [surface] in
  /// dark and recedes below it in light — the same role, opposite direction.
  final Color surfaceAlt;

  /// Two steps off [surface]: switch tracks, counters, the deepest inert block.
  final Color surfaceStrong;

  final Color surfaceInverse;

  /// The hairline. Midnight separates surfaces with this, not with a shadow.
  final Color borderSubtle;

  /// The stronger rule: dotted route paths, inactive track segments, drag handles.
  final Color borderStrong;

  final Color focusRing;

  final Color textPrimary;
  final Color textSecondary;

  /// Also the disabled text color — app.css disables with `--txt3`, so there is no separate
  /// disabled token to drift out of sync.
  final Color textTertiary;

  final Color textInverse;

  final Color success;
  final Color successFill;
  final Color successGround;
  final Color warning;

  /// 2.13:1 against white — put [textPrimary] on it, or prefer the ground+text pair.
  final Color warningFill;
  final Color warningGround;
  final Color danger;
  final Color dangerFill;
  final Color dangerGround;
  final Color info;
  final Color infoGround;

  final Color mapGround;
  final Color mapRoad;
  final Color mapWater;

  /// The pod stays dark in both themes (D-08).
  final Color podSurface;
  final Color podBorder;
  final Color podText;
  final Color podOn;

  /// Per-delivery hues for the batch flow, in order. Index with `i % orderHues.length`.
  final List<Color> orderHues;

  /// Light mode only — both are transparent in dark, where depth is surface lightness.
  final Color shadowSoft;
  final Color shadowLift;

  final bool isDark;

  static const dark = VinkolColors(
    brand: VinkolPalette.darkAccent,
    brandDeep: VinkolPalette.darkAccentDeep,
    brandSubtle: VinkolPalette.darkAccentDim,
    brandRing: VinkolPalette.darkAccentRing,
    brandHalo: VinkolPalette.darkAccentHalo,
    onBrand: VinkolPalette.white,
    textBrand: VinkolPalette.darkAccent,
    canvas: VinkolPalette.darkBg,
    surface: VinkolPalette.darkSurface,
    surfaceAlt: VinkolPalette.darkSurfaceAlt,
    surfaceStrong: VinkolPalette.darkSurfaceStrong,
    surfaceInverse: VinkolPalette.white,
    borderSubtle: VinkolPalette.darkLine,
    borderStrong: VinkolPalette.darkLine2,
    focusRing: VinkolPalette.darkAccent,
    textPrimary: VinkolPalette.darkText,
    textSecondary: VinkolPalette.darkText2,
    textTertiary: VinkolPalette.darkText3,
    textInverse: VinkolPalette.darkBg,
    success: VinkolPalette.darkOk,
    successFill: VinkolPalette.successFill,
    successGround: VinkolPalette.darkOkDim,
    warning: VinkolPalette.darkWarn,
    warningFill: VinkolPalette.warningFill,
    warningGround: VinkolPalette.darkWarnDim,
    danger: VinkolPalette.darkBad,
    dangerFill: VinkolPalette.dangerFill,
    dangerGround: VinkolPalette.darkBadDim,
    info: VinkolPalette.darkAccent,
    infoGround: VinkolPalette.darkAccentDim,
    mapGround: VinkolPalette.darkMapGround,
    mapRoad: VinkolPalette.darkMapRoad,
    mapWater: VinkolPalette.darkMapWater,
    podSurface: VinkolPalette.darkPod,
    podBorder: VinkolPalette.darkPodLine,
    podText: VinkolPalette.darkPodText,
    podOn: VinkolPalette.white,
    orderHues: VinkolPalette.darkOrderHues,
    // Dark carries no shadows: on a near-black ground they are invisible and cost paint time.
    shadowSoft: Colors.transparent,
    shadowLift: Colors.transparent,
    isDark: true,
  );

  static const light = VinkolColors(
    brand: VinkolPalette.lightAccent,
    brandDeep: VinkolPalette.lightAccentDeep,
    brandSubtle: VinkolPalette.lightAccentDim,
    brandRing: VinkolPalette.lightAccentRing,
    brandHalo: VinkolPalette.lightAccentHalo,
    onBrand: VinkolPalette.white,
    // brand500 is only 4.30:1 on the light canvas, so brand text takes the deeper step.
    textBrand: VinkolPalette.brand600,
    canvas: VinkolPalette.lightBg,
    surface: VinkolPalette.lightSurface,
    surfaceAlt: VinkolPalette.lightSurfaceAlt,
    surfaceStrong: VinkolPalette.lightSurfaceStrong,
    surfaceInverse: VinkolPalette.lightText,
    borderSubtle: VinkolPalette.lightLine,
    borderStrong: VinkolPalette.lightLine2,
    focusRing: VinkolPalette.brand700,
    textPrimary: VinkolPalette.lightText,
    textSecondary: VinkolPalette.lightText2,
    textTertiary: VinkolPalette.lightText3,
    textInverse: VinkolPalette.white,
    success: VinkolPalette.lightOk,
    successFill: VinkolPalette.successFill,
    successGround: VinkolPalette.lightOkDim,
    warning: VinkolPalette.lightWarn,
    warningFill: VinkolPalette.warningFill,
    warningGround: VinkolPalette.lightWarnDim,
    danger: VinkolPalette.lightBad,
    dangerFill: VinkolPalette.dangerFill,
    dangerGround: VinkolPalette.lightBadDim,
    info: VinkolPalette.brand600,
    infoGround: VinkolPalette.lightAccentDim,
    mapGround: VinkolPalette.lightMapGround,
    mapRoad: VinkolPalette.lightMapRoad,
    mapWater: VinkolPalette.lightMapWater,
    podSurface: VinkolPalette.lightPod,
    podBorder: VinkolPalette.lightPodLine,
    podText: VinkolPalette.lightPodText,
    podOn: VinkolPalette.white,
    orderHues: VinkolPalette.lightOrderHues,
    shadowSoft: VinkolPalette.shadowSoft,
    shadowLift: VinkolPalette.shadowLift,
    isDark: false,
  );

  /// The full triple for a status. Callers must render [VinkolStatusStyle.label] and
  /// [VinkolStatusStyle.shape], not just the color.
  VinkolStatusStyle statusStyle(VinkolStatus status) {
    switch (status) {
      case VinkolStatus.pending:
        return VinkolStatusStyle(
          label: 'Pending',
          shape: VinkolStatusShape.halfFilled,
          color: warning,
          ground: warningGround,
        );
      case VinkolStatus.withRider:
        return VinkolStatusStyle(
          label: 'With rider',
          shape: VinkolStatusShape.pulsingRing,
          color: brand,
          ground: brandSubtle,
        );
      case VinkolStatus.withShopper:
        // A donut, not the rider's pulsing ring: a shopper is gathering the order, which is
        // a different state from a package moving, and the two must be distinguishable
        // without colour.
        return VinkolStatusStyle(
          label: 'With shopper',
          shape: VinkolStatusShape.donut,
          color: brand,
          ground: brandSubtle,
        );
      case VinkolStatus.delivered:
        return VinkolStatusStyle(
          label: 'Delivered',
          shape: VinkolStatusShape.filledTick,
          color: success,
          ground: successGround,
        );
      case VinkolStatus.cancelled:
        // Neutral, not red. Cancellation is an outcome, not an error (D-05).
        return VinkolStatusStyle(
          label: 'Cancelled',
          shape: VinkolStatusShape.hollowSlash,
          color: textTertiary,
          ground: surfaceAlt,
        );
      case VinkolStatus.unattended:
        return VinkolStatusStyle(
          label: 'Unattended',
          shape: VinkolStatusShape.filledAlert,
          color: danger,
          ground: dangerGround,
        );
    }
  }

  /// Parses the raw `status` string the API returns. Returns null for anything outside the
  /// closed set rather than guessing — an unknown status is a backend change, not a colour.
  static VinkolStatus? parseStatus(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'pending':
        return VinkolStatus.pending;
      case 'with rider':
        return VinkolStatus.withRider;
      case 'with shopper':
        return VinkolStatus.withShopper;
      case 'delivered':
        return VinkolStatus.delivered;
      case 'cancelled':
        return VinkolStatus.cancelled;
      case 'unattended':
        return VinkolStatus.unattended;
      default:
        return null;
    }
  }

  @override
  VinkolColors copyWith(
      {Color? brand, Color? canvas, Color? surface, Color? textPrimary}) {
    return VinkolColors(
      brand: brand ?? this.brand,
      brandDeep: brandDeep,
      brandSubtle: brandSubtle,
      brandRing: brandRing,
      brandHalo: brandHalo,
      onBrand: onBrand,
      textBrand: textBrand,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt,
      surfaceStrong: surfaceStrong,
      surfaceInverse: surfaceInverse,
      borderSubtle: borderSubtle,
      borderStrong: borderStrong,
      focusRing: focusRing,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      textInverse: textInverse,
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
      mapGround: mapGround,
      mapRoad: mapRoad,
      mapWater: mapWater,
      podSurface: podSurface,
      podBorder: podBorder,
      podText: podText,
      podOn: podOn,
      orderHues: orderHues,
      shadowSoft: shadowSoft,
      shadowLift: shadowLift,
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
  /// The active Vinkol semantic palette. Falls back to dark rather than throwing — dark is
  /// the primary register, so a widget rendered outside the app theme (a test, a preview)
  /// still paints the product's default look.
  VinkolColors get vinkol =>
      Theme.of(this).extension<VinkolColors>() ?? VinkolColors.dark;
}
