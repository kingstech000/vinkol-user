import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vinkol type scale. Source of truth: `.claude/design/04-tokens.md` §2, decision D-02.
///
/// Three faces, split by job:
///   Montserrat     display + h1        — the brand voice, retained
///   Inter          h2 and below, num.* — drawn for UI at small sizes, ships tabular figures
///   IBM Plex Mono  identifiers only    — disambiguated 0/O and 1/l/I
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
  static TextStyle get displayL => GoogleFonts.montserrat(
      fontSize: 34, height: 40 / 34, fontWeight: FontWeight.w700, letterSpacing: -0.68);

  static TextStyle get displayS => GoogleFonts.montserrat(
      fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w700, letterSpacing: -0.56);

  // --- Headings
  static TextStyle get h1 => GoogleFonts.montserrat(
      fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w700, letterSpacing: -0.36);

  static TextStyle get h2 => GoogleFonts.inter(
      fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w600, letterSpacing: -0.2);

  static TextStyle get h3 => GoogleFonts.inter(
      fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w600, letterSpacing: -0.085);

  static TextStyle get h4 =>
      GoogleFonts.inter(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w600);

  // --- Body
  static TextStyle get bodyL =>
      GoogleFonts.inter(fontSize: 17, height: 26 / 17, fontWeight: FontWeight.w400);
  static TextStyle get body =>
      GoogleFonts.inter(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400);
  static TextStyle get bodyS =>
      GoogleFonts.inter(fontSize: 13, height: 20 / 13, fontWeight: FontWeight.w400);

  // --- Labels and supporting
  static TextStyle get label => GoogleFonts.inter(
      fontSize: 13, height: 16 / 13, fontWeight: FontWeight.w600, letterSpacing: 0.065);

  /// Uppercase eyebrow and status labels. Apply the uppercasing in the component, not here —
  /// some locales do not uppercase safely.
  static TextStyle get labelS => GoogleFonts.inter(
      fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w600, letterSpacing: 0.44);

  static TextStyle get caption =>
      GoogleFonts.inter(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400);

  static TextStyle get button => GoogleFonts.inter(
      fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w600, letterSpacing: 0.15);

  // --- Numeric. Every money value, ETA, distance and count uses one of these.
  // Tabular figures are what stop numbers jittering as values update and what lets columns
  // align on a shared axis (signature #4). Do not substitute a body style.
  static TextStyle get numXl => GoogleFonts.inter(
      fontSize: 32, height: 36 / 32, fontWeight: FontWeight.w700, fontFeatures: _tabular);

  static TextStyle get numL => GoogleFonts.inter(
      fontSize: 22, height: 26 / 22, fontWeight: FontWeight.w600, fontFeatures: _tabular);

  static TextStyle get num => GoogleFonts.inter(
      fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w500, fontFeatures: _tabular);

  /// Tracking codes, order and reference IDs. Not for prose, and not for money.
  static TextStyle get mono => GoogleFonts.ibmPlexMono(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.26,
      fontFeatures: _tabular);
}
