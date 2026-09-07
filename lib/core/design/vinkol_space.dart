/// Vinkol spacing, radius and elevation geometry.
/// Source of truth: `.claude/design/04-tokens.md` §3–5.
library;

import 'package:flutter/material.dart';

import 'vinkol_color.dart';

/// 4pt scale. Replaces the old 2pt `Gap` ladder, which permitted every value and so enforced
/// nothing. Density is a design decision here: a delivery list should show 6–8 rows on a
/// standard phone, and whitespace that reduces that count is failing the user.
abstract final class VinkolSpace {
  static const none = 0.0;
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 40.0;
  static const huge2 = 48.0;
  static const huge3 = 64.0;

  /// Page horizontal margin. Identical on every screen — never tune it per screen.
  static const pageMargin = xl;

  /// Between major sections. Operational register uses [sectionGap]; the hero register uses
  /// [sectionGapHero]. Pick one per screen and hold it.
  static const sectionGap = 28.0;
  static const sectionGapHero = xxxl;

  static const cardPadding = lg;
  static const listRowGap = md;
  static const labelToField = sm;
  static const iconToLabel = sm;

  /// Clearance above a bottom-anchored primary action, before the safe-area inset.
  static const bottomActionGap = xxl;
}

/// Radius. **Direction A · Midnight: 12 / 18 / 24 / full** (D-07 supersedes D-01's
/// 4 / 8 / 12 / 20). Mirrors `:root { --r-sm; --r-md; --r-lg }` in
/// `prototype/public/app/css/app.css`.
///
/// Rules: one radius level per nesting depth; a child never gets a larger radius than its
/// parent; anything flush to a screen edge is [none]. Primary buttons are [full], not [sm] —
/// the pill is part of the Midnight look.
abstract final class VinkolRadius {
  static const none = 0.0;
  static const xs =
      4.0; // --r-xs: checkboxes and other controls that read as square
  static const sm = 12.0; // --r-sm: inputs, chips, small tiles, inner blocks
  static const md =
      18.0; // --r-md: list-row cards, record cards, quick-action tiles
  static const lg = 24.0; // --r-lg: cards, the saturated hero, sheets
  static const full = 999.0; // avatars, status pills, the pod, primary buttons

  static const brXs = BorderRadius.all(Radius.circular(xs));
  static const brSm = BorderRadius.all(Radius.circular(sm));
  static const brMd = BorderRadius.all(Radius.circular(md));
  static const brLg = BorderRadius.all(Radius.circular(lg));
  static const brFull = BorderRadius.all(Radius.circular(full));

  /// Sheets and modals: rounded at the top, square where they meet the screen edge.
  static const brSheet = BorderRadius.vertical(top: Radius.circular(lg));
}

/// Elevation. **e0 is the default and should cover most of the app** — a hairline border and
/// no shadow.
///
/// In dark, the primary register, there are no shadows at all: depth reads as surface
/// lightness (`canvas` -> `surface` -> `surfaceAlt` -> `surfaceStrong`) separated by a
/// `borderSubtle` hairline. A shadow on a near-black ground is invisible and only costs paint
/// time, so every level below returns empty there.
///
/// Light mode has exactly two, matching `--sh` and `--sh2` in the prototype. The rule in both
/// registers: prefer a border to a shadow, and never more than one lifted surface on screen.
abstract final class VinkolElevation {
  /// The default: no shadow. Separation comes from the border, which the caller draws.
  static const List<BoxShadow> e0 = <BoxShadow>[];

  /// `--sh`. Cards, rows and tiles resting on the canvas.
  static List<BoxShadow> e1(VinkolColors c) => c.isDark
      ? e0
      : <BoxShadow>[
          BoxShadow(
              color: c.shadowSoft, offset: const Offset(0, 1), blurRadius: 3),
        ];

  /// `--sh2`. The pod, bottom sheets and the address overlay — the one lifted surface.
  static List<BoxShadow> e2(VinkolColors c) => c.isDark
      ? e0
      : <BoxShadow>[
          BoxShadow(
            color: c.shadowLift,
            offset: const Offset(0, 14),
            blurRadius: 34,
            spreadRadius: -14,
          ),
        ];

  /// The e0 hairline. Use this instead of reaching for a shadow.
  static Border hairline(VinkolColors c) =>
      Border.fromBorderSide(BorderSide(color: c.borderSubtle));
}
