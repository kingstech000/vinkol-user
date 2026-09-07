import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vinkol type scale. Source of truth: `.claude/design/04-tokens.md` §2, decision D-02.
///
/// One superfamily, two cuts:
///   Geist       everything — display, headings, body, labels, buttons, all `num.*`
///   Geist Mono  identifiers only — disambiguated 0/O and 1/l/I
///
/// Geist is drawn for interfaces: tight defaults, a large x-height that survives 11pt, and
/// tabular figures in every weight. Because one family now carries both the brand register and
/// the UI register, hierarchy comes from size, weight and tracking — never from a second face.
/// Weights w100–w900 are available; there is no italic cut, so do not ask for one.
///
/// Styles carry size, weight, leading and tracking but **no color** — color comes from
/// `context.vinkol` at the call site, so one style works in both themes.
///
/// Sizes are unscaled on purpose. `.sp` is banned (decision D-04): it scales with device width
/// and discards the user's OS text-size setting. Let `MediaQuery.textScaler` do its job.
abstract final class VinkolType {
  static const _tabular = [FontFeature.tabularFigures()];

  // --- Display: hero register only (splash, onboarding, tracking, order complete, receipt,
  // wallet balance, empty states). A screen not on that list may not use these.
  // Tracking runs tighter than the UI register — that density is what marks the hero register
  // now that a change of face no longer does.
  static TextStyle get displayL => GoogleFonts.geist(
      fontSize: 34,
      height: 40 / 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.02);

  static TextStyle get displayS => GoogleFonts.geist(
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.84);

  // --- Headings
  static TextStyle get h1 => GoogleFonts.geist(
      fontSize: 24,
      height: 30 / 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6);

  static TextStyle get h2 => GoogleFonts.geist(
      fontSize: 20,
      height: 26 / 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3);

  static TextStyle get h3 => GoogleFonts.geist(
      fontSize: 17,
      height: 24 / 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.17);

  static TextStyle get h4 => GoogleFonts.geist(
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.075);

  // --- Body
  static TextStyle get bodyL => GoogleFonts.geist(
      fontSize: 17, height: 26 / 17, fontWeight: FontWeight.w400);
  static TextStyle get body => GoogleFonts.geist(
      fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400);
  static TextStyle get bodyS => GoogleFonts.geist(
      fontSize: 13, height: 20 / 13, fontWeight: FontWeight.w400);

  // --- Labels and supporting
  static TextStyle get label => GoogleFonts.geist(
      fontSize: 13,
      height: 16 / 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.065);

  /// Uppercase eyebrow and status labels. Apply the uppercasing in the component, not here —
  /// some locales do not uppercase safely.
  static TextStyle get labelS => GoogleFonts.geist(
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.44);

  static TextStyle get caption => GoogleFonts.geist(
      fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400);

  static TextStyle get button => GoogleFonts.geist(
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15);

  // --- Numeric. Every money value, ETA, distance and count uses one of these.
  // Tabular figures are what stop numbers jittering as values update and what lets columns
  // align on a shared axis (signature #4). Do not substitute a body style.
  static TextStyle get numXl => GoogleFonts.geist(
      fontSize: 32,
      height: 36 / 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.64,
      fontFeatures: _tabular);

  static TextStyle get numL => GoogleFonts.geist(
      fontSize: 22,
      height: 26 / 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.33,
      fontFeatures: _tabular);

  static TextStyle get num => GoogleFonts.geist(
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w500,
      fontFeatures: _tabular);

  /// Tracking codes, order and reference IDs. Not for prose, and not for money.
  static TextStyle get mono => GoogleFonts.geistMono(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.26,
      fontFeatures: _tabular);
}
