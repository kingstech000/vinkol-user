import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/fonts.dart';

/// Vinkol type scale. Source of truth: `.claude/design/04-tokens.md` §2, decision D-02.
///
/// The spec (D-02) splits the scale across three faces:
///   Montserrat     display + h1        — the brand voice, retained
///   Inter          h2 and below, num.* — drawn for UI at small sizes, ships tabular figures
///   IBM Plex Mono  identifiers only    — disambiguated 0/O and 1/l/I
///
/// Only Montserrat is bundled (`AppFonts.montserrat`, see pubspec `fonts:`), so every style
/// below renders in Montserrat for now. Fonts are never fetched at runtime; to bring Inter or
/// IBM Plex Mono in, add their files under `assets/fonts/`, declare them in pubspec, and
/// re-point the styles here.
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
  static const TextStyle displayL = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 34,
      height: 40 / 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.68);

  static const TextStyle displayS = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.56);

  // --- Headings
  static const TextStyle h1 = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 24,
      height: 30 / 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.36);

  static const TextStyle h2 = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 20,
      height: 26 / 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2);

  static const TextStyle h3 = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 17,
      height: 24 / 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.085);

  static const TextStyle h4 = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w600);

  // --- Body
  static const TextStyle bodyL = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 17,
      height: 26 / 17,
      fontWeight: FontWeight.w400);
  static const TextStyle body = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w400);
  static const TextStyle bodyS = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 13,
      height: 20 / 13,
      fontWeight: FontWeight.w400);

  // --- Labels and supporting
  static const TextStyle label = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 13,
      height: 16 / 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.065);

  /// Uppercase eyebrow and status labels. Apply the uppercasing in the component, not here —
  /// some locales do not uppercase safely.
  static const TextStyle labelS = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.44);

  static const TextStyle caption = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400);

  static const TextStyle button = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15);

  // --- Numeric. Every money value, ETA, distance and count uses one of these.
  // Tabular figures are what stop numbers jittering as values update and what lets columns
  // align on a shared axis (signature #4). Do not substitute a body style.
  static const TextStyle numXl = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 32,
      height: 36 / 32,
      fontWeight: FontWeight.w700,
      fontFeatures: _tabular);

  static const TextStyle numL = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 22,
      height: 26 / 22,
      fontWeight: FontWeight.w600,
      fontFeatures: _tabular);

  static const TextStyle num = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w500,
      fontFeatures: _tabular);

  /// Tracking codes, order and reference IDs. Not for prose, and not for money.
  static const TextStyle mono = TextStyle(
      fontFamily: AppFonts.montserrat,
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.26,
      fontFeatures: _tabular);
}
