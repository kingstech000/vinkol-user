/// The reward surface's warm palette.
///
/// One screen in the app is allowed to be pleased with itself, and this is it. Everywhere
/// else Midnight holds: blue, one saturated object, no gradients. The reward card earns an
/// exception because a discount that arrives with no ceremony is a discount nobody notices.
///
/// The colours are **lifted from the artwork**, not invented — `assets/images/gift-box.png`
/// is a gold box with a red ribbon, and a warm card built from the gift's own hues still
/// reads as Vinkol. A warm card built from a fresh set reads as a different app.
///
/// This is a surface palette, not a semantic token set: it is deliberately kept out of
/// [VinkolColors] so that nothing outside the reward can reach for gold by accident.
library;

import 'package:flutter/widgets.dart';

import 'vinkol_color.dart';

/// The warm ink the reward card paints with, resolved for one brightness.
@immutable
class VinkolRewardInk {
  const VinkolRewardInk._({
    required this.gold,
    required this.goldDeep,
    required this.goldDim,
    required this.rose,
    required this.glow,
    required this.wash,
    required this.festive,
    required this.confetti,
    required this.onFestive,
    required this.onFestiveMuted,
    required this.shine,
  });

  /// Resolves the palette for [v]'s brightness.
  factory VinkolRewardInk.of(VinkolColors v) => v.isDark ? _dark : _light;

  /// The gift's gold, as ink. Used for the count chip once the card is warming.
  final Color gold;

  /// The deep end of the gold, and the warm end of the waterline gradient.
  final Color goldDeep;

  /// The gold as a ground for the count chip.
  final Color goldDim;

  /// The ribbon's red. The coolest use it gets is a confetti fleck.
  final Color rose;

  /// The light the box throws onto the card. Radial, and it grows with progress.
  final Color glow;

  /// The progress wash, cool on the start edge and warm on the end, so the card is literally
  /// warmer nearer the prize. Painted at the card's heat, never at full strength.
  final List<Color> wash;

  /// The earned card's ground. The one gradient in the app that is not a map scrim.
  final List<Color> festive;

  /// The confetti flecks, in the artwork's own hues. Four, in this order.
  final List<Color> confetti;

  /// Type on the festive ground.
  final Color onFestive;
  final Color onFestiveMuted;

  /// The sweep of shine that crosses the box once it is won.
  final Color shine;

  static const _dark = VinkolRewardInk._(
    gold: Color(0xFFFFC45C),
    goldDeep: Color(0xFFFF9F2E),
    goldDim: Color(0x2EFFC45C),
    rose: Color(0xFFFF7F8A),
    glow: Color(0x8CFFAF3C),
    wash: <Color>[Color(0x332E8BEF), Color(0x42FF9F2E), Color(0x38FF7F8A)],
    festive: <Color>[Color(0xFF0E74D8), Color(0xFFB4610A), Color(0xFF93303B)],
    confetti: <Color>[
      Color(0xFFFFC45C),
      Color(0xFFFF7F8A),
      Color(0x80FFFFFF),
      Color(0xFFFFC45C),
    ],
    onFestive: Color(0xFFFFFFFF),
    onFestiveMuted: Color(0xDBFFFFFF),
    shine: Color(0x99FFFFFF),
  );

  /// Light is not the dark palette lightened: gold at `#FFC45C` measures 1.4:1 on white and
  /// is unreadable as text, so the light register takes the burnt step for ink and keeps the
  /// bright gold only for glows and fills, where nothing is being read.
  static const _light = VinkolRewardInk._(
    gold: Color(0xFFA25C00),
    goldDeep: Color(0xFFD08400),
    goldDim: Color(0xFFFDF0D9),
    rose: Color(0xFFC0392F),
    glow: Color(0x8CFFAF3C),
    wash: <Color>[Color(0x330E74D8), Color(0x42FF9F2E), Color(0x38FF7F8A)],
    festive: <Color>[Color(0xFF0E74D8), Color(0xFFE08A12), Color(0xFFD2564F)],
    confetti: <Color>[
      Color(0xFFFFC45C),
      Color(0xFFFF7F8A),
      Color(0x99FFFFFF),
      Color(0xFFFFC45C),
    ],
    onFestive: Color(0xFFFFFFFF),
    onFestiveMuted: Color(0xDBFFFFFF),
    shine: Color(0x99FFFFFF),
  );
}
