import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/model/delivery_item.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/delivery/model/order_status.dart';
import 'package:starter_codes/features/delivery/view/widget/order_status_widgets.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/widgets/gap.dart';

class DeliveryListItem extends ConsumerWidget {
  final DeliveryItem item;
  final DeliveryModel originalDeliveryModel;

  const DeliveryListItem({
    super.key,
    required this.item,
    required this.originalDeliveryModel,
  });

  bool get _isPackageDelivery =>
      originalDeliveryModel.orderType?.toLowerCase() == 'delivery';

  void _open(WidgetRef ref) {
    ref.read(selectedDeliveryProvider.notifier).state = originalDeliveryModel;

    final orderType = originalDeliveryModel.orderType?.toLowerCase();
    if (orderType == 'delivery') {
      NavigationService.instance.navigateTo(NavigatorRoutes.bookingOrderScreen);
    } else {
      if (orderType != 'storedelivery') {
        debugPrint('Unknown order type: ${originalDeliveryModel.orderType}');
      }
      NavigationService.instance.navigateTo(NavigatorRoutes.storeOrderScreen);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The card says its status once. While the order is on its way the stage
    // track is the status — it answers "where is it" and "what comes next" in
    // one stroke, so a pill repeating the current stage above it is noise.
    // Once the order has finished, the outcome is the whole story and the pill
    // carries it on its own.
    final status = OrderStatus.parse(originalDeliveryModel.status);
    final inProgress = status.isInProgress;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: BorderRadius.circular(12.r),
        // border: Border.all(color: VinkolPalette.neutral200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _open(ref),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  reference: _reference,
                  subtitle: _subtitle,
                  imageUrl: _productImageUrl,
                  outcome: inProgress ? null : OrderStatusStyle.of(status),
                ),
                if (inProgress) ...[
                  Gap.h16,
                  OrderStageTrack(status: status),
                ],
                Gap.h16,
                _MetaRow(
                  timestamp: _timestamp,
                  delivery: originalDeliveryModel,
                ),
                Gap.h12,
                const Divider(
                    height: 1, thickness: 1, color: VinkolPalette.neutral100),
                Gap.h12,
                _RouteLine(origin: _origin, destination: _destination),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// What the customer quotes when they call support. The tracking id is the
  /// one meant for humans; the record id is the fallback for older orders.
  String get _reference {
    final tracking = originalDeliveryModel.trackingId;
    if (tracking != null && tracking.trim().isNotEmpty) {
      return tracking.trim().toUpperCase();
    }
    final id = item.orderId;
    if (id.isEmpty) return '—';
    return id.substring(0, id.length > 8 ? 8 : id.length).toUpperCase();
  }

  String get _subtitle {
    final parts = <String>[
      _isPackageDelivery ? 'Package delivery' : 'Store order',
    ];

    final deliveryType = originalDeliveryModel.deliveryType;
    if (deliveryType != null && deliveryType.trim().isNotEmpty) {
      parts.add(_titleCase(deliveryType.trim()));
    }

    final itemCount = originalDeliveryModel.totalItemsOrdered;
    if (!_isPackageDelivery && itemCount > 0) {
      parts.add(itemCount == 1 ? '1 item' : '$itemCount items');
    }

    return parts.join(' · ');
  }

  /// Store orders can carry a real product photo. Package deliveries never do,
  /// which is what the parcel asset stands in for.
  String? get _productImageUrl {
    final products = originalDeliveryModel.products;
    if (products == null || products.isEmpty) return null;
    final url = products.first.imageUrl;
    return (url != null && url.trim().isNotEmpty) ? url : null;
  }

  String get _origin {
    if (_isPackageDelivery) {
      return originalDeliveryModel.pickupLocation ??
          originalDeliveryModel.pickup?.location?.address ??
          'Pickup not set';
    }
    final store = originalDeliveryModel.store;
    if (store?.name != null && store!.name!.trim().isNotEmpty) {
      return store.name!;
    }
    return originalDeliveryModel.pickupLocation ?? 'Pickup not set';
  }

  String get _destination =>
      originalDeliveryModel.dropoffLocation ?? item.address;

  /// `21-01-2026 5:29 PM` reads as `21 Jan 2026 · 5:29 PM`. The raw string is
  /// kept whenever it does not parse, so an unexpected server format still
  /// shows something true rather than nothing.
  String get _timestamp {
    final date = originalDeliveryModel.date?.trim();
    final time = originalDeliveryModel.time?.trim();
    if (date == null || date.isEmpty) return item.timestamp;

    final pretty = prettyOrderDate(date);
    if (time == null || time.isEmpty) return pretty;
    return '$pretty · $time';
  }
}

String _titleCase(String value) =>
    value[0].toUpperCase() + value.substring(1).toLowerCase();

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.reference,
    required this.subtitle,
    required this.imageUrl,
    required this.outcome,
  });

  final String reference;
  final String subtitle;
  final String? imageUrl;

  /// The pill for a finished order. Null while the order is still on its way,
  /// when the stage track below the header carries the status instead.
  final OrderStatusStyle? outcome;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ParcelThumbnail(imageUrl: imageUrl),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.h3(
                reference,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: VinkolPalette.neutral900,
                letterSpacing: 0.4,
                maxLines: 1,
              ),
              Gap.h4,
              AppText.caption(
                subtitle,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: VinkolPalette.neutral500,
                maxLines: 1,
              ),
            ],
          ),
        ),
        if (outcome != null) ...[
          Gap.w8,
          OrderStatusPill(status: outcome!),
        ],
      ],
    );
  }
}

