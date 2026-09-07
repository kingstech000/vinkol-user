import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// A list row: optional icon well, title and meta, and a value flush to the end.
///
/// **Flush numerics** — design signature #4. Money, ETAs and distances go in [value] and are
/// rendered right-aligned in tabular figures, so every row in a list aligns on one optical
/// axis. That alignment is what makes multi-currency feel native rather than retrofitted:
/// `₦1,200` and `CA$1,234.56` are different widths, and only a shared end edge survives both.
///
/// A row shows a chevron *or* a value, never both — a value is the answer, and a chevron
/// promises another screen.
class VinkolRow extends StatefulWidget {
  const VinkolRow({
    super.key,
    required this.title,
    this.meta,
    this.value,
    this.valueMeta,
    this.icon,
    this.accentIcon = false,
    this.onTap,
    this.enabled = true,
    this.showDivider = false,
    this.trailing,
    this.titleMaxLines = 1,
    this.metaMaxLines = 1,
  });

  final String title;

  /// One supporting line under the title.
  final String? meta;

  /// The number. Pass it already formatted through the market layer — this widget must not
  /// know what a currency is.
  final String? value;

  /// A second line under the value: a date, a unit, a count.
  final String? valueMeta;

  final IconData? icon;

  /// Tints the icon well with the brand. Reserve it for the live or primary row.
  final bool accentIcon;

  final VoidCallback? onTap;
  final bool enabled;

  /// Drawn by [VinkolRowGroup]. A standalone row has no divider.
  final bool showDivider;

  /// Replaces the value/chevron slot entirely — a switch, a chip, a status.
  final Widget? trailing;

  /// One line by default, because a row title is normally a label. Raise it where the title
  /// is the content rather than a name for it — a street address truncated to "22 Bourdillon
  /// Road, Iko…" is the screen failing at its job.
  final int titleMaxLines;
  final int metaMaxLines;

  @override
  State<VinkolRow> createState() => _VinkolRowState();
}

class _VinkolRowState extends State<VinkolRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final interactive = widget.enabled && widget.onTap != null;
    final ink = widget.enabled ? v.textPrimary : v.textTertiary;
    final subInk = v.textTertiary;

    final body = Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: _pressed ? v.surfaceAlt : Colors.transparent,
        border: widget.showDivider
            ? BorderDirectional(top: BorderSide(color: v.borderSubtle))
            : null,
      ),
      child: Row(
        children: <Widget>[
          if (widget.icon != null) ...<Widget>[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.accentIcon ? v.brandSubtle : v.surfaceAlt,
                borderRadius: VinkolRadius.brSm,
              ),
              child: Icon(
                widget.icon,
                size: 19,
                color: widget.enabled
                    ? (widget.accentIcon ? v.brand : v.textSecondary)
                    : v.textTertiary,
              ),
            ),
            const SizedBox(width: 13),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.title,
                  style: VinkolType.h4.copyWith(color: ink),
                  maxLines: widget.titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.meta != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    widget.meta!,
                    style: VinkolType.bodyS.copyWith(color: subInk),
                    maxLines: widget.metaMaxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...<Widget>[
            const SizedBox(width: VinkolSpace.md),
            widget.trailing!,
          ] else if (widget.value != null) ...<Widget>[
            const SizedBox(width: VinkolSpace.md),
            // Never Expanded: the number keeps its full width and the title gives up space
            // instead. A truncated amount is worse than a truncated label.
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.value!,
                  style: VinkolType.num.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
                if (widget.valueMeta != null)
                  Text(
                    widget.valueMeta!,
                    style: VinkolType.caption.copyWith(color: subInk),
                    textAlign: TextAlign.end,
                  ),
              ],
            ),
          ] else if (interactive) ...<Widget>[
            const SizedBox(width: VinkolSpace.sm),
            Icon(Icons.chevron_right, size: 16, color: subInk),
          ],
        ],
      ),
    );

    if (!interactive) return body;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: body,
      ),
    );
  }
}

/// A group of rows in one bordered surface, hairline-separated.
///
/// e0 by default: a border and no shadow. The `lg` radius is the parent, so the rows' icon
/// wells inside are `sm` — a child never gets a larger radius than its parent.
class VinkolRowGroup extends StatelessWidget {
  const VinkolRowGroup(
      {super.key, required this.children, this.elevated = false});

  final List<VinkolRow> children;

