import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/l10n/status_labels.dart';

/// Status as typography — design signature #3.
///
/// Every status renders as a **triple**: label text, then shape, then colour, in that
/// priority order (decision D-05). The shape is not decoration; it is the signal that
/// survives a greyscale screenshot, a colourblind user and a monochrome printout. All six
/// statuses in the closed set have a different one.
///
/// The label is never omitted. There is no icon-only variant of this widget on purpose.
class VinkolStatusChip extends StatelessWidget {
  const VinkolStatusChip(
    this.status, {
    super.key,
    this.dense = false,
  });

  final VinkolStatus status;

  /// Drops the ground and the padding, for use inside a row that already has a container.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final style = context.vinkol.statusStyle(status);
    return VinkolStatusBadge(
      // The style's own label is the English fallback; what renders is the localized one.
      label: status.labelIn(context),
      shape: style.shape,
      color: style.color,
      ground: style.ground,
      dense: dense,
    );
  }
}

/// The status triple for anything outside the closed set of six delivery states.
///
/// A payment is `Successful` or `Pending` or `Failed`; a withdrawal is `Approved` or
/// `Rejected`. Those are not delivery statuses and must never be forced into [VinkolStatus],
/// but they are subject to the same rule (D-05): the label leads, the shape carries the
/// signal, and the colour is the last of the three. Callers supply the triple; this widget
/// is what stops any of them drawing a bare coloured dot.
class VinkolStatusBadge extends StatelessWidget {
  const VinkolStatusBadge({
    super.key,
    required this.label,
    required this.shape,
    required this.color,
    required this.ground,
    this.dense = false,
  });

  final String label;
  final VinkolStatusShape shape;
  final Color color;
  final Color ground;

  /// Drops the ground and the padding, for use inside a row that already has a container.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        VinkolStatusGlyph(
          shape: shape,
          color: color,
          knockout: dense ? v.surface : ground,
        ),
        const SizedBox(width: VinkolSpace.sm),
        // The label leads. Not uppercased in Dart: some locales do not uppercase safely.
        Flexible(
          child: Text(
            label,
            style: VinkolType.labelS.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (dense) return Semantics(label: label, child: content);

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: VinkolSpace.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: ground,
          borderRadius: VinkolRadius.brFull,
        ),
        child: content,
      ),
    );
  }
}

/// The shape half of the triple. 7pt of glyph doing the work colour cannot.
class VinkolStatusGlyph extends StatelessWidget {
  const VinkolStatusGlyph({
    super.key,
    required this.shape,
    required this.color,
    required this.knockout,
  });

  final VinkolStatusShape shape;
  final Color color;

  /// The colour behind the glyph. Ticks, holes and exclamations are drawn in it rather than
  /// cleared, so the mark reads on any ground without a saveLayer.
  final Color knockout;

  static const double _size = 12;

  @override
  Widget build(BuildContext context) {
    if (shape == VinkolStatusShape.pulsingRing) {
      return _PulsingRing(color: color, knockout: knockout, size: _size);
    }
    return CustomPaint(
      size: const Size.square(_size),
      painter: _GlyphPainter(shape: shape, color: color, knockout: knockout),
    );
  }
}

/// The only animated status. A delivery in motion is the one thing on screen that is
/// changing, so it is the one thing allowed to move.
class _PulsingRing extends StatefulWidget {
  const _PulsingRing({
    required this.color,
    required this.knockout,
    required this.size,
  });

  final Color color;
  final Color knockout;
  final double size;

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion means no motion, not a faster loop. The ring still reads as a ring,
    // which is the shape that carries the meaning.
    if (VinkolMotion.reduced(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _GlyphPainter(
          shape: VinkolStatusShape.pulsingRing,
          color: widget.color,
          knockout: widget.knockout,
          // A gentle breath, not a flash: 1.0 down to 0.45 opacity.
          pulse: 1 - (_controller.value * 0.55),
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.shape,
    required this.color,
    required this.knockout,
    this.pulse = 1,
  });

  final VinkolStatusShape shape;
  final Color color;
  final Color knockout;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final stroke = size.width * 0.18;
    final fill = Paint()..color = color.withValues(alpha: pulse);
    final line = Paint()
      ..color = color.withValues(alpha: pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    switch (shape) {
      case VinkolStatusShape.halfFilled:
        // Waiting: half the circle is done.
        canvas.drawCircle(c, r - stroke / 2, line);
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r - stroke),
          -math.pi / 2,
          math.pi,
          true,
          fill,
        );

      case VinkolStatusShape.pulsingRing:
        // In motion: an open ring, breathing.
        canvas.drawCircle(c, r - stroke / 2, line);

      case VinkolStatusShape.donut:
        // Held: solid ring, hollow centre. Distinct from the open ring at a glance.
        canvas.drawCircle(c, r, fill);
        canvas.drawCircle(c, r * 0.34, Paint()..color = knockout);

      case VinkolStatusShape.filledTick:
        canvas.drawCircle(c, r, fill);
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.27, size.height * 0.52)
            ..lineTo(size.width * 0.43, size.height * 0.69)
            ..lineTo(size.width * 0.75, size.height * 0.33),
          _mark(stroke),
        );

      case VinkolStatusShape.hollowSlash:
        // Stopped, not failed: hollow, struck through. Never red (D-05).
        canvas.drawCircle(c, r - stroke / 2, line);
        canvas.drawLine(
          Offset(size.width * 0.26, size.height * 0.74),
          Offset(size.width * 0.74, size.height * 0.26),
          line,
        );

      case VinkolStatusShape.filledAlert:
        canvas.drawCircle(c, r, fill);
        final mark = _mark(stroke);
        canvas.drawLine(
          Offset(c.dx, size.height * 0.26),
          Offset(c.dx, size.height * 0.55),
          mark,
        );
        // The dot of the exclamation, drawn as a zero-length round cap.
        canvas.drawLine(
          Offset(c.dx, size.height * 0.74),
          Offset(c.dx, size.height * 0.74),
          mark,
        );
    }
  }

  /// A mark cut into a filled glyph: the ground colour, so it reads without a saveLayer.
  Paint _mark(double stroke) => Paint()
    ..color = knockout
    ..style = PaintingStyle.stroke
    ..strokeWidth = stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.shape != shape ||
      old.color != color ||
      old.knockout != knockout ||
      old.pulse != pulse;
}
