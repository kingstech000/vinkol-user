import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/extensions/extensions.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/core/utils/text.dart';

class BulkMapWithQuotesScreen extends ConsumerStatefulWidget {
  const BulkMapWithQuotesScreen({super.key});

  @override
  ConsumerState<BulkMapWithQuotesScreen> createState() => _BulkMapWithQuotesScreenState();
}

class _BulkMapWithQuotesScreenState extends ConsumerState<BulkMapWithQuotesScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = false;
  String _selectedPaymentSource = 'Wallet';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setMapAndMarkers();
    });
  }

  void _setMapAndMarkers() async {
    final state = ref.read(rideLocationProvider);
    final bulkQuote = state.bulkQuoteResponse;

    if (bulkQuote == null) return;

    final List<LatLng> latLngs = [];
    final List<PointLatLng> polylinePoints = [];

    setState(() {
      _markers.clear();
      int dropoffCounter = 0;

      // First, add pickup marker from the first route's "from"
      if (bulkQuote.route.isNotEmpty) {
        final firstFrom = bulkQuote.route.first.from;
        final pickupLatLng = LatLng(firstFrom.location.lat, firstFrom.location.lng);
        latLngs.add(pickupLatLng);
        polylinePoints.add(PointLatLng(pickupLatLng.latitude, pickupLatLng.longitude));

        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: pickupLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: 'Pickup',
              snippet: firstFrom.location.address,
            ),
          ),
        );
      }

      // Then, add all "to" locations from the route as dropoffs
      for (int i = 0; i < bulkQuote.route.length; i++) {
        final routeLeg = bulkQuote.route[i];
        final dropoffLatLng = LatLng(routeLeg.to.location.lat, routeLeg.to.location.lng);
        latLngs.add(dropoffLatLng);
        polylinePoints.add(PointLatLng(dropoffLatLng.latitude, dropoffLatLng.longitude));
        dropoffCounter++;

        _markers.add(
          Marker(
            markerId: MarkerId('dropoff_$i'),
            position: dropoffLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'Drop-off $dropoffCounter',
              snippet: routeLeg.to.location.address,
            ),
          ),
        );
      }
    });

    if (latLngs.length >= 2) {
      // Draw polylines using the route order
      _polylines.clear();
      for (int i = 0; i < latLngs.length - 1; i++) {
        try {
          final polyCoords = await createPolyline(
            pickup: polylinePoints[i],
            dropOff: polylinePoints[i + 1],
          );
          if (polyCoords.isNotEmpty) {
            addPolyline(
              polylines: _polylines,
              polylineCoordinates: polyCoords,
              color: AppColors.primary,
              width: 5,
              polylineId: 'route_$i',
            );
          } else {
            _polylines.add(Polyline(
              polylineId: PolylineId('fallback_$i'),
              points: [latLngs[i], latLngs[i + 1]],
              color: AppColors.primary,
              width: 5,
            ));
          }
        } catch (e) {
          log('Error creating polyline $i: $e');
        }
      }

      setState(() {});

      LatLngBounds bounds = _boundsFromLatLngList(latLngs);
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
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
    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
  }

  Future<void> _confirmBooking() async {
    final state = ref.read(rideLocationProvider);
    final bulkQuote = state.bulkQuoteResponse;
    if (bulkQuote == null) return;

    setState(() => _isLoading = true);

    try {
      final bookingService = ref.read(bookingServiceProvider);
      final request = CreateNewBulkOrderRequest(
        quoteId: bulkQuote.quote,
        paymentSource: _selectedPaymentSource,
      );

      final response = await bookingService.createBulkOrderNew(orderRequest: request);

      if (response.authorizationUrl != null && response.authorizationUrl!.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => PaymentWebViewScreen(
                    paymentUrl: response.authorizationUrl!,
                    orderId: response.order?.id ?? '',
                    reference: response.reference ?? '',
                    isStoreOrder: false,
                  )));
        }
      } else {
        if (mounted) {
          NavigationService.instance.navigateToReplaceAll(
            NavigatorRoutes.paymentVerificationScreen,
            argument: {
              'orderId': response.order?.id ?? '',
              'reference': response.reference ?? '',
              'isStoreOrder': false,
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppStatusDialogs.showError(context, 'Booking Error', e is Failure ? e.message : e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideLocationProvider);
    final bulkQuote = state.bulkQuoteResponse;

    if (bulkQuote == null) {
      return const Scaffold(body: Center(child: Text('No bulk quote available.')));
    }

    final walletState = ref.watch(walletOverviewViewModelProvider);
    final double? walletBalance = walletState.walletBalance.valueOrNull;
    final bool isWalletInsufficient = walletBalance != null && bulkQuote.totalAmount > walletBalance;

    if (isWalletInsufficient && _selectedPaymentSource == 'Wallet') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedPaymentSource = 'Paystack');
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => NavigationService.instance.goBack(),
          child: Container(
            padding: EdgeInsets.all(8.w),
            margin: EdgeInsets.only(left: 20.w, top: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.w),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: state.stops.first.location!.coordinates!, zoom: 14),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(bottom: 400.h),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap.h14,
                      Center(child: Container(width: 50.w, height: 5.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r)))),
                      Gap.h20,
                      _buildQuoteSummary(bulkQuote),
                      Gap.h24,
                      Text('Route Details', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Gap.h12,
                      ...bulkQuote.route.map((route) => _buildRouteLeg(route)).toList(),
                      Gap.h24,
                      Text('Payment Method', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Gap.h12,
                      _buildPaymentSelector(walletBalance, isWalletInsufficient),
                      Gap.h32,
                      _buildConfirmButton(),
                      Gap.h32,
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSummary(BulkQuoteResponse quote) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('Total Amount', quote.totalAmount.toMoney(), Icons.payments_outlined),
          _buildSummaryItem('Distance', '${quote.totalDistance} km', Icons.directions_bike),
          _buildSummaryItem('Stops', '${quote.stops}', Icons.location_on_outlined),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24.sp),
        Gap.h8,
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildRouteLeg(BulkRoute leg) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, color: Colors.green, size: 12.sp),
              Gap.w8,
              Expanded(child: Text(leg.from.location.address ?? 'Pickup', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700))),
            ],
          ),
          Container(margin: EdgeInsets.only(left: 5.w, top: 4.h, bottom: 4.h), width: 2.w, height: 15.h, color: Colors.grey.shade300),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 12.sp),
              Gap.w8,
              Expanded(child: Text(leg.to.location.address ?? 'Drop-off', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600))),
            ],
          ),
          Gap.h8,
          Divider(color: Colors.grey.shade50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${leg.distance} km', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
              Text(leg.price.toMoney(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector(double? walletBalance, bool isInsufficient) {
    return GestureDetector(
      onTap: () => _showPaymentMethodPicker(walletBalance, isInsufficient),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(_selectedPaymentSource == 'Wallet' ? Icons.account_balance_wallet : Icons.credit_card, color: AppColors.primary),
            Gap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedPaymentSource, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    _selectedPaymentSource == 'Wallet'
                        ? (isInsufficient ? 'Insufficient funds' : 'Balance: ${walletBalance?.toMoney() ?? "₦0.00"}')
                        : 'Pay securely with card',
                    style: TextStyle(fontSize: 12.sp, color: isInsufficient && _selectedPaymentSource == 'Wallet' ? Colors.red : Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodPicker(double? walletBalance, bool isInsufficient) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.h3('Select Payment Method', fontSize: 16.sp, fontWeight: FontWeight.bold),
            Gap.h24,
            _buildPaymentOption('Wallet', Icons.account_balance_wallet, isInsufficient, isInsufficient ? 'Insufficient funds' : 'Balance: ${walletBalance?.toMoney() ?? "₦0.00"}'),
            Gap.h16,
            _buildPaymentOption('Paystack', Icons.credit_card, false, 'Pay securely with card'),
            Gap.h32,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, bool disabled, String subtitle) {
    final selected = _selectedPaymentSource == title;
    return GestureDetector(
      onTap: disabled
          ? null
          : () {
              setState(() => _selectedPaymentSource = title);
              Navigator.pop(context);
            },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade50 : (selected ? AppColors.primary.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: disabled ? Colors.grey.shade400 : (selected ? AppColors.primary : Colors.grey.shade600)),
            Gap.w16,
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: disabled ? Colors.grey.shade400 : Colors.black87)),
              Text(subtitle, style: TextStyle(fontSize: 12.sp, color: disabled ? Colors.red.shade300 : Colors.grey.shade500)),
            ])),
            if (selected) Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 0,
        ),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Confirm Bulk Booking', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
