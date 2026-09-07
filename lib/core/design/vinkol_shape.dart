/// Vinkol surface geometry: the superellipse contour every Vinkol surface is cut from.
///
/// A rounded rectangle changes curvature abruptly where the straight edge meets the arc, and
/// at the radii Midnight uses (12 / 18 / 24) that discontinuity is visible — it is what makes
/// a card read as *drawn* rather than as *carved*. A rounded superellipse eases curvature in
/// and out of each corner instead, which is the shape SwiftUI calls `.continuous` and the
/// shape the approved card reference is built from.
///
/// Flutter 3.38 carries [RSuperellipse] in the engine, so this is the real contour rather
/// than a Bezier impression of one, and it rasterises on the GPU like any other path.
///
/// Nothing here holds a literal: callers pass the radius tokens from [VinkolRadius] and the
/// elevation tokens from [VinkolElevation], and this file turns them into a path.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract final class VinkolShape {
  /// The contour of [rect] with [radii] at its corners.
  ///
  /// Radii are clamped to half the shorter side, so passing [VinkolRadius.full] yields a
  /// capsule rather than an assertion — which is what the pills in the system want.
  static Path superellipse(Rect rect, BorderRadius radii) {
    final BorderRadius r = _fit(rect, radii);
    return Path()
      ..addRSuperellipse(
        RSuperellipse.fromRectAndCorners(
          rect,
          topLeft: r.topLeft,
          topRight: r.topRight,
          bottomLeft: r.bottomLeft,
          bottomRight: r.bottomRight,
        ),
      );
  }

  static BorderRadius _fit(Rect rect, BorderRadius radii) {
    final double limit = rect.shortestSide / 2;
    Radius cap(Radius radius) => Radius.elliptical(
          radius.x.clamp(0.0, limit),
          radius.y.clamp(0.0, limit),
        );
    return BorderRadius.only(
      topLeft: cap(radii.topLeft),
      topRight: cap(radii.topRight),
      bottomLeft: cap(radii.bottomLeft),
      bottomRight: cap(radii.bottomRight),
    );
  }

  /// The radii a shadow needs when its box is spread out from (or into) the surface.
  static BorderRadius spread(BorderRadius radii, double by) {
    Radius grow(Radius radius) => Radius.elliptical(
          (radius.x + by).clamp(0.0, double.infinity),
          (radius.y + by).clamp(0.0, double.infinity),
        );
    return BorderRadius.only(
      topLeft: grow(radii.topLeft),
      topRight: grow(radii.topRight),
      bottomLeft: grow(radii.bottomLeft),
      bottomRight: grow(radii.bottomRight),
    );
  }
}

/// Paints one Vinkol surface: its elevation, its fill, then its hairline.
///
/// The hairline is stroked half a pixel inside the contour rather than centred on it, so a
/// 1px border stays 1px instead of straddling the edge and reading as a soft grey seam —
/// which at e0, where the hairline is the *only* separation, is the difference between a
/// crisp edge and a blurred one.
class VinkolSurfacePainter extends CustomPainter {
  const VinkolSurfacePainter({
    required this.radii,
    required this.color,
    this.border,
    this.borderWidth = 1,
    this.shadows = const <BoxShadow>[],
  });

  final BorderRadius radii;
  final Color color;
  final Color? border;
  final double borderWidth;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    if (rect.isEmpty) return;

    for (final BoxShadow shadow in shadows) {
      final Rect box = rect.shift(shadow.offset).inflate(shadow.spreadRadius);
      if (box.isEmpty) continue;
      canvas.drawPath(
        VinkolShape.superellipse(
          box,
          VinkolShape.spread(radii, shadow.spreadRadius),
        ),
        shadow.toPaint(),
      );
    }

    canvas.drawPath(
      VinkolShape.superellipse(rect, radii),
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );

    final Color? edge = border;
    if (edge != null) {
      final double inset = borderWidth / 2;
      canvas.drawPath(
        VinkolShape.superellipse(
          rect.deflate(inset),
          VinkolShape.spread(radii, -inset),
        ),
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(VinkolSurfacePainter old) =>
      old.radii != radii ||
      old.color != color ||
      old.border != border ||
      old.borderWidth != borderWidth ||
      !listEquals(old.shadows, shadows);
}

/// Clips a child — an illustration, a map, a photograph — to the same contour.
class VinkolSurfaceClipper extends CustomClipper<Path> {
  const VinkolSurfaceClipper(this.radii);

  final BorderRadius radii;

  @override
  Path getClip(Size size) =>
      VinkolShape.superellipse(Offset.zero & size, radii);

  @override
  bool shouldReclip(VinkolSurfaceClipper old) => old.radii != radii;
}
