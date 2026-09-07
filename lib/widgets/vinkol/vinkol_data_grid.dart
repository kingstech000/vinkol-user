import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// One label/value pair in a [VinkolDataGrid].
class VinkolDatum {
  const VinkolDatum({
    required this.label,
    required this.value,
    this.numeric = false,
  });

  final String label;

  /// Already formatted. A money or distance value must be passed through the market layer
  /// before it gets here.
  final String value;

  /// Renders in tabular figures. Set it for money, counts, distances and times.
  final bool numeric;
}

/// A two-column data grid — the detail block on an order, a quote, a receipt.
///
/// Two columns rather than a list of rows because these are *attributes*, not choices:
/// nothing here is tappable, and pairing them halves the vertical space a dense screen
/// spends on reference data.
class VinkolDataGrid extends StatelessWidget {
  const VinkolDataGrid({super.key, required this.data, this.columns = 2})
      : assert(columns == 1 || columns == 2,
            'One or two columns. Three does not fit 390pt.');

  final List<VinkolDatum> data;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < data.length; i += columns) {
      final pair = data.skip(i).take(columns).toList();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var j = 0; j < columns; j++) ...<Widget>[
              if (j > 0) const SizedBox(width: 13),
              Expanded(
                child: j < pair.length
                    ? _Cell(datum: pair[j])
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
      if (i + columns < data.length) {
        rows.add(const SizedBox(height: 17));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.datum});

  final VinkolDatum datum;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          datum.label,
          style: VinkolType.caption.copyWith(color: v.textTertiary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          datum.value,
          style: (datum.numeric ? VinkolType.num : VinkolType.h4)
              .copyWith(color: v.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// An event on a delivery's timeline.
///
/// The dot is the Line's node at its smallest scale: filled once the event has happened,
/// hollow while it has not. The time sits on the end axis in tabular figures so a column of
/// events aligns (signature #4).
class VinkolEventRow extends StatelessWidget {
  const VinkolEventRow({
    super.key,
    required this.title,
    required this.meta,
    this.time,
    this.date,
    this.done = false,
    this.showDivider = true,
  });

  final String title;

  /// Where it happened, or who did it.
  final String meta;

  final String? time;
  final String? date;

  /// Past events are filled; future ones are not.
  final bool done;

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: showDivider
            ? BorderDirectional(bottom: BorderSide(color: v.borderSubtle))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 5),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? v.brand : v.borderStrong,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: VinkolType.h4.copyWith(
                    color: done ? v.textPrimary : v.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: VinkolType.caption.copyWith(color: v.textTertiary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (time != null) ...<Widget>[
            const SizedBox(width: VinkolSpace.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  time!,
                  style: VinkolType.num.copyWith(
                    color: v.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
                if (date != null)
                  Text(
                    date!,
                    style: VinkolType.caption.copyWith(color: v.textTertiary),
                    textAlign: TextAlign.end,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A quick-action tile — the row of shortcuts under a hero.
///
/// Equal-width and icon-above-label so three or four sit in a row without any of them
/// looking like the primary action. The primary action is a button, not a tile.
class VinkolQuickAction extends StatefulWidget {
  const VinkolQuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<VinkolQuickAction> createState() => _VinkolQuickActionState();
}

class _VinkolQuickActionState extends State<VinkolQuickAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = !widget.enabled || widget.onTap == null;

    final tile = AnimatedContainer(
      duration: VinkolMotion.respecting(context, VinkolMotion.instant),
      curve: VinkolMotion.standard,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: VinkolSpace.sm,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: _pressed ? v.surfaceAlt : v.surface,
        borderRadius: VinkolRadius.brMd,
        border: VinkolElevation.hairline(v),
        boxShadow: VinkolElevation.e1(v),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            widget.icon,
            size: 22,
            color: disabled ? v.textTertiary : v.brand,
          ),
          const SizedBox(height: 9),
          Text(
            widget.label,
            style: VinkolType.labelS.copyWith(
              letterSpacing: 0,
              color: disabled ? v.textTertiary : v.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (disabled) return tile;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: tile,
      ),
    );
  }
}

/// A horizontally scrolling row of filter chips.
///
/// Bleeds to the screen edges — the negative margin in `.chips` — so a scrollable row reads
/// as scrollable instead of looking like a centred group that happens to be cut off.
class VinkolChipRow extends StatelessWidget {
  const VinkolChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.pageMargin = VinkolSpace.pageMargin,
  });

  final List<String> labels;

  /// Null selects nothing — a filter row with no filter applied.
  final int? selectedIndex;

  final ValueChanged<int> onSelected;

  /// The page margin this row is bleeding past.
  final double pageMargin;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsetsDirectional.only(start: pageMargin, end: pageMargin),
      physics: const ClampingScrollPhysics(),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < labels.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 9),
            VinkolChip(
              label: labels[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single chip. Selected state is a fill plus the label — never a colour shift alone.
class VinkolChip extends StatefulWidget {
  const VinkolChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? leading;

  @override
  State<VinkolChip> createState() => _VinkolChipState();
}

class _VinkolChipState extends State<VinkolChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = widget.onTap == null;

    final Color fill;
    final Color ink;
    final Color edge;
    if (widget.selected) {
      fill = disabled ? v.surfaceStrong : v.brand;
      ink = disabled ? v.textTertiary : v.onBrand;
      edge = disabled ? v.borderSubtle : v.brand;
    } else {
      fill = _pressed ? v.surfaceAlt : v.surface;
      ink = disabled ? v.textTertiary : v.textSecondary;
      edge = v.borderSubtle;
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: !disabled,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.fast),
          curve: VinkolMotion.standard,
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 17,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: VinkolRadius.brFull,
            border: Border.fromBorderSide(BorderSide(color: edge)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.leading != null) ...<Widget>[
                Icon(widget.leading, size: 16, color: ink),
                const SizedBox(width: 7),
              ],
              Text(
                widget.label,
                style: VinkolType.label.copyWith(color: ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
