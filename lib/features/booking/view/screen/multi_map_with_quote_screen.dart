import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/extensions/extensions.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';

class MultiMapWithQuoteScreen extends ConsumerStatefulWidget {
  const MultiMapWithQuoteScreen({super.key});

  @override
  ConsumerState<MultiMapWithQuoteScreen> createState() =>
      _MultiMapWithQuoteScreenState();
}

class _MultiMapWithQuoteScreenState
    extends ConsumerState<MultiMapWithQuoteScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = false;
  String _selectedPaymentSource = 'Wallet';

  // Colour palette for order pairs
  static const List<Color> _orderColors = [
    Color(0xFF6C63FF), // violet
    Color(0xFF00BFA6), // teal
    Color(0xFFFF6B6B), // coral
    Color(0xFFFFB347), // amber
    Color(0xFF48C9B0), // mint
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildMapContent());
  }

  // ─── Map Setup ─────────────────────────────────────────────────────────────

  Future<void> _buildMapContent() async {
    final quote = ref.read(rideLocationProvider).multiOrderQuoteResponse;
    if (quote == null || quote.orders.isEmpty) return;

    final List<LatLng> allPoints = [];
    setState(() => _markers.clear());
    _polylines.clear();

    for (int i = 0; i < quote.orders.length; i++) {
      final order = quote.orders[i];
      final color = _orderColors[i % _orderColors.length];
      final hue = _colorToHue(color);

      final pickup = LatLng(order.pickupLocation.lat, order.pickupLocation.lng);
      final dropoff =
          LatLng(order.dropoffLocation.lat, order.dropoffLocation.lng);

      allPoints.addAll([pickup, dropoff]);

      // Pickup marker
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('pickup_$i'),
          position: pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: 'Order ${i + 1} – Pickup',
            snippet: order.pickupLocation.address ?? '',
          ),
        ));
        // Dropoff marker (slightly different hue for contrast)
        _markers.add(Marker(
          markerId: MarkerId('dropoff_$i'),
          position: dropoff,
          icon: BitmapDescriptor.defaultMarkerWithHue((hue + 30) % 360),
          infoWindow: InfoWindow(
            title: 'Order ${i + 1} – Drop-off',
            snippet: order.dropoffLocation.address ?? '',
          ),
        ));
      });

      // Polyline per order pair
      try {
        final pts = await createPolyline(
          pickup: PointLatLng(pickup.latitude, pickup.longitude),
          dropOff: PointLatLng(dropoff.latitude, dropoff.longitude),
        );
        if (pts.isNotEmpty) {
          addPolyline(
            polylines: _polylines,
            polylineCoordinates: pts,
            color: color,
            width: 4,
            polylineId: 'route_$i',
          );
        } else {
          _polylines.add(Polyline(
            polylineId: PolylineId('fallback_$i'),
            points: [pickup, dropoff],
            color: color,
            width: 4,
          ));
        }
      } catch (e) {
        log('Polyline error for order $i: $e');
      }
    }

    if (mounted) setState(() {});

    if (allPoints.length >= 2 && _mapController != null) {
      final bounds = _boundsFromLatLngList(allPoints);
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (final p in list) {
      if (x0 == null || x0 > p.latitude) x0 = p.latitude;
      if (x1 == null || x1 < p.latitude) x1 = p.latitude;
      if (y0 == null || y0 > p.longitude) y0 = p.longitude;
      if (y1 == null || y1 < p.longitude) y1 = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
  }

  // Maps a Flutter Color to a Google Maps BitmapDescriptor hue value (0–360)
  double _colorToHue(Color color) {
    final HSLColor hsl = HSLColor.fromColor(color);
    return hsl.hue;
  }

  // ─── Confirm Booking ───────────────────────────────────────────────────────

  Future<void> _confirmBooking() async {
    final state = ref.read(rideLocationProvider);
    final quote = state.multiOrderQuoteResponse;
    if (quote == null) return;

    setState(() => _isLoading = true);
    try {
      final bookingService = ref.read(bookingServiceProvider);
      final request = CreateNewMultiOrderRequest(
        quoteId: quote.quote,
        paymentSource: _selectedPaymentSource,
      );

      final response =
          await bookingService.createMultiOrderNew(orderRequest: request);

      if (response.authorizationUrl != null &&
          response.authorizationUrl!.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => PaymentWebViewScreen(
                    paymentUrl: response.authorizationUrl!,
                    orderId: response.order?.id ??
                        (response.orderIds?.isNotEmpty == true
                            ? response.orderIds!.first
                            : ''),
                    reference: response.reference ?? '',
                    isStoreOrder: false,
                    isMultiOrder: true,
                  )));
        }
      } else {
        if (mounted) {
          if (response.order == null && response.orderIds != null) {
            // Wallet success for multi-order
            AppStatusDialogs.showSuccess(
              context,
              'Success',
              'Multi-order booking placed successfully!',
              onClosed: () {
                ref.read(navigationIndexProvider.notifier).state = 2;
                NavigationService.instance
                    .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
              },
            );
          } else {
            NavigationService.instance.navigateToReplaceAll(
              NavigatorRoutes.paymentVerificationScreen,
              argument: {
                'orderId': response.order?.id ??
                    (response.orderIds?.isNotEmpty == true
                        ? response.orderIds!.first
                        : ''),
                'reference': response.reference ?? '',
                'isStoreOrder': false,
                'isMultiOrder': true,
              },
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppStatusDialogs.showError(
          context,
          'Booking Error',
          e is Failure ? e.message : e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideLocationProvider);
    final quote = state.multiOrderQuoteResponse;

    if (quote == null) {
      return const Scaffold(
          body: Center(child: Text('No multi-order quote available.')));
    }

    final walletState = ref.watch(walletOverviewViewModelProvider);
    final double? walletBalance = walletState.walletBalance.valueOrNull;
    final bool isWalletInsufficient =
        walletBalance != null && quote.totalAmount > walletBalance;

    if (isWalletInsufficient && _selectedPaymentSource == 'Wallet') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedPaymentSource = 'Paystack');
      });
    }

    // Initial camera target: first pickup
    final LatLng initialTarget = quote.orders.isNotEmpty
        ? LatLng(quote.orders.first.pickupLocation.lat,
            quote.orders.first.pickupLocation.lng)
        : const LatLng(6.5244, 3.3792);

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
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child:
                Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.w),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: initialTarget, zoom: 13),
            onMapCreated: (controller) {
              _mapController = controller;
              _buildMapContent();
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(bottom: 420.h),
          ),

          // ── Draggable bottom sheet ───────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.52,
            minChildSize: 0.38,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28.r),
                    topRight: Radius.circular(28.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, -5))
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap.h14,
                      Center(
                        child: Container(
                          width: 50.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      Gap.h20,

                      _buildSummaryBanner(quote),
                      Gap.h24,

                      AppText.h5(
                        'Orders Breakdown',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                      Gap.h12,
                      ...List.generate(quote.orders.length,
                          (i) => _buildOrderCard(quote.orders[i], i)),

                      Gap.h24,

                      // ── Payment selector ────────────────────────────────
                      AppText.h5(
                        'Payment Method',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                      Gap.h12,
                      _buildPaymentSelector(
                          walletBalance, isWalletInsufficient),

                      Gap.h32,

                      // ── Confirm button ──────────────────────────────────
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

  // ─── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildSummaryBanner(MultiOrderQuoteResponse quote) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            Icons.payments_outlined,
            quote.totalAmount.toMoney(),
            'Total',
          ),
          _buildDivider(),
          _buildStat(
            Icons.inventory_2_outlined,
            '${quote.totalOrders}',
            'Orders',
          ),
          _buildDivider(),
          _buildStat(
            Icons.route_outlined,
            '${quote.orders.fold(0.0, (sum, o) => sum + o.distance).toStringAsFixed(1)} km',
            'Distance',
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 22.sp),
        Gap.h6,
        AppText.body(value, fontWeight: FontWeight.bold, fontSize: 15.sp),
        AppText.caption(label, color: Colors.grey.shade600, fontSize: 11.sp),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
        width: 1.w, height: 40.h, color: AppColors.primary.withOpacity(0.2));
  }

  Widget _buildOrderCard(MultiOrderItem order, int index) {
    final color = _orderColors[index % _orderColors.length];
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(8.r)),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: AppText.body(
                    order.description?.isNotEmpty == true
                        ? order.description!
                        : 'Order ${index + 1}',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: AppText.caption(
                    order.deliveryFee.toMoney(),
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          // ── Route ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Pickup row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Icon(Icons.circle,
                              color: Colors.green, size: 11.sp),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 4.h),
                          width: 1.5.w,
                          height: 60.h,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                    Gap.w10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.caption('Pickup',
                              color: Colors.grey.shade500, fontSize: 10.sp),
                          AppText.body(
                            order.pickupLocation.address ?? 'Pickup location',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap.h4,
                          if (order.pickupContactName?.isNotEmpty == true)
                            AppText.caption(
                              '${order.pickupContactName} · ${order.pickupContactPhone ?? ""}',
                              color: AppColors.primary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Dropoff row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 5.h),
                      child: Icon(Icons.location_on, color: color, size: 13.sp),
                    ),
                    Gap.w10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.caption('Drop-off',
                              color: Colors.grey.shade500, fontSize: 10.sp),
                          AppText.body(
                            order.dropoffLocation.address ??
                                'Drop-off location',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (order.receiverContactName?.isNotEmpty == true)
                            AppText.caption(
                              '${order.receiverContactName} · ${order.receiverContactPhone ?? ""}',
                              color: color,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap.h10,
                Divider(color: Colors.grey.shade100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.straighten,
                          size: 13.sp, color: Colors.grey.shade500),
                      Gap.w4,
                      AppText.caption(
                        '${order.distance} km',
                        color: Colors.grey.shade500,
                        fontSize: 11.sp,
                      ),
                    ]),
                    if (order.vehicleRequest?.isNotEmpty == true)
                      Row(children: [
                        Icon(Icons.two_wheeler,
                            size: 13.sp, color: Colors.grey.shade500),
                        Gap.w4,
                        AppText.caption(
                          order.vehicleRequest!,
                          color: Colors.grey.shade500,
                          fontSize: 11.sp,
                        ),
                      ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector(double? walletBalance, bool isInsufficient) {
    return GestureDetector(
      onTap: () => _showPaymentPicker(walletBalance, isInsufficient),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              _selectedPaymentSource == 'Wallet'
                  ? Icons.account_balance_wallet
                  : Icons.credit_card,
              color: AppColors.primary,
            ),
            Gap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(_selectedPaymentSource,
                      fontWeight: FontWeight.bold),
                  AppText.caption(
                    _selectedPaymentSource == 'Wallet'
                        ? (isInsufficient
                            ? 'Insufficient funds'
                            : 'Balance: ${walletBalance?.toMoney() ?? "₦0.00"}')
                        : 'Pay securely with card',
                    color: isInsufficient && _selectedPaymentSource == 'Wallet'
                        ? Colors.red
                        : Colors.grey.shade600,
                    fontSize: 12.sp,
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

  void _showPaymentPicker(double? walletBalance, bool isInsufficient) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.h3('Select Payment Method',
                fontSize: 16.sp, fontWeight: FontWeight.bold),
            Gap.h24,
            _buildPaymentOption(
              'Wallet',
              Icons.account_balance_wallet,
              isInsufficient,
              isInsufficient
                  ? 'Insufficient funds'
                  : 'Balance: ${walletBalance?.toMoney() ?? "₦0.00"}',
            ),
            Gap.h16,
            _buildPaymentOption(
              'Paystack',
              Icons.credit_card,
              false,
              'Pay securely with card',
            ),
            Gap.h32,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      String title, IconData icon, bool disabled, String subtitle) {
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
          color: disabled
              ? Colors.grey.shade50
              : (selected ? AppColors.primary.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: disabled
                    ? Colors.grey.shade400
                    : (selected ? AppColors.primary : Colors.grey.shade600)),
            Gap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(title,
                      fontWeight: FontWeight.bold,
                      color: disabled ? Colors.grey.shade400 : Colors.black87),
                  AppText.caption(subtitle,
                      color:
                          disabled ? Colors.red.shade300 : Colors.grey.shade500,
                      fontSize: 12.sp),
                ],
              ),
            ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Confirm Multi-Order Booking',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
      ),
    );
  }
}
