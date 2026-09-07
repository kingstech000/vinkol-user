import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/design/vinkol_color.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/model/delivery_item.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/widgets/gap.dart';

/// One order in the deliveries list.
///
/// Layout follows the shipment-card reference: a parcel thumbnail and the
/// tracking id on the header row, a stage track through the middle, then the
/// route. Everything on it is backed by a field the API actually returns
/// (decision D-10) — the reference's "4h away" has no ETA behind it, so the
/// stage track is driven by `status` alone and the timestamp shown is the one
/// the order carries.
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
    final status = _StatusStyle.of(originalDeliveryModel.status);
    final stages = _stages(isPackageDelivery: _isPackageDelivery);
    final stageIndex = _stageIndex(stages, originalDeliveryModel.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: VinkolPalette.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: VinkolPalette.neutral200),
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
                  status: status,
                ),
                if (status.isOnTrack) ...[
                  Gap.h16,
                  _StageTrack(stages: stages, currentIndex: stageIndex),
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

    final pretty = _prettyDate(date);
    if (time == null || time.isEmpty) return pretty;
    return '$pretty · $time';
  }
}

const _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _prettyDate(String raw) {
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

String _titleCase(String value) =>
    value[0].toUpperCase() + value.substring(1).toLowerCase();

// ---------------------------------------------------------------------------
// Status
// ---------------------------------------------------------------------------

/// The status triple — label, shape, color — carried together so no call site
/// can render the color on its own (decision D-05). The six values are the
/// closed set the backend returns; anything else falls through to the neutral
/// unknown style rather than being invented.
class _StatusStyle {
  const _StatusStyle({
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

  /// Whether the order is still moving through the stages. Cancelled and
  /// unattended orders left the track, so drawing one for them would lie.
  final bool isOnTrack;

  static _StatusStyle of(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'pending':
        return const _StatusStyle(
          label: 'Pending',
          icon: PhosphorIconsRegular.clock,
          color: VinkolPalette.warningText,
          ground: VinkolPalette.warningGround,
          isOnTrack: true,
        );
      case 'with rider':
        return const _StatusStyle(
          label: 'With rider',
          icon: PhosphorIconsRegular.truck,
          color: VinkolPalette.brand600,
          ground: VinkolPalette.brand50,
          isOnTrack: true,
        );
      case 'with shopper':
        return const _StatusStyle(
          label: 'With shopper',
          icon: PhosphorIconsRegular.shoppingBag,
          color: VinkolPalette.brand600,
          ground: VinkolPalette.brand50,
          isOnTrack: true,
        );
      case 'delivered':
        return const _StatusStyle(
          label: 'Delivered',
          icon: PhosphorIconsFill.checkCircle,
          color: VinkolPalette.successText,
          ground: VinkolPalette.successGround,
          isOnTrack: true,
        );
      case 'cancelled':
        // Cancellation is an outcome, not an error, so it reads neutral.
        return const _StatusStyle(
          label: 'Cancelled',
          icon: PhosphorIconsRegular.prohibit,
          color: VinkolPalette.neutral600,
          ground: VinkolPalette.neutral100,
          isOnTrack: false,
        );
      case 'unattended':
        return const _StatusStyle(
          label: 'Unattended',
          icon: PhosphorIconsRegular.warningCircle,
          color: VinkolPalette.dangerText,
          ground: VinkolPalette.dangerGround,
          isOnTrack: false,
        );
      default:
        return const _StatusStyle(
          label: 'Unknown',
          icon: PhosphorIconsRegular.question,
          color: VinkolPalette.neutral600,
          ground: VinkolPalette.neutral100,
          isOnTrack: false,
        );
    }
  }
}

/// The stages an order passes through, which differ by order type: a shopper
/// buys the goods before a rider carries them.
List<String> _stages({required bool isPackageDelivery}) => isPackageDelivery
    ? const <String>['Pending', 'With rider', 'Delivered']
    : const <String>['Pending', 'With shopper', 'With rider', 'Delivered'];

int _stageIndex(List<String> stages, String? status) {
  final normalized = status?.toLowerCase().trim();
  if (normalized == null) return 0;
  final index = stages.indexWhere((stage) => stage.toLowerCase() == normalized);
  return index < 0 ? 0 : index;
}

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.reference,
    required this.subtitle,
    required this.imageUrl,
    required this.status,
  });

  final String reference;
  final String subtitle;
  final String? imageUrl;
  final _StatusStyle status;

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
        Gap.w8,
        _StatusPill(status: status),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final _StatusStyle status;

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
class _StageTrack extends StatelessWidget {
  const _StageTrack({required this.stages, required this.currentIndex});

  final List<String> stages;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
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
