import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ItemDetails {
  final TextEditingController packageNameController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController recipientPhoneController =
      TextEditingController();
  final TextEditingController noteController = TextEditingController();

  void dispose() {
    packageNameController.dispose();
    recipientNameController.dispose();
    recipientPhoneController.dispose();
    noteController.dispose();
  }
}

class PackageInfoScreen extends ConsumerStatefulWidget {
  const PackageInfoScreen({super.key});

  @override
  _PackageInfoScreenState createState() => _PackageInfoScreenState();
}

class _PackageInfoScreenState extends ConsumerState<PackageInfoScreen> {
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<ItemDetails> _items = [];

  late String _pickupTime;
  late String _pickupDate;
  bool _isLoading = false;

  final List<String> _priorityTypes = ['Express', 'Regular'];

  /// The label is what the backend is sent, lowercased. The icon is the whole
  /// reason this is not a dropdown: a vehicle is recognised faster than it is
  /// read.
  final List<({String label, IconData icon})> _vehicleOptions = const [
    (label: 'Bike', icon: PhosphorIconsRegular.motorcycle),
    (label: 'Car', icon: PhosphorIconsRegular.car),
    (label: 'Bicycle', icon: PhosphorIconsRegular.bicycle),
    (label: 'Truck', icon: PhosphorIconsRegular.truck),
  ];

  bool _isInitialized = false;
  ProviderSubscription? _rideLocationSubscription;

