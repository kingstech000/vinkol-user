import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// The offer to switch to the other multi-stop product.
///
/// Neither editor is a dead end: multi-drop asks whether the parcels really all leave from
/// one place, and batch asks whether they really do not. The API calls these "Bulk" and
/// "Multi", which describe the payload and tell a user nothing, so the row leads with the
/// distinction that decides it — one origin, or several.
class SwitchOrderTypeRow extends StatelessWidget {
  const SwitchOrderTypeRow({
    super.key,
    required this.icon,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    // Not a VinkolRow: that truncates its meta to one line, and the meta here is the entire
    // explanation of what switching would do. A row that ellipses "Switch to Batch — separate
    // pickups, separate…" is worse than no row.
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(VinkolSpace.cardPadding),
          decoration: BoxDecoration(
            color: v.surface,
            borderRadius: VinkolRadius.brMd,
            border: VinkolElevation.hairline(v),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v.surfaceAlt,
                  borderRadius: VinkolRadius.brSm,
                ),
                child: Icon(icon, size: 19, color: v.textSecondary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        style: VinkolType.h4.copyWith(color: v.textPrimary)),
                    const SizedBox(height: VinkolSpace.xxs),
                    Text(meta,
                        style:
                            VinkolType.bodyS.copyWith(color: v.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: VinkolSpace.sm),
              Padding(
                padding: const EdgeInsets.only(top: VinkolSpace.md),
                child:
                    Icon(Icons.chevron_right, size: 16, color: v.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The numbered node on a route: stop 1, stop 2, stop 3.
///
/// Sized by its content with a 26pt floor rather than a fixed 26pt box, so the digit still
/// fits at a 2.0x text scale instead of being clipped by its own badge. Two digits fit too —
/// a ten-stop route is a real order, not an edge case.
class StopMarker extends StatelessWidget {
  const StopMarker({super.key, required this.label, this.isOrigin = false});

  final String label;

  /// The pickup: filled brand with the origin glyph rather than a number.
  final bool isOrigin;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: VinkolSpace.xs, vertical: VinkolSpace.xxs),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isOrigin ? v.brand : v.brandSubtle,
          borderRadius: VinkolRadius.brFull,
          border: Border.fromBorderSide(BorderSide(color: v.borderSubtle)),
        ),
        child: isOrigin
            ? Icon(Icons.trip_origin, size: 13, color: v.onBrand)
            : Text(label, style: VinkolType.label.copyWith(color: v.textBrand)),
      ),
    );
  }
}
