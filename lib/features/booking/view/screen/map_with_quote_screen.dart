import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/models.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/booking/view/widget/quote/order_checkout.dart';
import 'package:starter_codes/features/booking/view/widget/quote/payment_source_selector.dart';
import 'package:starter_codes/features/booking/view/widget/quote/quote_map_scaffold.dart';
import 'package:starter_codes/features/booking/view/widget/quote/quote_option_card.dart';
import 'package:starter_codes/features/booking/view/widget/quote/single_order_details_fields.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// One pickup, one drop-off — `orderType: "Delivery"`.
///
/// The map chrome, the payment selector and the post-order routing are shared with the
/// multi-drop and batch quote screens; what is left here is what is genuinely specific to a
/// single delivery: choosing between the delivery tiers the quote came back with, and the
/// package and recipient details that go on the one order.
class MapWithQuotesScreen extends ConsumerStatefulWidget {
  const MapWithQuotesScreen({super.key});

  @override
  ConsumerState<MapWithQuotesScreen> createState() =>
      _MapWithQuotesScreenState();
}

class _MapWithQuotesScreenState extends ConsumerState<MapWithQuotesScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};
  bool _isLoading = false;
  QuoteResponseModel? _selectedQuote;
  MarketPaymentProvider? _chosenPaymentSource;

  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _recipientPhoneController =
      TextEditingController();
  bool _addRecipient = false;

  final List<String> _itemTypes = <String>[
    'Phone',
    'Electronics',
    'Food',
    'Clothes',
    'General',
    'Documents'
  ];
  String _selectedItemType = 'General';

  @override
  void initState() {
    super.initState();
    final quoteResponses = ref.read(rideLocationProvider).quoteResponses;
    if (quoteResponses != null && quoteResponses.isNotEmpty) {
      _selectedQuote = quoteResponses.first;
    }
    _setMapAndMarkers();
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    super.dispose();
  }

  Future<void> _setMapAndMarkers() async {
    final rideLocationState = ref.read(rideLocationProvider);
    final pickupLocation = rideLocationState.pickUpLocation;
    final dropOffLocation = rideLocationState.dropOffLocation;

    final LatLng? pickupLatLng = pickupLocation?.coordinates;
    final LatLng? dropOffLatLng = dropOffLocation?.coordinates;
    if (pickupLatLng == null || dropOffLatLng == null) return;

    final List<LatLng> route = await routeBetween(pickupLatLng, dropOffLatLng);
    if (!mounted) return;

    setState(() {
      _markers
        ..clear()
        ..add(Marker(
          markerId: const MarkerId('pickup_location'),
          position: pickupLatLng,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
              title: pickupLocation!.formattedAddress ??
                  context.l10n.bookingPickup),
        ))
        ..add(Marker(
          markerId: const MarkerId('dropoff_location'),
          position: dropOffLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
              title: dropOffLocation!.formattedAddress ??
                  context.l10n.bookingDropOff),
        ));
      _polylines
        ..clear()
        ..add(Polyline(
          polylineId: const PolylineId('route'),
          points: route,
          color: context.vinkol.brand,
          width: 5,
        ));
    });

    final LatLngBounds? bounds =
        boundsFor(<LatLng>[pickupLatLng, dropOffLatLng]);
    if (bounds != null) {
      await _mapController
          ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  /// Creates the order on the backend, then hands off to the shared payment routing.
  Future<void> _proceedToPayment(MarketPaymentProvider paymentSource) async {
    final QuoteResponseModel? quote = _selectedQuote;
    if (quote == null) return;

    final rideLocationState = ref.read(rideLocationProvider);
    final quoteRequest = rideLocationState.quoteRequest;
    final pickupLocation = rideLocationState.pickUpLocation;
    final dropOffLocation = rideLocationState.dropOffLocation;

    if (quoteRequest == null ||
        pickupLocation == null ||
        dropOffLocation == null) {
      showBookingError(context, context.l10n.bookingMissingRideDetails);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double finalPrice = quote.discountedPrice ?? quote.price;

      // "Priority" is fulfilled by Chowdeck; express and regular are carried in-house.
      final bool isPriority =
          quote.deliveryType.toLowerCase().contains('priority');

      final user = ref.read(userProvider);
      final bookingService = ref.read(bookingServiceProvider);

      final createOrderRequest = CreateOrderRequest(
        state: pickupLocation.state ?? user!.currentState!,
        pickupLocation: pickupLocation,
        dropOffLocation: dropOffLocation,
        packageType: quote.deliveryType,
        packageName: _selectedItemType,
        priorityType: quote.deliveryType,
        vehicleType: quote.vehicleRequest,
        estimatedDeliveryTime: "30-60 min",
        price: finalPrice,
        pickupDate: quoteRequest.pickupDate ??
            DateTime.now().toIso8601String().split('T').first,
        pickupTime: quoteRequest.pickupTime ?? 'Anytime',
        note: quoteRequest.note ?? 'No notes',
        paymentSource: paymentSource.id,
        deliveryProvider: isPriority ? 'Chowdeck' : 'Internal',
        externalDeliveryFeeId: isPriority ? quote.id : null,
        description: quoteRequest.note ?? "",
        recipientName: _addRecipient ? _recipientNameController.text : null,
        recipientPhone: _addRecipient ? _recipientPhoneController.text : null,
      );

      final response =
          await bookingService.createOrder(orderDetails: createOrderRequest);

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
    final rideLocationState = ref.watch(rideLocationProvider);
    final List<QuoteResponseModel>? quoteResponses =
        rideLocationState.quoteResponses;

    if (quoteResponses == null || quoteResponses.isEmpty) {
      return Scaffold(
        backgroundColor: v.canvas,
        body: SafeArea(
          child: VinkolStateView.empty(
            icon: Icons.local_shipping_outlined,
            title: context.l10n.bookingNoDeliveryOptionsAvailable,
            message: context.l10n.bookingNoDeliveryOptionsBody,
            action: VinkolStateAction(
              label: context.l10n.bookingChangeTheStops,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      );
    }

    // Fall back to the first quote the courier network can actually serve.
    if (_selectedQuote == null || !_selectedQuote!.isAvailable) {
      _selectedQuote = quoteResponses.firstWhere(
        (QuoteResponseModel q) => q.isAvailable,
        orElse: () => quoteResponses.first,
      );
    }

    final user = ref.watch(userProvider);
    final double? walletBalance =
        ref.watch(walletOverviewViewModelProvider).walletBalance.valueOrNull;
    final double amount =
        _selectedQuote!.discountedPrice ?? _selectedQuote!.price;
    final MarketPaymentProvider paymentSource = resolvePaymentSource(
      chosen: _chosenPaymentSource,
      walletBalance: walletBalance,
      amount: amount,
    );

    final LatLng? pickupLatLng = rideLocationState.pickUpLocation?.coordinates;
    final LatLng? dropOffLatLng =
        rideLocationState.dropOffLocation?.coordinates;
    final LatLngBounds? bounds = boundsFor(<LatLng>[
      if (pickupLatLng != null) pickupLatLng,
      if (dropOffLatLng != null) dropOffLatLng,
    ]);

    return QuoteMapScaffold(
      initialCameraPosition: CameraPosition(
        target: bounds?.northeast ?? const LatLng(6.3364, 5.6171),
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _setMapAndMarkers();
      },
      initialSheetSize: 0.82,
      minSheetSize: 0.45,
      maxSheetSize: 0.82,
      children: <Widget>[
        AppText.h3(
          context.l10n.bookingSelectDeliveryRequest,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        Gap.h16,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quoteResponses.map((quote) {
              final bool isExpressQuote =
                  quote.deliveryType.toLowerCase() == "express";
              return GestureDetector(
                onTap: !quote.isAvailable
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          showCloseIcon: true,
                          behavior: SnackBarBehavior.floating,
                          content: Text(quote.unavailableMessage ??
                              'Not available for this route'),
                        ));
                      }
                    : () {
                        setState(() {
                          _selectedQuote = quote;
                        });
                        debugPrint(
                            '[MapWithQuotesScreen] Quote selected: ${quote.deliveryType}');
                      },
                child: QuoteOptionCard(
                  title: quote.deliveryType,
                  time: "30-60 min",
                  price: quote.price,
                  description:
                      'Bike Delivery\nNo mixing; just your direct stuff.',
                  isExpress: isExpressQuote,
                  discountedPrice: quote.discountedPrice,
                  isSelected: _selectedQuote == quote,
                  hasDiscount: user?.hasCoupon ?? false,
                  isAvailable: quote.isAvailable,
                  unavailableMessage: quote.unavailableMessage,
                ),
              );
            }).toList(),
          ),
        ),
        Gap.h24,
        SingleOrderDetailsFields(
          selectedItemType: _selectedItemType,
          itemTypes: _itemTypes,
          onItemTypeChanged: (String value) =>
              setState(() => _selectedItemType = value),
          addRecipient: _addRecipient,
          onAddRecipientChanged: (bool value) =>
              setState(() => _addRecipient = value),
          recipientNameController: _recipientNameController,
          recipientPhoneController: _recipientPhoneController,
        ),
        Gap.h24,
        Text(
          context.l10n.bookingPaymentSource,
          style: VinkolType.labelS.copyWith(color: v.textTertiary),
        ),
        Gap.h12,
        PaymentSourceField(
          selected: paymentSource,
          amount: amount,
          walletBalance: walletBalance,
          onChanged: (MarketPaymentProvider provider) =>
              setState(() => _chosenPaymentSource = provider),
        ),
        Gap.h32,
        VinkolPrimaryButton(
          label: context.l10n.bookingConfirmBooking,
          loading: _isLoading,
          onPressed: _selectedQuote!.isAvailable
              ? () => _proceedToPayment(paymentSource)
              : null,
        ),
      ],
    );
  }
}
