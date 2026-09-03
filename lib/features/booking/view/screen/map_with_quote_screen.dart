import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:starter_codes/core/extensions/extensions.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/map_utils.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/payment/view/payment_webview.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/wallet/view_model/wallet_history_view_model.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/widgets/app_textfield.dart';

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
  String _selectedPaymentSource = 'Wallet'; // Default to Wallet

  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _recipientPhoneController =
      TextEditingController();
  bool _addRecipient = false;

  final List<String> _itemTypes = [
    'Phone', // Phone
    'Electronics', // Electronics
    'Food', // Food
    'Clothes', // Clothes
    'General', // General
    'Documents' // Documents
  ];
  String _selectedItemType = 'General';

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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSnackbar('Error displaying route on map.');
        });
      }
    } else {
      debugPrint(
          '[MapWithQuotesScreen] Missing pickup or dropoff coordinates!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackbar('Missing location details for map display.');
      });
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

      // Update logic: Priority is now the external (Chowdeck) option
      final String deliveryTypeLower =
          _selectedQuote!.deliveryType.toLowerCase();
      final bool isPriority = deliveryTypeLower.contains('priority');
      // Assuming 'express' and 'regular' are Internal
      final String deliveryProvider = isPriority ? 'Chowdeck' : 'Internal';

      debugPrint(
          '[MapWithQuotesScreen] Selected quote details: Type=${_selectedQuote!.deliveryType}, Provider=$deliveryProvider');

      final user = ref.read(userProvider);
      final bookingService = ref.read(bookingServiceProvider);

      final createOrderRequest = CreateOrderRequest(
        state: pickupLocation.state ?? user!.currentState!,
        pickupLocation: pickupLocation,
        dropOffLocation: dropOffLocation,
        packageType: _selectedQuote!.deliveryType,
        packageName: _selectedItemType,
        priorityType: _selectedQuote!.deliveryType,
        vehicleType: _selectedQuote!.vehicleRequest,
        estimatedDeliveryTime: "30-60 min",
        price: finalPrice,
        pickupDate: quoteRequest.pickupDate ??
            DateTime.now().toIso8601String().split('T').first,
        pickupTime: quoteRequest.pickupTime ?? 'Anytime',
        note: quoteRequest.note ?? 'No notes',
        paymentSource: _selectedPaymentSource,
        deliveryProvider: deliveryProvider,
        externalDeliveryFeeId: isPriority ? _selectedQuote!.id : null,
        description: quoteRequest.note ?? "",
        recipientName: _addRecipient ? _recipientNameController.text : null,
        recipientPhone: _addRecipient ? _recipientPhoneController.text : null,
      );

      debugPrint('[MapWithQuotesScreen] Creating order on backend...');
      debugPrint(
          '[MapWithQuotesScreen] Request: ${createOrderRequest.toJson()}');

      final orderInitiationResponse = await bookingService.createOrder(
        orderDetails: createOrderRequest,
      );

      debugPrint(
          '[MapWithQuotesScreen] ===== ORDER CREATED SUCCESSFULLY =====');

      if (orderInitiationResponse.authorizationUrl != null &&
          orderInitiationResponse.authorizationUrl!.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => PaymentWebViewScreen(
                    paymentUrl: orderInitiationResponse.authorizationUrl!,
                    orderId: orderInitiationResponse.order?.id ?? '',
                    reference: orderInitiationResponse.reference ?? '',
                    isStoreOrder: false,
                  )));
          debugPrint('[MapWithQuotesScreen] Navigated to payment WebView');
        }
      } else {
        // Wallet payment or direct success
        if (mounted) {
          NavigationService.instance.navigateToReplaceAll(
            NavigatorRoutes.paymentVerificationScreen,
            argument: {
              'orderId': orderInitiationResponse.order?.id ?? '',
              'reference': orderInitiationResponse.reference ?? '',
              'isStoreOrder': false,
            },
          );
          debugPrint(
              '[MapWithQuotesScreen] Navigated to payment verification (Wallet/Direct)');
        }
      }
    } catch (e, st) {
      debugPrint('[MapWithQuotesScreen] ===== ERROR CREATING ORDER =====');
      debugPrint('[MapWithQuotesScreen] Error: $e');
      debugPrint('[MapWithQuotesScreen] Stack trace: $st');

      String errorMessage = 'An unexpected error occurred.';
      String errorTitle = 'Error';

      if (e is Failure) {
        errorMessage = e.message;
        errorTitle = e.title;
      } else {
        errorMessage = e.toString();
      }

      if (mounted) {
        AppStatusDialogs.showError(context, errorTitle, errorMessage);
      }
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

    // Initialize selection to the first AVAILABLE quote if not valid
    if (_selectedQuote == null || !_selectedQuote!.isAvailable) {
      try {
        _selectedQuote = quoteResponses.firstWhere((q) => q.isAvailable);
      } catch (e) {
        // If none are available, we might still select the first one but it will be disabled?
        // Or just leave it null/first and handle disabled state
        _selectedQuote = quoteResponses.first;
      }
    }

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

    final walletState = ref.watch(walletOverviewViewModelProvider);
    final double? walletBalance = walletState.walletBalance.valueOrNull;

    // Check if wallet should be disabled based on selected quote price
    final bool isWalletInsufficient = _selectedQuote != null &&
        walletBalance != null &&
        (_selectedQuote!.discountedPrice ?? _selectedQuote!.price) >
            walletBalance;

    // Auto-switch to Paystack if Wallet is selected but insufficient
    if (isWalletInsufficient && _selectedPaymentSource == 'Wallet') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedPaymentSource = 'Paystack';
          });
        }
      });
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.w),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
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
            padding: EdgeInsets.only(
                bottom: 350.h), // Adjust map padding for bottom sheet
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.82,
            minChildSize: 0.45,
            maxChildSize: 0.82,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      AppText.h3(
                        'Select Delivery Request',
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        showCloseIcon: true,
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                            quote.unavailableMessage ??
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
                              child: _buildQuoteCard(
                                quote.deliveryType,
                                "30-60 min",
                                quote.price,
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
                      Text(
                        'Package Type',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Gap.h12,
                      // Item Type Dropdown
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedItemType,
                            isExpanded: true,
                            hint: Text(
                              'Select Item Type',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 14.sp),
                            ),
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.grey.shade600),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedItemType = newValue;
                                });
                              }
                            },
                            items: _itemTypes
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                      fontSize: 14.sp, color: Colors.black87),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Gap.h24,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Recipient Details',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Switch.adaptive(
                            value: _addRecipient,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                _addRecipient = value;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_addRecipient) ...[
                        Gap.h12,
                        AppTextField(
                          controller: _recipientNameController,
                          hint: 'Recipient Name',
                          keyboardType: TextInputType.name,
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Icon(Icons.person_outline,
                                color: Colors.grey.shade600),
                          ),
                        ),
                        Gap.h12,
                        AppTextField(
                          controller: _recipientPhoneController,
                          hint: 'Recipient Phone Number',
                          keyboardType: TextInputType.phone,
                          formatter: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Icon(Icons.phone_outlined,
                                color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                      Gap.h24,
                      Text(
                        'Payment Source',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Gap.h12,
                      // Redesigned Payment Selector
                      GestureDetector(
                        onTap: () {
                          _showPaymentMethodPicker(
                              context, walletBalance, isWalletInsufficient);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _selectedPaymentSource == 'Wallet'
                                      ? Icons.account_balance_wallet
                                      : Icons.credit_card,
                                  color: AppColors.primary,
                                  size: 20.sp,
                                ),
                              ),
                              Gap.w16,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedPaymentSource,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (_selectedPaymentSource == 'Wallet') ...[
                                      Gap.h4,
                                      Text(
                                        isWalletInsufficient
                                            ? 'Insufficient funds'
                                            : 'Balance: ${walletBalance?.toMoney() ?? "₦0.00"}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isWalletInsufficient
                                              ? Colors.red
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ] else ...[
                                      Gap.h4,
                                      Text(
                                        'Pay securely with card',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Gap.h32,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ||
                                  (_selectedQuote != null &&
                                      !_selectedQuote!.isAvailable)
                              ? null
                              : _proceedToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Confirm Booking', // Changed from Proceed to Payment
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      // Add extra padding at the bottom for scrolling past safe area
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
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

  void _showPaymentMethodPicker(
      BuildContext context, double? walletBalance, bool isWalletInsufficient) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.h3(
                'Select Payment Method',
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              Gap.h24,
              _buildPaymentDetailOption(
                context,
                'Wallet',
                Icons.account_balance_wallet,
                isWalletInsufficient,
                isWalletInsufficient
                    ? 'Insufficient funds'
                    : 'Balance: ${walletBalance?.toMoney() ?? "₦0.00"}',
              ),
              Gap.h16,
              _buildPaymentDetailOption(
                context,
                'Paystack',
                Icons.credit_card,
                false,
                'Pay securely with card',
              ),
              // Gap.h16,
              // _buildPaymentDetailOption(
              //   context,
              //   'Globus Bank',
              //   Icons.account_balance,
              //   false,
              //   'Pay with Globus Bank',
              // ),
              Gap.h32,
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentDetailOption(BuildContext context, String title,
      IconData icon, bool isDisabled, String subtitle) {
    final bool isSelected = _selectedPaymentSource == title;
    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                if (title == 'Globus Bank') {
                  _selectedPaymentSource = 'Globus';
                } else {
                  _selectedPaymentSource = title;
                }
              });
              Navigator.pop(context);
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.shade50
              : (isSelected
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade200
                : (isSelected ? AppColors.primary : Colors.grey.shade200),
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.shade200
                    : (isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24.sp,
                color: isDisabled
                    ? Colors.grey.shade400
                    : (isSelected ? AppColors.primary : Colors.grey.shade600),
              ),
            ),
            Gap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey.shade400 : Colors.black87,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDisabled
                          ? Colors.red.shade300
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.primary,
                size: 24.sp,
              )
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(
      String title, String time, double price, String description,
      {required bool isExpress,
      required bool isSelected,
      double? discountedPrice,
      bool? hasDiscount,
      bool isAvailable = true,
      String? unavailableMessage}) {
    // Opacity for unavailable state
    final double opacity = isAvailable ? 1.0 : 0.5;

    // Determine type based on title/isExpress
    final bool isPriority = title.toLowerCase().contains('priority');
    final bool isDarkTheme = isExpress || isPriority;

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 200.w,
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color:
              isPriority ? null : (isExpress ? AppColors.black : Colors.white),
          gradient: isPriority
              ? const LinearGradient(
                  colors: [
                    Color(0xFF9C27B0),
                    Color(0xFF00C853)
                  ], // Purple to Green
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image/Header Section
                Container(
                  height: 100.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isPriority || isExpress
                        ? Colors.black
                            .withOpacity(0.1) // Subtle overlay for dark themes
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    // We need AssetImage to work, make sure path is correct
                    image: const DecorationImage(
                      image: AssetImage(ImageAsset.riderBikeImg),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          // Badge Text
                          isPriority
                              ? "Priority+"
                              : (isExpress ? "Express" : "Regular"),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
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
                      // Title
                      Text(
                        isPriority
                            ? "Priority Delivery"
                            : title.toLowerCase() == 'express'
                                ? "Express Delivery"
                                : "Regular Delivery",
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      Gap.h4,
                      // Price Row
                      if (hasDiscount == true &&
                          discountedPrice != null &&
                          isAvailable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              discountedPrice.toMoney(),
                              style: TextStyle(
                                color: isDarkTheme
                                    ? Colors.white
                                    : AppColors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            isAvailable ? price.toMoney() : 'Unavailable',
                            style: TextStyle(
                              decoration: discountedPrice != null &&
                                      hasDiscount == true &&
                                      isAvailable
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor:
                                  isDarkTheme ? Colors.white : AppColors.black,
                              decorationThickness: 3,
                              color:
                                  isDarkTheme ? Colors.white : AppColors.black,
                              fontSize: (discountedPrice != null &&
                                      hasDiscount == true)
                                  ? 14.sp
                                  : 20.sp,
                              fontWeight: (discountedPrice != null &&
                                      hasDiscount == true)
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          if (discountedPrice != null &&
                              hasDiscount == true &&
                              isAvailable) ...[
                            Gap.w8,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        unavailableMessage ?? "Unavailable",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
