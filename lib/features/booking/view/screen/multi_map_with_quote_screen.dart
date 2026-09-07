import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/models.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/booking/view/widget/quote/order_checkout.dart';
import 'package:starter_codes/features/booking/view/widget/quote/payment_source_selector.dart';
import 'package:starter_codes/features/booking/view/widget/quote/quote_map_scaffold.dart';
import 'package:starter_codes/features/booking/view/widget/quote/quote_summary.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// Batch — `orderType: "Multi"`. Several independent deliveries booked in one go, each with
/// its own pickup, its own drop-off, its own rider and its own price. One failing does not
/// affect the others, which is the whole reason it is not multi-drop.
class MultiMapWithQuoteScreen extends ConsumerStatefulWidget {
  const MultiMapWithQuoteScreen({super.key});

  @override
  ConsumerState<MultiMapWithQuoteScreen> createState() =>
      _MultiMapWithQuoteScreenState();
}

class _MultiMapWithQuoteScreenState
    extends ConsumerState<MultiMapWithQuoteScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};
  bool _isLoading = false;
  MarketPaymentProvider? _chosenPaymentSource;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _plotRoutes());
  }

  /// One route per delivery, each in that delivery's hue. The colour is the only thing tying
  /// a line on the map to a card in the sheet, so it comes from the shared order ramp rather
  /// than being invented per screen.
  Future<void> _plotRoutes() async {
    final MultiOrderQuoteResponse? quote =
        ref.read(rideLocationProvider).multiOrderQuoteResponse;
    if (quote == null || quote.orders.isEmpty) return;

    final List<Color> hues = context.vinkol.orderHues;
    final List<LatLng> allPoints = <LatLng>[];
    final Set<Marker> markers = <Marker>{};
    final Set<Polyline> polylines = <Polyline>{};

    for (int i = 0; i < quote.orders.length; i++) {
      final MultiOrderItem order = quote.orders[i];
      final Color color = hues[i % hues.length];
      final double hue = HSLColor.fromColor(color).hue;

      final LatLng pickup =
          LatLng(order.pickupLocation.lat, order.pickupLocation.lng);
      final LatLng dropoff =
          LatLng(order.dropoffLocation.lat, order.dropoffLocation.lng);
      allPoints.addAll(<LatLng>[pickup, dropoff]);

      markers
        ..add(Marker(
          markerId: MarkerId('pickup_$i'),
          position: pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: context.l10n.bookingDeliveryPickup(i + 1),
            snippet: order.pickupLocation.address ?? '',
          ),
        ))
        ..add(Marker(
          markerId: MarkerId('dropoff_$i'),
          position: dropoff,
          icon: BitmapDescriptor.defaultMarkerWithHue((hue + 30) % 360),
          infoWindow: InfoWindow(
            title: context.l10n.bookingDeliveryDropOff(i + 1),
            snippet: order.dropoffLocation.address ?? '',
          ),
        ));

      polylines.add(Polyline(
        polylineId: PolylineId('route_$i'),
        points: await routeBetween(pickup, dropoff),
        color: color,
        width: 4,
      ));
    }

    if (!mounted) return;
    setState(() {
      _markers
        ..clear()
        ..addAll(markers);
      _polylines
        ..clear()
        ..addAll(polylines);
    });

    final LatLngBounds? bounds = boundsFor(allPoints);
    if (bounds != null) {
      await _mapController
          ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    }
  }

  Future<void> _confirmBooking(MarketPaymentProvider paymentSource) async {
    final MultiOrderQuoteResponse? quote =
        ref.read(rideLocationProvider).multiOrderQuoteResponse;
    if (quote == null) return;

    setState(() => _isLoading = true);
    try {
      final response =
          await ref.read(bookingServiceProvider).createMultiOrderNew(
                orderRequest: CreateNewMultiOrderRequest(
                  quoteId: quote.quote,
                  paymentSource: paymentSource.id,
                ),
              );
      if (mounted) await routeAfterOrder(context, ref, response, isBatch: true);
    } catch (e) {
      if (mounted) showBookingError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final MultiOrderQuoteResponse? quote =
        ref.watch(rideLocationProvider).multiOrderQuoteResponse;

    if (quote == null) {
      return Scaffold(
        backgroundColor: v.canvas,
        body: SafeArea(
          child: VinkolStateView.empty(
            icon: Icons.inventory_2_outlined,
            title: context.l10n.bookingNoMultiOrderQuoteAvailable,
            message: context.l10n.bookingNoDeliveryOptionsBody,
            action: VinkolStateAction(
              label: context.l10n.bookingChangeTheStops,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      );
    }

    final double? walletBalance =
        ref.watch(walletOverviewViewModelProvider).walletBalance.valueOrNull;
    final MarketPaymentProvider paymentSource = resolvePaymentSource(
      chosen: _chosenPaymentSource,
      walletBalance: walletBalance,
      amount: quote.totalAmount,
    );

    return QuoteMapScaffold(
      initialCameraPosition: CameraPosition(
        target: quote.orders.isNotEmpty
            ? LatLng(quote.orders.first.pickupLocation.lat,
                quote.orders.first.pickupLocation.lng)
            : const LatLng(6.5244, 3.3792),
        zoom: 13,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _plotRoutes();
      },
      initialSheetSize: 0.52,
      minSheetSize: 0.38,
      maxSheetSize: 0.92,
      children: <Widget>[
        QuoteStats(
          cells: <({String label, String value})>[
            (label: l10n.bookingDeliveries, value: '${quote.totalOrders}'),
            (
              label: l10n.bookingDistance,
              value: MarketFormat.distance(quote.orders.fold<double>(
                  0, (double sum, MultiOrderItem o) => sum + o.distance)),
            ),
            (label: l10n.bookingRiders, value: '${quote.orders.length}'),
          ],
        ),
        VinkolSectionHeader(
          label: l10n.bookingDeliveries,
          meta: l10n.bookingPricedSeparately,
        ),
        for (int i = 0; i < quote.orders.length; i++)
          _BatchQuoteCard(order: quote.orders[i], index: i),
        const SizedBox(height: VinkolSpace.sm),
        QuoteMoneyCard(
          subtotal: quote.totalAmount,
          hint: l10n.bookingEachTrackedSeparately,
          lines: <({String amount, String label})>[
            (
              label: l10n.bookingDeliveryCount(quote.orders.length),
              amount: MarketFormat.money(quote.totalAmount),
            ),
          ],
        ),
        const SizedBox(height: VinkolSpace.xxl),
        Text(
          l10n.commonPaymentMethod,
          style: VinkolType.labelS.copyWith(color: v.textTertiary),
        ),
        const SizedBox(height: VinkolSpace.md),
        PaymentSourceField(
          selected: paymentSource,
          amount: quote.totalAmount,
          walletBalance: walletBalance,
          onChanged: (MarketPaymentProvider provider) =>
              setState(() => _chosenPaymentSource = provider),
        ),
        const SizedBox(height: VinkolSpace.xxxl),
        VinkolPrimaryButton(
          label: l10n.bookingReviewAndPay,
          loading: _isLoading,
          onPressed: () => _confirmBooking(paymentSource),
        ),
      ],
    );
  }
}

/// One delivery in the batch quote, in the same hue its route is drawn in on the map.
///
/// The hue is the only link between a line on the map and a price in the sheet, so the card
/// also states its number and its price in words and figures — colour is the third signal.
class _BatchQuoteCard extends StatelessWidget {
  const _BatchQuoteCard({required this.order, required this.index});

  final MultiOrderItem order;
  final int index;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final Color hue = v.orderHues[index % v.orderHues.length];

    return Container(
      margin: const EdgeInsets.only(bottom: VinkolSpace.md),
      padding: const EdgeInsets.all(VinkolSpace.cardPadding),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brMd,
        border: BorderDirectional(
          top: BorderSide(color: v.borderSubtle),
          end: BorderSide(color: v.borderSubtle),
          bottom: BorderSide(color: v.borderSubtle),
          start: BorderSide(color: hue, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: hue,
                  borderRadius: VinkolRadius.brFull,
                ),
              ),
              const SizedBox(width: VinkolSpace.iconToLabel),
              Expanded(
                child: Text(
                  l10n.bookingDeliveryNumber(index + 1),
                  style: VinkolType.h4.copyWith(color: v.textPrimary),
                ),
              ),
              Text(
                MarketFormat.money(order.deliveryFee),
                style: VinkolType.num.copyWith(color: v.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: VinkolSpace.sm),
          Text(
            '${order.pickupLocation.address ?? l10n.bookingPickup} → '
            '${order.dropoffLocation.address ?? l10n.bookingDropOff}',
            style: VinkolType.bodyS.copyWith(color: v.textSecondary),
          ),
          const SizedBox(height: VinkolSpace.xxs),
          Text(
            <String>[
              if (order.receiverContactName?.isNotEmpty == true)
                order.receiverContactName!,
              if (order.description?.isNotEmpty == true) order.description!,
              MarketFormat.distance(order.distance),
            ].join(' · '),
            style: VinkolType.caption.copyWith(color: v.textTertiary),
          ),
        ],
      ),
    );
  }
}
