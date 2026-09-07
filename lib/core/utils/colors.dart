import 'package:starter_codes/core/design/vinkol_color.dart';

/// The legacy color API, re-pointed at the Midnight tokens (decision D-03).
///
/// 202 files depend on these names, so the names and signatures do not change — only what
/// they *produce*. Every member below now resolves to a [VinkolPalette] token, which means
/// the whole app moved onto the new palette without a rename sweep.
///
/// **This class is light-mode only and has no theme awareness.** It is a migration shim, not
/// a token layer. New and touched code should read `context.vinkol` (a [VinkolColors]
/// resolved for the active brightness) instead; every member here is deleted once its call
/// sites reach zero.
class AppColors {
  /// Ink, not pure black — Midnight's light-mode `--txt`.
  static const black = VinkolPalette.lightText;

  static const white = VinkolPalette.white;

  /// The brand. `#0E74D8`, unchanged and unchangeable (02-do-not-lose.md).
  static const primary = VinkolPalette.brand500;

  /// Secondary text — light-mode `--txt2`. 6.1:1 on white; the old `#6D6969` was 4.7:1.
  static const darkgrey = VinkolPalette.lightText2;

  /// The strong neutral for headings and icons on light. Was `#303030`.
  static const greyLight = VinkolPalette.lightText;

  /// Borders and rules — light-mode `--line2`. **Never carries text**: the old `#D9D9D9` was
  /// 1.41:1 and neither is this.
  static const lightgrey = VinkolPalette.lightLine2;

  /// Success *text* on light. Not a fill — see [VinkolPalette.successFill].
  static const green = VinkolPalette.lightOk;

  /// Error *text* on light. The old `#E54335` was 4.05:1 and failed AA for body copy.
  static const red = VinkolPalette.lightBad;

  /// Field and inert-block fill — light-mode `--surf2`.
  static const formFillColor = VinkolPalette.lightSurfaceAlt;

  @Deprecated(
      'An off-brand near-duplicate of the brand blue. Use AppColors.primary.')
  static const blue = VinkolPalette.brand500;

  @Deprecated(
      'The purple contradicts the brand. Use AppColors.primary, or context.vinkol.brandSubtle for a tint.')
  static const primaryLight = VinkolPalette.brand400;

  @Deprecated(
      'The purple contradicts the brand. Use AppColors.lightgrey, or context.vinkol.borderSubtle.')
  static const purpleGrey = VinkolPalette.lightLine2;

  @Deprecated('Duplicate of AppColors.formFillColor. Use that.')
  static const formWhite = VinkolPalette.lightSurfaceAlt;
}