  @override
  void initState() {
    super.initState();
    _priorityController.text = _priorityTypes.first;
    _vehicleController.text = _vehicleOptions.first.label;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeItems();
      _rideLocationSubscription =
          ref.listenManual(rideLocationProvider, (previous, next) {
        if (previous?.stops.length != next.stops.length) {
          _initializeItems();
        }
      });
    });
  }

  void _initializeItems() {
    final rideLocationState = ref.read(rideLocationProvider);
    _items.clear();

    if (rideLocationState.orderType == OrderType.standard) {
      _items.add(ItemDetails());
    } else if (rideLocationState.orderType == OrderType.bulk) {
      final dropoffCount =
          rideLocationState.stops.where((s) => !s.isPickup).length;
      for (int i = 0; i < dropoffCount; i++) {
        _items.add(ItemDetails());
      }
    } else if (rideLocationState.orderType == OrderType.multi) {
      final pairCount = rideLocationState.stops.length ~/ 2;
      for (int i = 0; i < pairCount; i++) {
        _items.add(ItemDetails());
      }
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final DateTime now = DateTime.now();
      _pickupDate = DateFormat('dd-MM-yyyy').format(now);
      _pickupTime = TimeOfDay.fromDateTime(now).format(context);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _packageNameController.dispose();
    _priorityController.dispose();
    _vehicleController.dispose();
    _noteController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    _rideLocationSubscription?.close();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
            textTheme: const TextTheme(
              displayMedium:
                  TextStyle(color: AppColors.primary, fontSize: 32.0),
              bodyLarge: TextStyle(color: Colors.blueGrey),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _pickupTime = picked.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime threeMonthsFromNow =
        DateTime(now.year, now.month + 3, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: threeMonthsFromNow,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _pickupDate = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _getQuote() async {
    final rideLocationState = ref.read(rideLocationProvider);
    final pickupLocation = rideLocationState.pickUpLocation;
    final dropOffLocation = rideLocationState.dropOffLocation;
    FocusScope.of(context).unfocus();

    if (rideLocationState.orderType == OrderType.standard) {
      if (pickupLocation == null || dropOffLocation == null) {
        AppStatusDialogs.showError(context, 'Missing Information',
            'Please select both pick-up and drop-off locations first.');
        return;
      }
    } else {
      final allLocationsSelected =
          rideLocationState.stops.every((stop) => stop.location != null);
      if (!allLocationsSelected) {
        AppStatusDialogs.showError(context, 'Missing Information',
            'Please select all locations for your order.');
        return;
      }
    }

    for (int i = 0; i < _items.length; i++) {
      if (_items[i].packageNameController.text.isEmpty) {
        AppStatusDialogs.showError(context, 'Missing Information',
            'Please enter package name for Item ${i + 1}.');
        return;
      }
      if (rideLocationState.orderType != OrderType.standard) {
        if (_items[i].recipientNameController.text.isEmpty) {
          AppStatusDialogs.showError(context, 'Missing Information',
              'Please enter recipient name for Item ${i + 1}.');
          return;
        }
        if (_items[i].recipientPhoneController.text.isEmpty) {
          AppStatusDialogs.showError(context, 'Missing Information',
              'Please enter recipient phone for Item ${i + 1}.');
          return;
        }
      }
    }

    if (_vehicleController.text.isEmpty) {
      AppStatusDialogs.showError(
          context, 'Missing Information', 'Please select a vehicle type.');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final bookingService = ref.read(bookingServiceProvider);

      if (!GuestModeUtils.requireAuthForDelivery(context)) {
        return;
      }

      final user = ref.watch(userProvider);
      final userState = user?.currentState;

      if (userState == null) {
        AppStatusDialogs.showError(
            context, 'Error', 'User state not available. Please try again.');
        return;
      }

      if (rideLocationState.orderType == OrderType.standard) {
        final quoteRequest = GetQuoteRequest(
          userId: user?.id,
          note: _items[0].noteController.text,
          name: _items[0].packageNameController.text,
          pickupTime: _pickupTime,
          pickupDate: _pickupDate,
          pickupLocation: LocationData(
              lat: pickupLocation!.coordinates!.latitude.toString(),
              lng: pickupLocation.coordinates!.longitude.toString(),
              address: pickupLocation.formattedAddress ?? ''),
          dropoffLocation: LocationData(
              lat: dropOffLocation!.coordinates!.latitude.toString(),
              lng: dropOffLocation.coordinates!.longitude.toString(),
              address: dropOffLocation.formattedAddress ?? ''),
          state: userState,
          orderType: 'Delivery',
          vehicleRequest: _vehicleController.text.toLowerCase(),
        );

        final List<QuoteResponseModel> quoteResponse = await bookingService
            .getAllQuotesForDeliveryTypes(
          baseQuoteDetails: quoteRequest,
          market: ref.read(marketProvider),
        );

        ref.read(rideLocationProvider.notifier).setQuoteRequest(quoteRequest);
        ref.read(rideLocationProvider.notifier).setQuoteResponse(quoteResponse);
      } else if (rideLocationState.orderType == OrderType.bulk) {
        final stops = rideLocationState.stops;
        print('=== All Stops ===');
        for (var stop in stops) {
          print(
              'Stop ID: ${stop.id}, isPickup: ${stop.isPickup}, location: ${stop.location}');
        }
        final pickupStop = stops.firstWhere((s) => s.isPickup);
        final pickupLocation = pickupStop.location!;
        final dropoffStops = stops.where((s) => !s.isPickup).toList();
        print('=== Dropoff Stops ===');
        for (var i = 0; i < dropoffStops.length; i++) {
          print(
              'Dropoff $i: ${dropoffStops[i].id}, location: ${dropoffStops[i].location}');
        }

        final bulkQuoteRequest = GetNewBulkQuoteRequest(
          state: userState,
          orderType: 'Delivery',
          pickup: NewBulkPickup(
            location: LatLngNumber(
              lat: pickupLocation.coordinates!.latitude,
              lng: pickupLocation.coordinates!.longitude,
              address: pickupLocation.formattedAddress,
            ),
            pickupContact: _items.isNotEmpty &&
                    _items[0].recipientPhoneController.text.isNotEmpty
                ? _items[0].recipientPhoneController.text
                : '0000000000',
            pickupName: _items.isNotEmpty &&
                    _items[0].recipientNameController.text.isNotEmpty
                ? _items[0].recipientNameController.text
                : 'Sender',
          ),
          dropoffs: List.generate(dropoffStops.length, (i) {
            final dropoffLocation = dropoffStops[i].location!;
            return NewBulkDropoff(
              location: LatLngNumber(
                lat: dropoffLocation.coordinates!.latitude,
                lng: dropoffLocation.coordinates!.longitude,
                address: dropoffLocation.formattedAddress,
              ),
              dropoffContact: _items[i].recipientPhoneController.text,
              dropoffName: _items[i].recipientNameController.text,
            );
          }),
          deliveryType: 'bulk',
          vehicleRequest: _vehicleController.text.toLowerCase(),
          guest: null,
          date: _pickupDate,
          description:
              _items.isNotEmpty ? _items[0].packageNameController.text : '',
          note: _items.isNotEmpty ? _items[0].noteController.text : '',
          userId: user?.id,
        );

        final bulkQuote =
            await bookingService.getBulkQuote(quoteRequest: bulkQuoteRequest);

        ref
            .read(rideLocationProvider.notifier)
            .setBulkQuoteRequest(bulkQuoteRequest);
        ref.read(rideLocationProvider.notifier).setBulkQuoteResponse(bulkQuote);

        NavigationService.instance.navigateTo(
          NavigatorRoutes.bulkMapWithQuoteScreen,
        );
      } else if (rideLocationState.orderType == OrderType.multi) {
        final stops = rideLocationState.stops;
        final multiQuoteRequest = GetNewMultiOrderQuoteRequest(
          orders: List.generate(stops.length ~/ 2, (i) {
            final pickupStop = stops[i * 2];
            final dropoffStop = stops[i * 2 + 1];
            return NewMultiOrderItem(
              pickupLocation: LatLngNumber(
                lat: pickupStop.location!.coordinates!.latitude,
                lng: pickupStop.location!.coordinates!.longitude,
                address: pickupStop.location!.formattedAddress,
              ),
              pickupContact: NewMultiOrderPickupContact(
                name: _items[i].recipientNameController.text.isNotEmpty
                    ? _items[i].recipientNameController.text
                    : 'Sender',
                phone: _items[i].recipientPhoneController.text.isNotEmpty
                    ? _items[i].recipientPhoneController.text
                    : '0000000000',
              ),
              dropoffLocation: LatLngNumber(
                lat: dropoffStop.location!.coordinates!.latitude,
                lng: dropoffStop.location!.coordinates!.longitude,
                address: dropoffStop.location!.formattedAddress,
              ),
              receiverContact: NewMultiOrderPickupContact(
                name: _items[i].recipientNameController.text,
                phone: _items[i].recipientPhoneController.text,
              ),
              state: userState,
              note: _items[i].noteController.text,
              description: _items[i].packageNameController.text,
              vehicleRequest: _vehicleController.text.toLowerCase(),
            );
          }),
          guest: null,
          userId: user?.id,
        );

        final multiQuote = await bookingService.getMultiOrderQuote(
            quoteRequest: multiQuoteRequest);

        ref
            .read(rideLocationProvider.notifier)
            .setMultiOrderQuoteResponse(multiQuote);

        NavigationService.instance.navigateTo(
          NavigatorRoutes.multiMapWithQuoteScreen,
        );
      }

      if (rideLocationState.orderType == OrderType.standard) {
        NavigationService.instance.navigateTo(
          NavigatorRoutes.mapWithQuoteScreen,
        );
      }
    } catch (e) {
      print('Error getting quote: $e');
      AppStatusDialogs.showError(context, 'Error', 'Failed to get quote: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideLocationState = ref.watch(rideLocationProvider);

    return Scaffold(
      appBar: MiniAppBar(
        title: 'Package Info',
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.white,
              Colors.white,
            ],
            stops: const [0.0, 0.2, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildHeader(),
                      SizedBox(height: 32.h),
                      _buildGeneralInfoSection(),
                      SizedBox(height: 32.h),
                      _buildItemsSection(rideLocationState),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Information',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildTimeDatePicker(
                context,
                label: 'Pickup Date',
                value: _pickupDate,
                icon: PhosphorIconsRegular.calendarBlank,
                onTap: () => _selectDate(context),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildTimeDatePicker(
                context,
                label: 'Pickup Time',
                value: _pickupTime,
                icon: PhosphorIconsRegular.clock,
                onTap: () => _selectTime(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _buildFieldLabel('Vehicle Type'),
        SizedBox(height: 8.h),
        _buildVehicleSelector(),
      ],
    );
  }

  /// Four options, all of them on screen. A sheet to choose between four things
  /// costs two taps, hides the alternatives behind the first one, and shows
  /// nothing about what is being chosen. Laid out, the vehicle is one gesture
  /// and the icons carry the meaning.
  Widget _buildVehicleSelector() {
    // IntrinsicHeight so the four tiles stay the same height when a large OS
    // text scale wraps one of the labels onto a second line.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _vehicleOptions.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _buildVehicleTile(_vehicleOptions[i])),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleTile(({String label, IconData icon}) option) {
    final selected = _vehicleController.text == option.label;
    return GestureDetector(
      onTap: () => setState(() => _vehicleController.text = option.label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: 12,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          // Selection is carried by the border weight, the icon, the label
          // weight and the tick together — never by colour on its own.
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.lightgrey,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option.icon,
                  size: 26,
                  color: selected ? AppColors.primary : AppColors.darkgrey,
                ),
                const SizedBox(height: 8),
                AppText.caption(
                  option.label,
                  centered: true,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.black : AppColors.darkgrey,
                ),
              ],
            ),
            if (selected)
              const PositionedDirectional(
                top: 0,
                end: 0,
                child: Icon(
                  PhosphorIconsFill.checkCircle,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(RideLocationState state) {
    String title = 'Package Details';
    if (state.orderType == OrderType.bulk) title = 'Dropoff Items';
    if (state.orderType == OrderType.multi) title = 'Orders Details';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        ...List.generate(_items.length, (index) {
          final item = _items[index];
          String itemLabel = 'Item ${index + 1}';
          if (state.orderType == OrderType.bulk) {
            final dropoff =
                state.stops.where((s) => !s.isPickup).toList()[index];
            itemLabel =
                'Dropoff to: ${dropoff.location?.formattedAddress ?? "Location ${index + 1}"}';
          } else if (state.orderType == OrderType.multi) {
            final pickup = state.stops[index * 2];
            final dropoff = state.stops[index * 2 + 1];
            itemLabel =
                'Order ${index + 1}: ${pickup.location?.formattedAddress ?? "P"}  -→  ${dropoff.location?.address ?? "D"}';
          }

          return Container(
            margin:
                EdgeInsets.only(bottom: index < _items.length - 1 ? 24.h : 0),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                  color: AppColors.greyLight.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_items.length > 1) ...[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      itemLabel,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                _buildInputField(
                  'Package Name',
                  item.packageNameController,
                  hintText: 'Enter package name',
                  icon: PhosphorIconsRegular.package,
                ),
                if (state.orderType != OrderType.standard) ...[
                  SizedBox(height: 16.h),
                  _buildInputField(
                    'Recipient Name',
                    item.recipientNameController,
                    hintText: 'Name',
                    icon: PhosphorIconsRegular.user,
                  ),
                  SizedBox(height: 12.w),
                  _buildInputField(
                    'Recipient Phone',
                    item.recipientPhoneController,
                    hintText: 'Phone',
                    icon: PhosphorIconsRegular.phone,
                  ),
                ],
                SizedBox(height: 16.h),
                _buildInputField(
                  'Special Instructions',
                  item.noteController,
                  hintText: 'Add any special instructions or notes...',
                  maxLines: 2,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          PhosphorIconsRegular.truck,
          color: AppColors.primary,
          size: 28.w,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Package Details',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Tell us about your package',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    String? hintText,
    int? maxLines,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        SizedBox(height: 8.h),
        AppTextField(
          controller: controller,
          maxLines: maxLines,
          hint: hintText,
          prefixIcon: icon != null
              ? Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Icon(
                    icon,
                    size: 20.w,
                    color: AppColors.greyLight,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildTimeDatePicker(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 15.w,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _getQuote,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Quote',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
