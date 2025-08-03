import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/extensions/extensions.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/provider/navigation_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/provider/payment_provider.dart';
import 'package:starter_codes/features/payment/model/payment_detail_model.dart';
// Import for debugPrint

class MapWithQuotesScreen extends ConsumerStatefulWidget {
  const MapWithQuotesScreen({super.key});

  @override
  ConsumerState<MapWithQuotesScreen> createState() =>
      _MapWithQuotesScreenState();
}

class _MapWithQuotesScreenState extends ConsumerState<MapWithQuotesScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = false;
  QuoteResponseModel? _selectedQuote; // Now holds the *selected* quote

  @override
  void initState() {
    super.initState();
    _initializeScreenData();
  }

  /// Initializes screen data including selected quote and sets up the map.
  void _initializeScreenData() {
    debugPrint('[_initializeScreenData] called.');
    final quoteResponses = ref
        .read(rideLocationProvider)
        .quoteResponses; // Assuming this is now a list
    if (quoteResponses != null && quoteResponses.isNotEmpty) {
      _selectedQuote = quoteResponses.first; // Select the first one by default
      debugPrint(
          '[_initializeScreenData] Selected quote initialized: $_selectedQuote');
    } else {
      debugPrint(
          '[_initializeScreenData] Warning: No quoteResponses found in rideLocationProvider.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackbar(
            'No delivery options available. Please go back and try again.');
        // NavigationService.instance.goBack();
      });
    }
    _setMapAndMarkers();
  }

  /// Sets up Google Map, adds pickup/drop-off markers, and draws polyline.
  void _setMapAndMarkers() async {
    debugPrint('[_setMapAndMarkers] called.');
    final rideLocationState = ref.read(rideLocationProvider);
    final pickupLocation = rideLocationState.pickUpLocation;
    final dropOffLocation = rideLocationState.dropOffLocation;

    if (pickupLocation?.coordinates != null &&
        dropOffLocation?.coordinates != null) {
      final pickupLatLng = pickupLocation!.coordinates!;
      final dropOffLatLng = dropOffLocation!.coordinates!;
      debugPrint(
          '[_setMapAndMarkers] Pickup LatLng: $pickupLatLng, DropOff LatLng: $dropOffLatLng');

      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('pickup_location'),
              position: pickupLatLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(
                  title: pickupLocation.formattedAddress ?? 'Pickup Location'),
            ),
          );
          _markers.add(
            Marker(
              markerId: const MarkerId('dropoff_location'),
              position: dropOffLatLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                  title:
                      dropOffLocation.formattedAddress ?? 'Drop-off Location'),
            ),
          );
          debugPrint('[_setMapAndMarkers] Markers added: ${_markers.length}');
        });
      }

      try {
        final polylineCoordinates = await createPolyline(
          pickup: PointLatLng(pickupLatLng.latitude, pickupLatLng.longitude),
          dropOff: PointLatLng(dropOffLatLng.latitude, dropOffLatLng.longitude),
        );

        if (mounted) {
          setState(() {
            _polylines.clear();
            if (polylineCoordinates.isNotEmpty) {
              addPolyline(
                polylines: _polylines,
                polylineCoordinates: polylineCoordinates,
                color: AppColors.primary,
                width: 5,
              );
              debugPrint(
                  '[_setMapAndMarkers] Polyline added with ${polylineCoordinates.length} points.');
            } else {
              _polylines.add(Polyline(
                polylineId: const PolylineId('route'),
                points: [pickupLatLng, dropOffLatLng],
                color: AppColors.primary,
                width: 5,
              ));
              debugPrint(
                  '[_setMapAndMarkers] Polyline points empty, added fallback straight line.');
            }

            LatLngBounds bounds =
                _boundsFromLatLngList([pickupLatLng, dropOffLatLng]);
            _mapController
                ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
            debugPrint('[_setMapAndMarkers] Camera animated to bounds.');
          });
        }
      } catch (e, st) {
        debugPrint(
            '[_setMapAndMarkers] Error fetching polyline or setting map bounds: $e');
        debugPrint('[_setMapAndMarkers] Stack trace: $st');
        _showSnackbar('Error displaying route on map.');
      }
    } else {
      debugPrint(
          '[_setMapAndMarkers] Pickup or Drop-off coordinates are null. Cannot set map elements.');
      _showSnackbar('Missing location details for map display.');
    }
  }

  /// Calculates LatLngBounds from a list of LatLng points.
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null || x0 > latLng.latitude) x0 = latLng.latitude;
      if (x1 == null || x1 < latLng.latitude) x1 = latLng.latitude;
      if (y0 == null || y0 > latLng.longitude) y0 = latLng.longitude;
      if (y1 == null || y1 < latLng.longitude) y1 = latLng.longitude;
    }
    if (x0 == null || x1 == null || y0 == null || y1 == null) {
      debugPrint(
          '[_boundsFromLatLngList] Warning: Some coordinates were null, defaulting bounds.');
      return LatLngBounds(
          southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));
    }
    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }

  /// Prepares payment details and navigates to the PaymentScreen.
  Future<void> _proceedToPayment() async {
    debugPrint('[_proceedToPayment] called.');
    if (_selectedQuote == null) {
      debugPrint('[_proceedToPayment] _selectedQuote is null.');
      _showSnackbar('Please select a delivery option.');
      return;
    }

    final rideLocationState = ref.read(rideLocationProvider);
    final quoteRequest = rideLocationState.quoteRequest;
    final pickupLocation = rideLocationState.pickUpLocation;
    final dropOffLocation = rideLocationState.dropOffLocation;

    if (quoteRequest == null ||
        pickupLocation == null ||
        dropOffLocation == null) {
      debugPrint(
          '[_proceedToPayment] Missing quote request, pickup, or drop-off location.');
      _showSnackbar('Missing ride details. Please re-enter.');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
      debugPrint('[_proceedToPayment] _isLoading set to true.');
    }

    try {
      final paymentDetails = PaymentDetails(
        quoteResponseModel: _selectedQuote!,
        quoteRequest: quoteRequest,
        reference: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      );
      debugPrint('[_proceedToPayment] PaymentDetails created: $paymentDetails');

      ref.read(paymentDetailsProvider.notifier).state = paymentDetails;
      debugPrint('[_proceedToPayment] PaymentDetails set in provider.');

      if (mounted) {
        NavigationService.instance
            .navigateTo(NavigatorRoutes.deliveryPaymentScreen);
        debugPrint('[_proceedToPayment] Navigated to deliveryPaymentScreen.');
      }
    } catch (e, st) {
      debugPrint('[_proceedToPayment] Error preparing for payment: $e');
      debugPrint('[_proceedToPayment] Stack trace: $st');
      _showSnackbar('Failed to prepare for payment: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('[_proceedToPayment] _isLoading set to false.');
      }
    }
  }

  /// Creates the order after successful payment. Triggered by paymentStatusProvider listener.
  Future<void> _createOrderAfterPayment() async {
    debugPrint('[_createOrderAfterPayment] called.');

    final rideLocationState = ref.read(rideLocationProvider);
    final quoteRequest = rideLocationState.quoteRequest;
    final pickupLocation = rideLocationState.pickUpLocation;
    final dropOffLocation = rideLocationState.dropOffLocation;

    if (_selectedQuote == null) {
      debugPrint('[_createOrderAfterPayment] Error: _selectedQuote is null.');
      _showSnackbar('Could not complete order. Please try again.');
      return;
    }
    if (quoteRequest == null) {
      debugPrint('[_createOrderAfterPayment] Error: quoteRequest is null.');
      _showSnackbar('Missing ride request details for order creation.');
      return;
    }
    if (pickupLocation == null || dropOffLocation == null) {
      debugPrint(
          '[_createOrderAfterPayment] Error: Pick-up or drop-off location is missing.');
      _showSnackbar(
          'Pick-up or drop-off location is missing for order creation.');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
      debugPrint('[_createOrderAfterPayment] _isLoading set to true.');
    }

    try {
      final packageType = _selectedQuote!.deliveryType;
      final packageName = quoteRequest.name ?? 'Unknown Package';
      final priorityType = _selectedQuote!.deliveryType;
      final vehicleType = _selectedQuote!.vehicleRequest;
      const estimatedDeliveryTime = "30-60 min"; // Placeholder
      final price = _selectedQuote!.price;
      final pickupDate = quoteRequest.pickupDate ??
          DateTime.now().toIso8601String().split('T').first;
      final pickupTime = quoteRequest.pickupTime ?? 'Anytime';
      final note = quoteRequest.note ?? '';
      final transRef = ref.watch(paymentDetailsProvider)!.reference;
      final state = ref.watch(userProvider)!.currentState!;
      final bookingService = ref.read(bookingServiceProvider);
      final createOrderRequest = CreateOrderRequest(
        state: state,
        paystackReference: transRef,
        pickupLocation: pickupLocation,
        dropOffLocation: dropOffLocation,
        packageType: packageType,
        packageName: packageName,
        priorityType: priorityType,
        vehicleType: vehicleType,
        estimatedDeliveryTime: estimatedDeliveryTime,
        price: price,
        pickupDate: pickupDate,
        pickupTime: pickupTime,
        note: note,
      );
      debugPrint(
          '[_createOrderAfterPayment] Attempting to create order with details: $createOrderRequest');

      final orderResponse =
          await bookingService.createOrder(orderDetails: createOrderRequest);
      debugPrint(
          '[_createOrderAfterPayment] Order created successfully: $orderResponse');

      if (mounted) {
        ref.read(selectedDeliveryProvider.notifier).state = orderResponse;
        ref.read(comingFromBookingsScreenProvider.notifier).state = true;
        NavigationService.instance
            .navigateToReplaceAll(NavigatorRoutes.bookingOrderScreen);
        debugPrint(
            '[_createOrderAfterPayment] Navigated to bookingOrderScreen.');
      }
    } catch (e, st) {
      debugPrint(
          '[_createOrderAfterPayment] Error creating order after payment: $e');
      debugPrint('[_createOrderAfterPayment] Stack trace: $st');
      _showSnackbar('Failed to create order: ${e.toString().split(':')[0]}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('[_createOrderAfterPayment] _isLoading set to false.');
      }
    }
  }

  /// Helper function to show a snackbar safely.
  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      debugPrint(
          'Attempted to show snackbar but widget was unmounted: $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentStatus>(paymentStatusProvider,
        (previousStatus, newStatus) {
      debugPrint(
          '[MapWithQuotesScreen.build] Payment status changed: $previousStatus -> $newStatus');
      if (newStatus == PaymentStatus.success) {
        debugPrint(
            '[MapWithQuotesScreen.build] Payment successful, attempting to create order...');
        _createOrderAfterPayment();
      } else if (newStatus == PaymentStatus.failed) {
        debugPrint(
            '[MapWithQuotesScreen.build] Payment failed, showing snackbar...');
        _showSnackbar('Payment was not successful. Please try again.');
      }
      ref.read(paymentStatusProvider.notifier).state = PaymentStatus.initial;
      debugPrint(
          '[MapWithQuotesScreen.build] Payment status reset to initial.');
    });

    final rideLocationState = ref.watch(rideLocationProvider);
    final List<QuoteResponseModel>? quoteResponses =
        rideLocationState.quoteResponses; // Now a list

    if (quoteResponses == null || quoteResponses.isEmpty) {
      debugPrint(
          '[MapWithQuotesScreen.build] quoteResponses is null or empty, showing error message.');
      return const Scaffold(
        body: Center(
          child: Text('No delivery options available.'),
        ),
      );
    }

    // Ensure _selectedQuote is set if it's null (e.g., on first build)
    _selectedQuote ??= quoteResponses.first;

    final pickupLatLng = rideLocationState.pickUpLocation?.coordinates;
    final dropOffLatLng = rideLocationState.dropOffLocation?.coordinates;

    CameraPosition initialCameraPosition;
    if (pickupLatLng != null && dropOffLatLng != null) {
      LatLngBounds bounds =
          _boundsFromLatLngList([pickupLatLng, dropOffLatLng]);
      initialCameraPosition = CameraPosition(
        target: bounds.northeast,
        zoom: 14,
      );
      debugPrint(
          '[MapWithQuotesScreen.build] Initial camera position set based on pickup/dropoff bounds.');
    } else {
      initialCameraPosition = const CameraPosition(
        target: LatLng(6.3364, 5.6171), // Default to Benin City, Nigeria
        zoom: 14.0,
      );
      debugPrint(
          '[MapWithQuotesScreen.build] Initial camera position defaulted to Benin City.');
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            NavigationService.instance.goBack();
            debugPrint('[MapWithQuotesScreen.AppBar] Back button tapped.');
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            margin: EdgeInsets.only(left: 20.w, top: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child:
                Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.w),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (controller) {
                _mapController = controller;
                _setMapAndMarkers();
                debugPrint('[MapWithQuotesScreen.GoogleMap] Map created.');
              },
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: quoteResponses.map((quote) {
                      final bool isExpressQuote =
                          quote.deliveryType.toLowerCase() == "express";
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedQuote = quote;
                          });
                          debugPrint(
                              '[MapWithQuotesScreen.QuoteCard] Quote card tapped. Selected: $_selectedQuote');
                        },
                        child: _buildQuoteCard(
                          quote.deliveryType,
                          "30-60 min", // Assuming estimated time is consistent or fetched per quote
                          quote.price,
                          'Bike Delivery\nNo mixing; just your direct stuff.', // Adjust description as needed
                          isExpress: isExpressQuote,
                          isSelected: _selectedQuote == quote,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Gap.h16,
                SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    title: 'Proceed to Payment',
                    loading: _isLoading,
                    onTap: _isLoading ? null : _proceedToPayment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single quote card widget.
  Widget _buildQuoteCard(
      String title, String time, double price, String description,
      {required bool isExpress, required bool isSelected}) {
    return Container(
      width: 250.w,
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isExpress ? AppColors.black : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 3.w)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 2.w,
            blurRadius: 5.w,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isExpress ? AppColors.black : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              image: const DecorationImage(
                image: AssetImage(ImageAsset.riderBike),
                fit: BoxFit.contain,
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          size: 18.w),
                      Gap.w4,
                      AppText.button(
                        title,
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price.toMoney(),
                      style: TextStyle(
                        color: isExpress ? Colors.white : AppColors.black,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
