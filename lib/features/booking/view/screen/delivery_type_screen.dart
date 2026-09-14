import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/view/widget/order_type_copy.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

/// Step one of a booking: the shape of the delivery. Each option draws its
/// shape with the Line at glyph scale, so the difference is visible before
/// the words are read. Choosing one sets the order type and moves on to the
/// stops.
class DeliveryTypeScreen extends ConsumerWidget {
  const DeliveryTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(rideLocationProvider);
    // Only a booking with an address on it is "in progress"; a fresh entry
    // has the provider's default type, which is nobody's choice yet.
    final inProgress = booking.stops.any((s) => s.location != null);
    final current = inProgress ? booking.orderType : null;

    return Scaffold(
      appBar: MiniAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.h1(
                'How are you sending?',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: VinkolPalette.neutral900,
                letterSpacing: -0.4,
              ),
              Gap.h6,
              AppText.body(
                'Pick the shape of the delivery. You set the addresses next.',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: VinkolPalette.neutral500,
                lineHeight: 1.4,
              ),
              Gap.h24,
              for (final type in OrderType.values) ...[
                _TypeOption(
                  type: type,
                  isCurrent: type == current,
                  onTap: () {
                    ref.read(rideLocationProvider.notifier).setOrderType(type);
                    NavigationService.instance
                        .navigateTo(NavigatorRoutes.deliveryStopsScreen);
                  },
                ),
                if (type != OrderType.values.last) Gap.h12,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One shape. [isCurrent] marks the type already on the booking in progress
/// so a customer coming back knows which one they were on — a label and a
/// brand hairline, never colour alone.
class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.type,
    required this.isCurrent,
    required this.onTap,
  });

  final OrderType type;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${type.title}. ${type.description}',
      child: Material(
        color: VinkolPalette.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: isCurrent ? VinkolPalette.brand500 : AppColors.background,
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                SizedBox(
                  width: 40.w,
                  height: 52.h,
                  child: _ShapeGlyph(type: type),
                ),
                Gap.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText.body(
                            type.title,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: VinkolPalette.neutral900,
                          ),
                          if (isCurrent) ...[
                            Gap.w8,
                            AppText.caption(
                              'CURRENT',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: VinkolPalette.brand600,
                              letterSpacing: 0.6,
                            ),
                          ],
                        ],
                      ),
                      Gap.h2,
                      AppText.caption(
                        type.description,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: VinkolPalette.neutral500,
                        lineHeight: 1.3,
                      ),
                    ],
                  ),
                ),
                Gap.w8,
                Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 18.w,
                  color: VinkolPalette.neutral400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The Line at glyph scale: a hollow origin, filled destinations, rules
/// between. Standard is one column of two; bulk fans one origin to three;
/// multi is two independent columns side by side.
class _ShapeGlyph extends StatelessWidget {
  const _ShapeGlyph({required this.type});

  final OrderType type;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ShapePainter(type));
  }
}

class _ShapePainter extends CustomPainter {
  const _ShapePainter(this.type);

  final OrderType type;

  static const _node = 4.0;
  static const _stroke = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rule = Paint()
      ..color = VinkolPalette.neutral300
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke;
    final origin = Paint()
      ..color = VinkolPalette.neutral500
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke;
    final destination = Paint()
      ..color = VinkolPalette.brand500
      ..style = PaintingStyle.fill;

    void column(double x, double top, double bottom, {int stops = 1}) {
      // Rule first so the nodes sit on top of it.
      canvas.drawLine(Offset(x, top), Offset(x, bottom), rule);
      canvas.drawCircle(Offset(x, top), _node, origin);
      if (stops == 1) {
        canvas.drawCircle(Offset(x, bottom), _node, destination);
        return;
      }
      // One origin, several destinations spaced down the rule.
      final span = bottom - top;
      for (var i = 1; i <= stops; i++) {
        final y = top + span * i / stops;
        canvas.drawCircle(Offset(x, y), _node, destination);
      }
    }

    const top = _node + _stroke;
    final bottom = size.height - _node - _stroke;

    switch (type) {
      case OrderType.standard:
        column(size.width / 2, top, bottom);
      case OrderType.bulk:
        column(size.width / 2, top, bottom, stops: 3);
      case OrderType.multi:
        column(size.width * 0.3, top, bottom);
        column(size.width * 0.7, top, bottom);
    }
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) => oldDelegate.type != type;
}
