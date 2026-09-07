import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/booking/data/booking_service.dart';
import 'package:starter_codes/features/booking/data/quote_request_builder.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/item_details.dart';
import 'package:starter_codes/features/booking/view/widget/package_info/get_quote_button.dart';
import 'package:starter_codes/features/booking/view/widget/package_info/package_general_info_section.dart';
import 'package:starter_codes/features/booking/view/widget/package_info/package_info_header.dart';
import 'package:starter_codes/features/booking/view/widget/package_info/package_items_section.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/l10n/l10n.dart';

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
  final List<String> _vehicleTypes = ['Bike', 'Car', 'Bicycle', 'Truck'];

  bool _isInitialized = false;
  ProviderSubscription? _rideLocationSubscription;

  @override
  void initState() {
    super.initState();
    _priorityController.text = _priorityTypes.first;
    _vehicleController.text = _vehicleTypes.first;

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

    // Multi-drop and batch collect their package and recipient per stop, in their own
    // editors, because the API models them per stop: asking for five packages at the end,
    // indexed by number, made people match "Item 3" to an address from memory.
    if (rideLocationState.orderType == OrderType.standard) {
      _items.add(ItemDetails());
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // The home card already asked when to collect; starting from that answer means the
      // user is not asked the same question twice. Null there means now.
      final DateTime at =
          ref.read(rideLocationProvider).pickupAt ?? DateTime.now();
      _pickupDate = DateFormat('dd-MM-yyyy').format(at);
      _pickupTime = TimeOfDay.fromDateTime(at).format(context);
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
    } else if (!rideLocationState.isReadyForQuote) {
      AppStatusDialogs.showError(context, 'Missing Information',
          'Every stop needs an address, a package and a recipient.');
      return;
    }

    for (int i = 0; i < _items.length; i++) {
      if (_items[i].packageNameController.text.isEmpty) {
        AppStatusDialogs.showError(context, 'Missing Information',
            'Please enter package name for Item ${i + 1}.');
        return;
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
        final quoteRequest = QuoteRequestBuilder.standard(
          user: user,
          userState: userState,
          item: _items[0],
          pickupLocation: pickupLocation!,
          dropOffLocation: dropOffLocation!,
          pickupTime: _pickupTime,
          pickupDate: _pickupDate,
          vehicleRequest: _vehicleController.text.toLowerCase(),
        );

        final List<QuoteResponseModel> quoteResponse = await bookingService
            .getAllQuotesForDeliveryTypes(baseQuoteDetails: quoteRequest);

        ref.read(rideLocationProvider.notifier).setQuoteRequest(quoteRequest);
        ref.read(rideLocationProvider.notifier).setQuoteResponse(quoteResponse);
      } else if (rideLocationState.orderType == OrderType.bulk) {
        final bulkQuoteRequest = QuoteRequestBuilder.bulk(
          user: user,
          userState: userState,
          state: rideLocationState,
          pickupDate: _pickupDate,
          vehicleRequest: _vehicleController.text.toLowerCase(),
          senderFallbackName: context.l10n.bookingSender,
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
        final multiQuoteRequest = QuoteRequestBuilder.multiOrder(
          user: user,
          userState: userState,
          state: rideLocationState,
          vehicleRequest: _vehicleController.text.toLowerCase(),
          senderFallbackName: context.l10n.bookingSender,
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
      debugPrint('Error getting quote: $e');
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
        title: context.l10n.bookingPackageInfo,
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
                      const PackageInfoHeader(),
                      SizedBox(height: 32.h),
                      PackageGeneralInfoSection(
                        pickupDate: _pickupDate,
                        pickupTime: _pickupTime,
                        onSelectDate: () => _selectDate(context),
                        onSelectTime: () => _selectTime(context),
                        vehicleController: _vehicleController,
                        vehicleTypes: _vehicleTypes,
                        onVehicleSelected: (value) {
                          _vehicleController.text = value;
                        },
                      ),
                      SizedBox(height: 32.h),
                      PackageItemsSection(
                          items: _items, state: rideLocationState),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.fromSTEB(24.w, 16.h, 24.w, 24.h),
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
                child:
                    GetQuoteButton(isLoading: _isLoading, onPressed: _getQuote),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
