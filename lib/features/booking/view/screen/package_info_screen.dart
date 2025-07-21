import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal_form_field.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';

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
              displayMedium: TextStyle(color: AppColors.primary, fontSize: 32.0),
              bodyLarge: TextStyle(color: Colors.blueGrey),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _pickupTime = picked.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime threeMonthsFromNow = DateTime(now.year, now.month + 3, now.day);

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
            dialogTheme: DialogThemeData( // Corrected
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
    if (picked != null) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      final bookingService = ref.read(bookingServiceProvider);

      final quoteRequest = GetQuoteRequest(
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
        state: ref.read(userProvider)!.currentState!,
        orderType: 'Delivery',
        // deliveryType: _priorityController.text.toLowerCase(),
        vehicleRequest: _vehicleController.text.toLowerCase(),
      );

      final List<QuoteResponseModel> quoteResponse =
          await bookingService.getAllQuotesForDeliveryTypes(baseQuoteDetails: quoteRequest);
   

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniAppBar(
        title: 'Package Info',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField('Package Name', _packageNameController,
                        hintText: 'Enter package name'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeDatePicker(
                            context,
                            label: 'Pickup Time',
                            value: _pickupTime,
                            onTap: () => _selectTime(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeDatePicker(
                            context,
                            label: 'Pickup Date',
                            value: _pickupDate,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                      ],
                    ),
                    Gap.h16,
                    // AppText.caption(
                    //   'Priority Type',
                    //   color: AppColors.black,
                    // ),
                    // Gap.h8,
                    // ModalFormField(
                    //   title: 'Priority Type',
                    //   options: _priorityTypes,
                    //   controller: _priorityController,
                    //   onOptionSelected: (value) {
                    //     _priorityController.text = value;
                    //   },
                    // ),
                    // Gap.h16,
                    AppText.caption(
                      'Vehicle Type',
                      color: AppColors.black,
                    ),
                    Gap.h8,
                    ModalFormField(
                      title: 'Vehicle Type',
                      options: _vehicleTypes,
                      controller: _vehicleController,
                      onOptionSelected: (value) {
                        _vehicleController.text = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'Note',
                      _noteController,
                      hintText: 'Add any special instructions',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                title: 'Get Quote',
                loading: _isLoading,
                onTap: _isLoading ? null : _getQuote,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {String? hintText, int? maxLines}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.caption(
          label,
          color: AppColors.black,
        ),
        Gap.h8,
        AppTextField(
          controller: controller,
          maxLines: maxLines,
          hint: hintText,
        ),
      ],
    );
  }

  Widget _buildTimeDatePicker(BuildContext context,
      {required String label,
      required String value,
      required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.caption(
          label,
          color: AppColors.black,
        ),
        Gap.h8,
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.formFillColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}