  /// Lifts the group onto `e1`. In dark mode this is a no-op — depth there is surface
  /// lightness, not shadow.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brLg,
        border: VinkolElevation.hairline(v),
        boxShadow: elevated ? VinkolElevation.e1(v) : VinkolElevation.e0,
      ),
      child: ClipRRect(
        borderRadius: VinkolRadius.brLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (var i = 0; i < children.length; i++)
              VinkolRow(
                title: children[i].title,
                meta: children[i].meta,
                value: children[i].value,
                valueMeta: children[i].valueMeta,
                icon: children[i].icon,
                accentIcon: children[i].accentIcon,
                onTap: children[i].onTap,
                enabled: children[i].enabled,
                trailing: children[i].trailing,
                titleMaxLines: children[i].titleMaxLines,
                metaMaxLines: children[i].metaMaxLines,
                showDivider: i > 0,
              ),
          ],
        ),
      ),
    );
  }
}

/// A record card — one order in the Records list.
///
/// The reference is the identity, the status is the triple, and the route is the Line at its
/// smallest scale: two labelled ends with the arrow between them.
class VinkolRecordCard extends StatefulWidget {
  const VinkolRecordCard({
    super.key,
    required this.reference,
    required this.referenceLabel,
    required this.status,
    this.value,
    this.origin,
    this.destination,
    this.onTap,
  });

  /// The tracking or order id, in tabular figures.
  final String reference;

  /// The eyebrow above it: "Order", "Tracking ID".
  final String referenceLabel;

  final Widget status;

  /// Already formatted by the market layer.
  final String? value;

  final String? origin;
  final String? destination;

  final VoidCallback? onTap;

  @override
  State<VinkolRecordCard> createState() => _VinkolRecordCardState();
}

class _VinkolRecordCardState extends State<VinkolRecordCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final interactive = widget.onTap != null;

    final card = AnimatedContainer(
      duration: VinkolMotion.respecting(context, VinkolMotion.instant),
      curve: VinkolMotion.standard,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VinkolSpace.lg,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: _pressed ? v.surfaceAlt : v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
        boxShadow: VinkolElevation.e1(v),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.referenceLabel,
                      style: VinkolType.caption.copyWith(color: v.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.reference,
                      // Mono: this string gets read aloud and transcribed, so 0/O and 1/l
                      // have to be distinguishable.
                      style: VinkolType.mono.copyWith(
                        color: v.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: VinkolSpace.md),
              widget.status,
            ],
          ),
          if (widget.origin != null && widget.destination != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsetsDirectional.only(top: 14),
              decoration: BoxDecoration(
                border:
                    BorderDirectional(top: BorderSide(color: v.borderSubtle)),
              ),
              child: _RouteEnds(
                origin: widget.origin!,
                destination: widget.destination!,
                value: widget.value,
              ),
            ),
          ] else if (widget.value != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsetsDirectional.only(top: 14),
              decoration: BoxDecoration(
                border:
                    BorderDirectional(top: BorderSide(color: v.borderSubtle)),
              ),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  widget.value!,
                  style: VinkolType.numL.copyWith(color: v.textPrimary),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (!interactive) return card;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      ),
    );
  }
}

class _RouteEnds extends StatelessWidget {
  const _RouteEnds({
    required this.origin,
    required this.destination,
    this.value,
  });

  final String origin;
  final String destination;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(child: _end(v, 'From', origin, TextAlign.start)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.md),
          child: CustomPaint(
            size: const Size(28, 8),
            painter: _EndsArrowPainter(color: v.textTertiary),
          ),
        ),
        Flexible(child: _end(v, 'To', destination, TextAlign.start)),
        if (value != null) ...<Widget>[
          const SizedBox(width: VinkolSpace.md),
          Text(
            value!,
            style: VinkolType.num.copyWith(
              color: v.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ],
    );
  }

  Widget _end(VinkolColors v, String label, String place, TextAlign align) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: VinkolType.caption.copyWith(color: v.textTertiary)),
        const SizedBox(height: 2),
        Text(
          place,
          style: VinkolType.h4.copyWith(color: v.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _EndsArrowPainter extends CustomPainter {
  const _EndsArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width - 5, y),
      Paint()
        ..color = color
        ..strokeWidth = 1,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, y)
        ..lineTo(size.width - 6, y - 3.5)
        ..lineTo(size.width - 6, y + 3.5)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_EndsArrowPainter old) => old.color != color;
}
