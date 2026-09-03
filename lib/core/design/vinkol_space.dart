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

/// Four named steps plus full. Replaces the 13 ad-hoc values measured in the audit.
///
/// Rules: one radius level per nesting depth; a child never gets a larger radius than its
/// parent; anything flush to a screen edge is [none].
abstract final class VinkolRadius {
  static const none = 0.0;
  static const xs = 4.0; // badges, progress, small indicators
  static const sm = 8.0; // inputs, list rows, tiles, chips, small buttons
  static const md = 12.0; // cards, content blocks, images
  static const lg = 20.0; // sheets and modals — top corners only
  static const full = 999.0; // avatars, status pills, the pod

  static const brXs = BorderRadius.all(Radius.circular(xs));
  static const brSm = BorderRadius.all(Radius.circular(sm));
  static const brMd = BorderRadius.all(Radius.circular(md));
  static const brFull = BorderRadius.all(Radius.circular(full));

  /// Sheets and modals: rounded at the top, square where they meet the screen edge.
  static const brSheet = BorderRadius.vertical(top: Radius.circular(lg));
}

/// Elevation. **e0 is the default and should cover most of the app** — a hairline border and
/// no shadow. This is the clearest expression of the ratified direction (D-01, Quiet
/// Infrastructure), and it replaces the 29 files of hand-written shadows found in the audit.
///
/// At most one e2-or-above surface is visible at a time. In dark mode, elevation reads through
/// surface lightness rather than shadow, so these return empty there.
abstract final class VinkolElevation {
  /// The default: no shadow. Separation comes from the border, which the caller draws.
  static const List<BoxShadow> e0 = <BoxShadow>[];

  static List<BoxShadow> e1(VinkolColors c) => c.isDark
      ? const <BoxShadow>[]
      : <BoxShadow>[BoxShadow(color: c.shadowE1, offset: const Offset(0, 1), blurRadius: 2)];

  /// Sticky bottom bar, the pod, the map overlay panel.
  static List<BoxShadow> e2(VinkolColors c) => c.isDark
      ? const <BoxShadow>[]
      : <BoxShadow>[
          BoxShadow(
              color: c.shadowE2, offset: const Offset(0, 8), blurRadius: 24, spreadRadius: -8),
        ];

  /// Dialogs and menus.
  static List<BoxShadow> e3(VinkolColors c) => c.isDark
      ? const <BoxShadow>[]
      : <BoxShadow>[
          BoxShadow(
              color: c.shadowE3, offset: const Offset(0, 16), blurRadius: 40, spreadRadius: -12),
        ];

  /// The e0 hairline. Use this instead of reaching for a shadow.
  static Border hairline(VinkolColors c) =>
      Border.fromBorderSide(BorderSide(color: c.borderSubtle));
}