/// The parcel tile. A store order shows what was bought; everything else shows
/// the parcel asset, which is why it sits on a tinted ground rather than
/// floating on the card.
class _ParcelThumbnail extends StatelessWidget {
  const _ParcelThumbnail({required this.imageUrl});

  final String? imageUrl;

  static const _asset = 'assets/images/package-image.png';

  Widget get _parcel => Image.asset(_asset, fit: BoxFit.contain);

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    // The parcel asset sits straight on the card — it is already a shape on
    // transparency, so a tile behind it only adds an edge to nothing. A real
    // product photo is a rectangle and still needs the rounded clip, and keeps
    // the tinted ground underneath it while it loads.
    return SizedBox(
      width: 52.w,
      height: 52.w,
      child: url == null
          ? _parcel
          : Container(
              decoration: BoxDecoration(
                color: VinkolPalette.neutral50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _parcel,
              ),
            ),
    );
  }
}

/// When the order was placed, and what it cost. The amount is right-aligned on
/// the card's edge so amounts line up down the list, and the currency symbol is
/// set a step lighter so the number stays the hero.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.timestamp, required this.delivery});

  final String timestamp;
  final DeliveryModel delivery;

  @override
  Widget build(BuildContext context) {
    final money = delivery.amountDue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.caption(
                'Ordered',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.neutral400,
                letterSpacing: 0.6,
              ),
              Gap.h2,
              AppText.body(
                timestamp.isEmpty ? '—' : timestamp,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: VinkolPalette.neutral700,
                maxLines: 1,
              ),
            ],
          ),
        ),
        Gap.w12,
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.body(
              money.currency.symbol,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: VinkolPalette.neutral500,
            ),
            AppText.h3(
              money.format(showSymbol: false),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: VinkolPalette.neutral900,
            ),
          ],
        ),
      ],
    );
  }
}

/// The route, drawn as the vertical line the design system uses at every scale:
/// a hollow origin, a filled destination, a rule joining them. Vertical rather
/// than the reference's side-by-side split because Nigerian and Canadian
/// addresses are both far too long to survive half a card's width.
class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.origin, required this.destination});

  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5.h),
          child: Column(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: VinkolPalette.neutral400, width: 2),
                ),
              ),
              Container(
                width: 2,
                height: 22.h,
                color: VinkolPalette.neutral200,
              ),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: VinkolPalette.brand500,
                ),
              ),
            ],
          ),
        ),
        Gap.w10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.body(
                origin,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: VinkolPalette.neutral600,
                maxLines: 1,
              ),
              Gap.h12,
              AppText.body(
                destination,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: VinkolPalette.neutral900,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
