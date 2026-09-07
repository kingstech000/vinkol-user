import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/models.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/booking/view/widget/quote/order_checkout.dart';
import 'package:starter_codes/features/booking/view/widget/quote/payment_source_selector.dart';
import 'package:starter_codes/features/booking/view/widget/quote/quote_map_scaffold.dart';
import 'package:starter_codes/features/booking/view/widget/quote/quote_summary.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// Multi-drop — `orderType: "Bulk"`. One pickup, several drop-offs, chained into a single
/// route carried by one rider.
class BulkMapWithQuotesScreen extends ConsumerStatefulWidget {
  const BulkMapWithQuotesScreen({super.key});

  @override
  ConsumerState<BulkMapWithQuotesScreen> createState() =>
      _BulkMapWithQuotesScreenState();
}

class _BulkMapWithQuotesScreenState
    extends ConsumerState<BulkMapWithQuotesScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};
  bool _isLoading = false;
  MarketPaymentProvider? _chosenPaymentSource;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _plotRoute());
  }

  /// Plots the chained route: the pickup, then every drop-off in the order the quote returned
  /// them, joined leg by leg. The order is the product here — it is what the price is for.
  Future<void> _plotRoute() async {
    final BulkQuoteResponse? quote =
        ref.read(rideLocationProvider).bulkQuoteResponse;
    if (quote == null || quote.route.isEmpty) return;

    final List<LatLng> stops = <LatLng>[
      LatLng(quote.route.first.from.location.lat,
          quote.route.first.from.location.lng),
      for (final BulkRoute leg in quote.route)
        LatLng(leg.to.location.lat, leg.to.location.lng),
    ];

    final Set<Marker> markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: stops.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: context.l10n.bookingPickup,
          snippet: quote.route.first.from.location.address,
        ),
      ),
      for (int i = 0; i < quote.route.length; i++)
        Marker(
          markerId: MarkerId('dropoff_$i'),
          position: stops[i + 1],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: context.l10n.bookingStopNumber(i + 1),
            snippet: quote.route[i].to.location.address,
          ),
        ),
    };

    final Set<Polyline> polylines = <Polyline>{};
    for (int i = 0; i < stops.length - 1; i++) {
      polylines.add(Polyline(
        polylineId: PolylineId('route_$i'),
        points: await routeBetween(stops[i], stops[i + 1]),
        color: context.vinkol.brand,
        width: 5,
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

    final LatLngBounds? bounds = boundsFor(stops);
    if (bounds != null) {
      await _mapController
          ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  Future<void> _confirmBooking(MarketPaymentProvider paymentSource) async {
    final BulkQuoteResponse? quote =
        ref.read(rideLocationProvider).bulkQuoteResponse;
    if (quote == null) return;

    setState(() => _isLoading = true);
    try {
      final response =
          await ref.read(bookingServiceProvider).createBulkOrderNew(
                orderRequest: CreateNewBulkOrderRequest(
                  quoteId: quote.quote,
                  paymentSource: paymentSource.id,
                ),
              );
      if (mounted) await routeAfterOrder(context, ref, response);
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
    final state = ref.watch(rideLocationProvider);
    final BulkQuoteResponse? quote = state.bulkQuoteResponse;

    if (quote == null) {
      return Scaffold(
        backgroundColor: v.canvas,
        body: SafeArea(
          child: VinkolStateView.empty(
            icon: Icons.alt_route_outlined,
            title: context.l10n.bookingNoBulkQuoteAvailable,
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
        target: LatLng(quote.route.first.from.location.lat,
            quote.route.first.from.location.lng),
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _plotRoute();
      },
      initialSheetSize: 0.65,
      minSheetSize: 0.4,
      maxSheetSize: 0.9,
      children: <Widget>[
        QuoteStats(
          cells: <({String label, String value})>[
            (label: l10n.bookingStops, value: '${quote.stops}'),
            (
              label: l10n.bookingDistance,
              value: MarketFormat.distance(quote.totalDistance)
            ),
            (label: l10n.bookingRider, value: '1'),
          ],
        ),
        VinkolSectionHeader(
          label: l10n.bookingRoute,
          meta: l10n.bookingInThisOrder,
        ),
        QuoteCard(
          children: <Widget>[
            QuoteLegRow(
              marker: '',
              markerIsOrigin: true,
              showDivider: false,
              title:
                  quote.route.first.from.location.address ?? l10n.bookingPickup,
              meta: l10n.bookingCollectAll(quote.route.length),
            ),
            for (int i = 0; i < quote.route.length; i++)
              QuoteLegRow(
                marker: '${i + 1}',
                title: quote.route[i].to.location.address ??
                    l10n.bookingStopNumber(i + 1),
                meta: quote.route[i].to.name ?? l10n.bookingDropOff,
                value: MarketFormat.distance(quote.route[i].distance),
              ),
          ],
        ),
        VinkolSectionHeader(label: l10n.bookingPrice),
        QuoteMoneyCard(
          subtotal: quote.totalAmount,
          hint: l10n.bookingQuotedAsOneRoute,
          lines: <({String amount, String label})>[
            for (int i = 0; i < quote.route.length; i++)
              (
                label: l10n.bookingStopNumber(i + 1),
                amount: MarketFormat.money(quote.route[i].price),
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
