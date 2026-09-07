import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// One stop on the Line.
class VinkolStop {
  const VinkolStop({
    required this.label,
    this.place,
    this.placeholder,
    this.onTap,
  });

  /// The uppercase eyebrow: "PICKUP", "DROP-OFF", "STOP 2".
  final String label;

  /// The address. Null renders [placeholder] in the tertiary ink instead.
  final String? place;

  /// Shown when [place] is null — "Where are we collecting from?".
  final String? placeholder;

  final VoidCallback? onTap;
}

/// **The Line** — design signature #1, vertical.
///
/// Pickup node, dotted path, diamond terminus. One continuous route line is the product's
/// organising device, and a user should be able to identify a Vinkol screen from it alone.
/// The geometry is identical at every scale it appears at, which is what makes it a
/// signature rather than a decoration.
///
/// The rail is 16pt wide with a 13pt gutter, matching `.stops` in the prototype.
class VinkolStopsRail extends StatelessWidget {
  const VinkolStopsRail({super.key, required this.stops});

  final List<VinkolStop> stops;

  @override
  Widget build(BuildContext context) {
    // Guarded in build, not the initialiser list: a const constructor cannot read
    // `stops.length`, and const-ness matters on a widget that appears in every list.
    assert(stops.length >= 2,
        'A route needs at least an origin and a destination.');
    final v = context.vinkol;

    // The rail is painted as a positioned sibling rather than a stretched Row child: a Row
    // with CrossAxisAlignment.stretch hands its children an infinite height whenever the
    // Line sits in an unbounded column (a ListView item, which is every place it appears).
    // In a Stack the rail takes its height from the stops instead, with the same geometry.
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: 16,
          child: CustomPaint(
            painter: _RailPainter(
              stopCount: stops.length,
              node: v.brand,
              path: v.borderStrong,
            ),
          ),
        ),
        Padding(
          // 16pt rail + 13pt gutter.
          padding: const EdgeInsetsDirectional.only(start: 29),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var i = 0; i < stops.length; i++)
                _StopRow(
                  stop: stops[i],
                  // Rows are separated by a hairline, never by a shadow. The first has none.
                  showDivider: i > 0,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StopRow extends StatefulWidget {
  const _StopRow({required this.stop, required this.showDivider});

  final VinkolStop stop;
  final bool showDivider;

  @override
  State<_StopRow> createState() => _StopRowState();
}

class _StopRowState extends State<_StopRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final stop = widget.stop;
    final disabled = stop.onTap == null;
    final filled = stop.place != null && stop.place!.isNotEmpty;

    final body = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: _pressed ? v.surfaceAlt : Colors.transparent,
        border: widget.showDivider
            ? BorderDirectional(top: BorderSide(color: v.borderSubtle))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            stop.label.toUpperCase(),
            style: VinkolType.labelS.copyWith(color: v.textTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            filled ? stop.place! : (stop.placeholder ?? ''),
            style: VinkolType.h4.copyWith(
              // An empty stop reads as tertiary; a disabled one reads as tertiary too, but
              // the tap target is gone, which is the real signal.
              color: filled && !disabled ? v.textPrimary : v.textTertiary,
              fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (disabled) return body;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: stop.onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(button: true, child: body),
    );
  }
}

/// The rail: a ring at every stop, a diamond at the terminus, dots between.
class _RailPainter extends CustomPainter {
  const _RailPainter({
    required this.stopCount,
    required this.node,
    required this.path,
  });

  final int stopCount;
  final Color node;
  final Color path;

  @override
  void paint(Canvas canvas, Size size) {
    // 16pt of vertical padding top and bottom, matching `.stops__rail`.
    const pad = 16.0;
    final x = size.width / 2;
    final span = size.height - pad * 2;
    if (span <= 0 || stopCount < 2) return;

    final gap = span / (stopCount - 1);
    final ring = Paint()
      ..color = node
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final dot = Paint()
      ..color = path
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < stopCount - 1; i++) {
      final from = pad + gap * i + 9;
      final to = pad + gap * (i + 1) - 9;
      // Dotted, not dashed: 2pt dots on a 5pt pitch, the same rhythm as the existing
      // HorizontalDottedLine so the two read as one device.
      for (var y = from; y < to; y += 5) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 0.1), dot);
      }
    }

    for (var i = 0; i < stopCount; i++) {
      final y = pad + gap * i;
      if (i == stopCount - 1) {
        // The terminus is a diamond — a square on its corner, filled.
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(0.7853981633974483); // 45°
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 10, height: 10),
            const Radius.circular(2),
          ),
          Paint()..color = node,
        );
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(x, y), 4.25, ring);
      }
    }
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.stopCount != stopCount || old.node != node || old.path != path;
}

/// **The Line, horizontal** — the progress track on order detail.
///
/// Same device, rotated: nodes for each step, a filled segment behind the ones that are
/// done, and a ringed node for where the delivery is now. The current node's ring is the
/// only thing that distinguishes "here" from "done", so it is a shape, not a shade.
class VinkolProgressTrack extends StatelessWidget {
  const VinkolProgressTrack({
    super.key,
    required this.step,
    this.total = 4,
    this.from,
    this.to,
  }) : assert(total >= 2, 'A track needs at least two steps.');

  /// 1-based. `step == 1` means the first node is current and nothing is complete.
  final int step;
  final int total;

  /// Optional end labels under the track.
  final String? from;
  final String? to;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final current = step.clamp(1, total);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          label: 'Step $current of $total',
          child: SizedBox(
            height: 22,
            child: Row(
              children: <Widget>[
                for (var i = 0; i < total; i++) ...<Widget>[
                  _TrackNode(
                    done: i < current - 1,
                    now: i == current - 1,
                    onColor: v.brand,
                    offColor: v.borderStrong,
                    ring: v.brandRing,
                  ),
                  if (i < total - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: i < current - 1 ? v.brand : v.borderStrong,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (from != null || to != null) ...<Widget>[
          const SizedBox(height: VinkolSpace.sm),
          Row(
            children: <Widget>[
              Expanded(child: _end(v, 'From', from, TextAlign.start)),
              Expanded(child: _end(v, 'To', to, TextAlign.end)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _end(VinkolColors v, String label, String? value, TextAlign align) {
    if (value == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: align == TextAlign.start
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: VinkolType.caption.copyWith(color: v.textTertiary)),
        Text(
          value,
          style: VinkolType.h4.copyWith(color: v.textPrimary),
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TrackNode extends StatelessWidget {
  const _TrackNode({
    required this.done,
    required this.now,
    required this.onColor,
    required this.offColor,
    required this.ring,
  });

  final bool done;
  final bool now;
  final Color onColor;
  final Color offColor;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done || now ? onColor : offColor,
        // A 5pt halo marks the current step. Shape, not shade.
        boxShadow: now
            ? <BoxShadow>[BoxShadow(color: ring, spreadRadius: 5)]
            : const <BoxShadow>[],
      ),
    );
  }
}
