import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/model/order_status.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The status pieces the deliveries list and the order detail sheets share, so
/// an order reads the same on its row and on its own screen.

// ---------------------------------------------------------------------------
// Status
// ---------------------------------------------------------------------------

/// The status triple — label, shape, color — carried together so no call site
/// can render the color on its own (decision D-05). The label and the closed
/// set come from [OrderStatus]; this only decides how each one looks.
class OrderStatusStyle {
  const OrderStatusStyle({
    required this.label,
    required this.icon,
    required this.color,
    required this.ground,
    required this.isOnTrack,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color ground;

  /// Whether the order is still moving through the stages, so a card knows
  /// whether to draw the stage track.
  final bool isOnTrack;

  static OrderStatusStyle of(OrderStatus status) {
    final (IconData icon, Color color, Color ground) = switch (status.kind) {
      OrderStatusKind.pending => (
          PhosphorIconsRegular.clock,
          VinkolPalette.warningText,
          VinkolPalette.warningGround,
        ),
      OrderStatusKind.withShopper => (
          PhosphorIconsRegular.shoppingBag,
          VinkolPalette.brand600,
          VinkolPalette.brand50,
        ),
      OrderStatusKind.withRider => (
          PhosphorIconsRegular.truck,
          VinkolPalette.brand600,
          VinkolPalette.brand50,
        ),
      OrderStatusKind.delivered => (
          PhosphorIconsFill.checkCircle,
          VinkolPalette.successText,
          VinkolPalette.successGround,
        ),
      // Cancellation is an outcome, not an error, so it reads neutral.
      OrderStatusKind.cancelled => (
          PhosphorIconsRegular.prohibit,
          VinkolPalette.neutral600,
          VinkolPalette.neutral100,
        ),
      OrderStatusKind.unattended => (
          PhosphorIconsRegular.warningCircle,
          VinkolPalette.dangerText,
          VinkolPalette.dangerGround,
        ),
      OrderStatusKind.unknown => (
          PhosphorIconsRegular.question,
          VinkolPalette.neutral600,
          VinkolPalette.neutral100,
        ),
    };

    return OrderStatusStyle(
      label: status.label,
      icon: icon,
      color: color,
      ground: ground,
      isOnTrack: status.isOnTrack,
    );
  }
}

/// The stages every order passes through: placed, in someone's hands, at the
/// door. The server reports a single hand-off status — `Picked` once the goods
/// have been collected — for package and store orders alike, so the track has
/// one hand-off stage, labelled by whoever the server says has the order. Store
/// orders used to get a separate `With shopper` stage the server never sends,
/// which left every store order reading one stage further from delivery than
/// it was.
List<String> orderStages(OrderStatus status) => <String>[
      'Pending',
      status.kind == OrderStatusKind.withShopper ? 'With shopper' : 'With rider',
      'Delivered',
    ];

int orderStageIndex(OrderStatus status) => switch (status.kind) {
      OrderStatusKind.pending => 0,
      OrderStatusKind.withShopper || OrderStatusKind.withRider => 1,
      OrderStatusKind.delivered => 2,
      OrderStatusKind.cancelled ||
      OrderStatusKind.unattended ||
      OrderStatusKind.unknown =>
        0,
    };

class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill({super.key, required this.status});

  final OrderStatusStyle status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: status.ground,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12.w, color: status.color),
          Gap.w4,
          AppText.caption(
            status.label,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: status.color,
          ),
        ],
      ),
    );
  }
}

/// The stage track. Nodes are filled up to and including the current stage,
/// and the connector ahead of it is dashed — the difference is shape, not just
/// color, so it survives grayscale.
class OrderStageTrack extends StatelessWidget {
  const OrderStageTrack({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final stages = orderStages(status);
    final currentIndex = orderStageIndex(status);
    final row = <Widget>[];

    for (var i = 0; i < stages.length; i++) {
      if (i > 0) {
        row.add(
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _Connector(reached: i <= currentIndex),
            ),
          ),
        );
      }
      row.add(_StageNode(
        label: stages[i],
        reached: i <= currentIndex,
        isCurrent: i == currentIndex,
        alignment: i == 0
            ? CrossAxisAlignment.start
            : (i == stages.length - 1
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center),
      ));
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: row);
  }
}

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.label,
    required this.reached,
    required this.isCurrent,
    required this.alignment,
  });

  final String label;
  final bool reached;
  final bool isCurrent;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16.w,
          child: Center(
            child: Container(
              width: isCurrent ? 14.w : 10.w,
              height: isCurrent ? 14.w : 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? VinkolPalette.brand500 : VinkolPalette.white,
                border: Border.all(
                  color: reached
                      ? VinkolPalette.brand500
                      : VinkolPalette.neutral300,
                  width: 2,
                ),
              ),
              child: isCurrent
                  ? Center(
                      child: Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: VinkolPalette.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        Gap.h6,
        AppText.caption(
          label,
          fontSize: 10,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          color: reached ? VinkolPalette.brand600 : VinkolPalette.neutral400,
          maxLines: 1,
        ),
      ],
    );
  }
}

/// Solid where the order has been, dashed where it has not.
class _Connector extends StatelessWidget {
  const _Connector({required this.reached});

  final bool reached;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16.w,
      child: Center(
        child: reached
            ? Container(height: 2, color: VinkolPalette.brand500)
            : LayoutBuilder(
                builder: (context, constraints) {
                  const dash = 3.0;
                  const gap = 3.0;
                  final count = (constraints.maxWidth / (dash + gap))
                      .floor()
                      .clamp(1, 60);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List<Widget>.generate(
                      count,
                      (_) => Container(
                        width: dash,
                        height: 2,
                        color: VinkolPalette.neutral300,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dates
// ---------------------------------------------------------------------------

const _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// `21-01-2026` reads as `21 Jan 2026`. The raw string is kept whenever it
/// does not parse, so an unexpected server format still shows something true
/// rather than nothing.
String prettyOrderDate(String raw) {
  final parts = raw.split('-');
  if (parts.length != 3) return raw;

  // The API writes day-first; a four-digit leading part means it wrote ISO.
  final isIso = parts.first.length == 4;
  final day = int.tryParse(isIso ? parts[2] : parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(isIso ? parts[0] : parts[2]);
  if (day == null || month == null || year == null) return raw;
  if (month < 1 || month > 12) return raw;

  return '$day ${_months[month - 1]} $year';
}
