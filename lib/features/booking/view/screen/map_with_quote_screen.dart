// lib/features/booking/view/screen/map_with_quote_screen.dart
// UPDATED VERSION - Works with backend payment flow

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/extensions/extensions.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/features/booking/model/request.dart';

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
  QuoteResponseModel? _selectedQuote;

  @override
  void initState() {
    super.initState();
    _initializeScreenData();
  }

  void _initializeScreenData() {
    debugPrint('[MapWithQuotesScreen] Initializing screen data...');
    final quoteResponses = ref.read(rideLocationProvider).quoteResponses;

    if (quoteResponses != null && quoteResponses.isNotEmpty) {
      _selectedQuote = quoteResponses.first;
      debugPrint(
          '[MapWithQuotesScreen] Selected quote initialized: ${_selectedQuote?.deliveryType}');
    } else {
      debugPrint('[MapWithQuotesScreen] WARNING: No quotes available!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackbar(
            'No delivery options available. Please go back and try again.');
      });
    }
    _setMapAndMarkers();
  }

  void _setMapAndMarkers() async {
    debugPrint('[MapWithQuotesScreen] Setting up map markers...');
    final rideLocationState = ref.read(rideLocationProvider);
    final pickupLocation = rideLocationState.pickUpLocation;
    final dropOffLocation = rideLocationState.dropOffLocation;

    if (pickupLocation?.coordinates != null &&
        dropOffLocation?.coordinates != null) {
      final pickupLatLng = pickupLocation!.coordinates!;
      final dropOffLatLng = dropOffLocation!.coordinates!;

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
            } else {
              _polylines.add(Polyline(
                polylineId: const PolylineId('route'),
                points: [pickupLatLng, dropOffLatLng],
                color: AppColors.primary,
                width: 5,
              ));
            }

            LatLngBounds bounds =
                _boundsFromLatLngList([pickupLatLng, dropOffLatLng]);
            _mapController
                ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
          });
        }
      } catch (e, st) {
        debugPrint('[MapWithQuotesScreen] Error setting up route: $e\n$st');
        _showSnackbar('Error displaying route on map.');
      }
    } else {
      debugPrint(
          '[MapWithQuotesScreen] Missing pickup or dropoff coordinates!');
      _showSnackbar('Missing location details for map display.');
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null || x0 > latLng.latitude) x0 = latLng.latitude;
      if (x1 == null || x1 < latLng.latitude) x1 = latLng.latitude;
      if (y0 == null || y0 > latLng.longitude) y0 = latLng.longitude;
      if (y1 == null || y1 < latLng.longitude) y1 = latLng.longitude;
    }
    if (x0 == null || x1 == null || y0 == null || y1 == null) {
      return LatLngBounds(
          southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));
    }
    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }

  /// Creates order on backend and navigates to payment WebView
  Future<void> _proceedToPayment() async {
    debugPrint('[MapWithQuotesScreen] ===== PROCEEDING TO PAYMENT =====');

    if (_selectedQuote == null) {
      debugPrint('[MapWithQuotesScreen] ERROR: No quote selected!');
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
      debugPrint('[MapWithQuotesScreen] ERROR: Missing required data!');
      _showSnackbar('Missing ride details. Please re-enter.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use discounted price if available, otherwise use regular price
      final finalPrice =
          _selectedQuote!.discountedPrice ?? _selectedQuote!.price;

      debugPrint(
          '[MapWithQuotesScreen] Selected delivery type: ${_selectedQuote!.deliveryType}');
      debugPrint(
          '[MapWithQuotesScreen] Original price: ${_selectedQuote!.price}');
      debugPrint(
          '[MapWithQuotesScreen] Discounted price: ${_selectedQuote!.discountedPrice}');
      debugPrint('[MapWithQuotesScreen] Final price: $finalPrice');

      final user = ref.read(userProvider);
      final bookingService = ref.read(bookingServiceProvider);

      // Prepare order request
      final createOrderRequest = CreateOrderRequest(
        state: pickupLocation.state ?? user!.currentState!,
        pickupLocation: pickupLocation,
        dropOffLocation: dropOffLocation,
        packageType: _selectedQuote!.deliveryType,
        packageName: quoteRequest.name ?? 'Package',
        priorityType: _selectedQuote!.deliveryType,
        vehicleType: _selectedQuote!.vehicleRequest,
        estimatedDeliveryTime: "30-60 min",
        price: finalPrice,
        pickupDate: quoteRequest.pickupDate ??
            DateTime.now().toIso8601String().split('T').first,
        pickupTime: quoteRequest.pickupTime ?? 'Anytime',
        note: quoteRequest.note ?? 'No notes',
      );

      debugPrint('[MapWithQuotesScreen] Creating order on backend...');
      debugPrint(
          '[MapWithQuotesScreen] Request: ${createOrderRequest.toJson()}');

      // Call backend to create order and get payment URL
      final orderInitiationResponse = await bookingService.createOrder(
        orderDetails: createOrderRequest,
      );

      debugPrint(
          '[MapWithQuotesScreen] ===== ORDER CREATED SUCCESSFULLY =====');
      debugPrint(
          '[MapWithQuotesScreen] Order ID: ${orderInitiationResponse.order.id}');
      debugPrint(
          '[MapWithQuotesScreen] Payment URL: ${orderInitiationResponse.authorizationUrl}');
      debugPrint(
          '[MapWithQuotesScreen] Reference: ${orderInitiationResponse.reference}');

      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
                  paymentUrl: orderInitiationResponse.authorizationUrl,
                  orderId: orderInitiationResponse.order.id,
                  reference: orderInitiationResponse.reference,
                  isStoreOrder: false,
                )));
        debugPrint('[MapWithQuotesScreen] Navigated to payment WebView');
      }
    } catch (e, st) {
      debugPrint('[MapWithQuotesScreen] ===== ERROR CREATING ORDER =====');
      debugPrint('[MapWithQuotesScreen] Error: $e');
      debugPrint('[MapWithQuotesScreen] Stack trace: $st');

      _showSnackbar('Failed to create order: ${e.toString().split(':').first}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideLocationState = ref.watch(rideLocationProvider);
    final List<QuoteResponseModel>? quoteResponses =
        rideLocationState.quoteResponses;

    if (quoteResponses == null || quoteResponses.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.no_luggage,
                size: 60,
              ),
              SizedBox(
                height: 20,
              ),
              Text('No delivery options available.'),
            ],
          ),
        ),
      );
    }

    _selectedQuote ??= quoteResponses.first;

    final pickupLatLng = rideLocationState.pickUpLocation?.coordinates;
    final dropOffLatLng = rideLocationState.dropOffLocation?.coordinates;
    final user = ref.watch(userProvider);

    CameraPosition initialCameraPosition;
    if (pickupLatLng != null && dropOffLatLng != null) {
      LatLngBounds bounds =
          _boundsFromLatLngList([pickupLatLng, dropOffLatLng]);
      initialCameraPosition = CameraPosition(
        target: bounds.northeast,
        zoom: 14,
      );
    } else {
      initialCameraPosition = const CameraPosition(
        target: LatLng(6.3364, 5.6171), // Default to Benin City, Nigeria
        zoom: 14.0,
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            NavigationService.instance.goBack();
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
                              '[MapWithQuotesScreen] Quote selected: ${quote.deliveryType}');
                        },
                        child: _buildQuoteCard(
                          quote.deliveryType,
                          "30-60 min",
                          quote.price,
                          'Bike Delivery\nNo mixing; just your direct stuff.',
                          isExpress: isExpressQuote,
                          discountedPrice: quote.discountedPrice,
                          isSelected: _selectedQuote == quote,
                          hasDiscount: user?.hasCoupon ?? false,
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

  Widget _buildQuoteCard(
      String title, String time, double price, String description,
      {required bool isExpress,
      required bool isSelected,
      double? discountedPrice,
      bool? hasDiscount}) {
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
                      Icon(
                        Icons.check_circle,
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
                        size: 18.w,
                      ),
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
                if (hasDiscount == true && discountedPrice != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        discountedPrice.toMoney(),
                        style: TextStyle(
                          color: isExpress ? Colors.white : AppColors.black,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price.toMoney(),
                      style: TextStyle(
                        decoration:
                            discountedPrice != null && hasDiscount == true
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        decorationColor:
                            isExpress ? Colors.white : AppColors.black,
                        decorationThickness: 3,
                        color: isExpress ? Colors.white : AppColors.black,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (discountedPrice != null && hasDiscount == true)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1,
                            color: Colors.deepOrange.withOpacity(.4),
                          ),
                        ),
                        child: Text(
                          "20% off",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 14.sp,
                          ),
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
