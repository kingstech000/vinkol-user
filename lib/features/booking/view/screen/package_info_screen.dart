import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/modal_form_field.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';

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

  late String _pickupTime;
  late String _pickupDate;
  bool _isLoading = false;

  final List<String> _priorityTypes = ['Express', 'Regular'];
  final List<String> _vehicleTypes = ['Bike', 'Car', 'Bicycle', 'Truck'];

  // Add a flag to ensure initialization happens only once
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Only set default values for controllers here, as they don't depend on context
    _priorityController.text = _priorityTypes.first;
    _vehicleController.text = _vehicleTypes.first;
    // _pickupDate and _pickupTime will be initialized in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Perform context-dependent initialization here, only once
    if (!_isInitialized) {
      final DateTime now = DateTime.now();
      _pickupDate = DateFormat('dd-MM-yyyy').format(now);
      _pickupTime = TimeOfDay.fromDateTime(now).format(context);
      _isInitialized = true; // Set flag to true after initialization
    }
  }

  @override
  void dispose() {
    _packageNameController.dispose();
    _priorityController.dispose();
    _vehicleController.dispose();
    _noteController.dispose();
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
            dialogTheme: DialogThemeData(
              // Corrected
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: AppColors.primary, width: 2.0),
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

    if (pickupLocation == null || dropOffLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please select both pick-up and drop-off locations first.')),
      );
      return;
    }

    if (_packageNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter package name.')),
      );
      return;
    }

    // if (_priorityController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please select a priority type.')),
    //   );
    //   return;
    // }

    if (_vehicleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle type.')),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final bookingService = ref.read(bookingServiceProvider);

      // Check if user is guest and trying to get quote
      if (!GuestModeUtils.requireAuthForDelivery(context)) {
        return; // Auth prompt will be shown by the utility method
      }

      final user = ref.watch(userProvider);
      final userState = user?.currentState;

      if (userState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User state not available. Please try again.')),
        );
        return;
      }

      final quoteRequest = GetQuoteRequest(
        userId: user?.id,
        note: _noteController.text,
        name: _packageNameController.text,
        pickupTime: _pickupTime,
        pickupDate: _pickupDate,
        pickupLocation: LocationData(
            lat: pickupLocation.coordinates!.latitude.toString(),
            lng: pickupLocation.coordinates!.longitude.toString()),
        dropoffLocation: LocationData(
            lat: dropOffLocation.coordinates!.latitude.toString(),
            lng: dropOffLocation.coordinates!.longitude.toString()),
        state: userState,
        orderType: 'Delivery',
        // deliveryType: _priorityController.text.toLowerCase(),
        vehicleRequest: _vehicleController.text.toLowerCase(),
      );

      final List<QuoteResponseModel> quoteResponse = await bookingService
          .getAllQuotesForDeliveryTypes(baseQuoteDetails: quoteRequest);

      ref.read(rideLocationProvider.notifier).setQuoteRequest(quoteRequest);
      ref.read(rideLocationProvider.notifier).setQuoteResponse(quoteResponse);

      NavigationService.instance.navigateTo(
        NavigatorRoutes.mapWithQuoteScreen,
      );
    } catch (e) {
      print('Error getting quote: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get quote: $e')),
      );
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
                      // Header Section
                      _buildHeader(),
                      SizedBox(height: 32.h),

                      // Package Name Field
                      _buildInputField(
                        'Package Name',
                        _packageNameController,
                        hintText: 'Enter package name',
                        icon: Icons.inventory_2_outlined,
                      ),
                      SizedBox(height: 20.h),

                      // Date and Time Pickers
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeDatePicker(
                              context,
                              label: 'Pickup Date',
                              value: _pickupDate,
                              icon: Icons.calendar_today_rounded,
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildTimeDatePicker(
                              context,
                              label: 'Pickup Time',
                              value: _pickupTime,
                              icon: Icons.access_time_rounded,
                              onTap: () => _selectTime(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Vehicle Type Field
                      _buildFieldLabel('Vehicle Type'),
                      SizedBox(height: 8.h),
                      ModalFormField(
                        title: _vehicleController.text.isEmpty
                            ? 'Select vehicle type'
                            : _vehicleController.text,
                        textColor: _vehicleController.text.isEmpty
                            ? AppColors.darkgrey.withOpacity(0.5)
                            : AppColors.black,
                        options: _vehicleTypes,
                        controller: _vehicleController,
                        onOptionSelected: (value) {
                          _vehicleController.text = value;
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Note Field
                      _buildInputField(
                        'Special Instructions',
                        _noteController,
                        hintText: 'Add any special instructions or notes...',
                        maxLines: 4,
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              // Submit Button
              Container(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.local_shipping_rounded,
            color: AppColors.primary,
            size: 28.w,
          ),
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
        fontSize: 15.sp,
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
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    size: 15.w,
                    color: AppColors.primary,
                  ),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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
                      fontSize: 17.sp,
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
