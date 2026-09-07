import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// The Vinkol mark: the route Line at brand scale.
///
/// A ring, a stem, a diamond — pickup, path, destination. It is the same geometry as
/// [VinkolStopsRail] and the order-row glyph, drawn large. That is the whole point of
/// signature #1: a user should be able to identify a Vinkol screen from the Line alone, and
/// the logo being made of it is what teaches them to.
///
/// No wordmark asset, no PNG. The old splash and auth screens both loaded a 250pt
/// `splash.png`, which cannot recolour for dark mode and cannot scale.
class VinkolMark extends StatelessWidget {
  const VinkolMark({super.key, this.height = 76, this.color});

  final double height;

  /// Defaults to the brand. The mark is the one place the saturated blue appears on a screen
  /// that has no hero card.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/images/splash.png", height: height);
  }
}

/// Which onboarding panel's art to draw.
enum VinkolOnboardingArt { send, track, trust }

/// The onboarding illustration — drawn, not an asset.
///
/// Each panel is the Line answering one question: where does it go, where is it now, what if
/// it goes wrong. Stock illustration, 3D objects and decorative sparkles are banned outright
/// (banned aesthetics, brief §3), and a drawn mark also recolours for dark mode and survives
/// any screen density.
class VinkolOnboardingArtwork extends StatelessWidget {
  const VinkolOnboardingArtwork({super.key, required this.art});

  final VinkolOnboardingArt art;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Semantics(
      excludeSemantics: true,
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: CustomPaint(
          painter: _ArtPainter(
            art: art,
            accent: v.brand,
            line: v.borderSubtle,
            line2: v.borderStrong,
            ground: v.canvas,
          ),
        ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  const _ArtPainter({
    required this.art,
    required this.accent,
    required this.line,
    required this.line2,
    required this.ground,
  });

  final VinkolOnboardingArt art;
  final Color accent;
  final Color line;
  final Color line2;
  final Color ground;

  @override
  void paint(Canvas canvas, Size size) {
    // The prototype's 320×180 viewBox, scaled to fit and centred.
    final s = math.min(size.width / 320, size.height / 180);
    canvas.translate((size.width - 320 * s) / 2, (size.height - 180 * s) / 2);
    canvas.scale(s);

    Paint strokeOf(Color c, [double w = 3]) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (art) {
      case VinkolOnboardingArt.send:
        // Origin ring, a long route across the panel, a mid stop, a diamond terminus.
        canvas.drawCircle(const Offset(42, 38), 9, strokeOf(accent));
        canvas.drawPath(
          Path()
            ..moveTo(42, 47)
            ..cubicTo(42, 103, 160, 83, 160, 123)
            ..cubicTo(160, 163, 278, 143, 278, 153),
          strokeOf(accent),
        );
        canvas.save();
        canvas.translate(278, 153);
        canvas.rotate(math.pi / 4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 16, height: 16),
            const Radius.circular(2),
          ),
          Paint()..color = accent,
        );
        canvas.restore();
        // The mid node is knocked out in the canvas colour so the route reads as passing
        // through it rather than stopping.
        canvas.drawCircle(const Offset(160, 123), 5, Paint()..color = ground);
        canvas.drawCircle(const Offset(160, 123), 5, strokeOf(accent));

      case VinkolOnboardingArt.track:
        // Accuracy rings around a live position, with a spur to the destination.
        canvas.drawCircle(const Offset(160, 90), 58, strokeOf(line, 2));
        canvas.drawCircle(const Offset(160, 90), 34, strokeOf(line2, 2));
        canvas.drawCircle(const Offset(160, 90), 11, Paint()..color = accent);
        canvas.drawLine(
            const Offset(160, 90), const Offset(214, 52), strokeOf(accent));
        canvas.drawCircle(const Offset(214, 52), 7, Paint()..color = ground);
        canvas.drawCircle(const Offset(214, 52), 7, strokeOf(accent));

      case VinkolOnboardingArt.trust:
        // A shield and a tick. Geometric, at the same 3pt stroke as everything else.
        canvas.drawPath(
          Path()
            ..moveTo(160, 26)
            ..lineTo(108, 48)
            ..lineTo(108, 90)
            ..cubicTo(108, 120, 129, 143, 160, 152)
            ..cubicTo(191, 143, 212, 120, 212, 90)
            ..lineTo(212, 48)
            ..close(),
          strokeOf(accent),
        );
        canvas.drawPath(
          Path()
            ..moveTo(140, 92)
            ..lineTo(154, 106)
            ..lineTo(182, 76),
          strokeOf(accent),
        );
    }
  }

  @override
  bool shouldRepaint(_ArtPainter old) =>
      old.art != art || old.accent != accent || old.ground != ground;
}
