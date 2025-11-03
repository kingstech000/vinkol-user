import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/copy_to_clipboard_util.dart';
import 'package:starter_codes/core/utils/launch_link.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_detail_view_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/provider/navigation_provider.dart';
import 'package:starter_codes/widgets/circular_network_image.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/dot_spinning_indicator.dart';
import 'package:starter_codes/widgets/reverse_map.dart';

class BookingOrderScreen extends ConsumerStatefulWidget {
  const BookingOrderScreen({super.key});

  @override
  ConsumerState<BookingOrderScreen> createState() => _BookingOrderScreenState();
}

class _BookingOrderScreenState extends ConsumerState<BookingOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDelivery = ref.read(selectedDeliveryProvider);
      if (selectedDelivery != null && selectedDelivery.id != null) {
        ref
            .read(deliveryDetailsViewModelProvider.notifier)
            .fetchDeliveryById(selectedDelivery.id!);
      } else {
        debugPrint('Error: No delivery selected or ID is null.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryDetailsAsync = ref.watch(deliveryDetailsViewModelProvider);
    final isFromBookingScreen = ref.watch(comingFromBookingsScreenProvider);

    return PopScope(
      canPop: !isFromBookingScreen,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (isFromBookingScreen) {
          ref.read(comingFromBookingsScreenProvider.notifier).state = false;
          NavigationService.instance
              .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
        } else {
          NavigationService.instance.goBack();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              if (isFromBookingScreen) {
                NavigationService.instance
                    .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
              } else {
                NavigationService.instance.goBack();
              }
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              margin: EdgeInsets.only(left: 20.w, top: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: AppColors.black, size: 18.w),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: deliveryDetailsAsync.when(
                data: (delivery) {
                  if (delivery == null) {
                    return Container(color: Colors.grey.shade300);
                  }
                  return ReverseLocationStringMap(
                    pickupLocationString: delivery.pickupLocation,
                    dropoffLocationString: delivery.dropoffLocation,
                  );
                },
                loading: () => Container(color: Colors.grey.shade300),
                error: (err, stack) => Container(color: Colors.red.shade100),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.35,
              maxChildSize: 0.95,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag Handle
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Center(
                          child: Container(
                            width: 40.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: deliveryDetailsAsync.when(
                            data: (delivery) {
                              if (delivery == null) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40.w),
                                    child: Column(
                                      children: [
                                        Icon(Icons.inbox_outlined,
                                            size: 64.w,
                                            color: Colors.grey.shade400),
                                        Gap.h16,
                                        Text(
                                          'No delivery details found',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  // Status Banner with gradient
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 16.h,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          Color(0xFF6C63FF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.r),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.delivery_dining_sharp,
                                            color: AppColors.white,
                                            size: 24.w,
                                          ),
                                        ),
                                        Gap.w12,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AppText.caption(
                                                'Delivery Status',
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 11.sp,
                                              ),
                                              AppText.h5(
                                                delivery.status ?? 'Pending',
                                                color: AppColors.white,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Gap.h24,
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    child: Column(
                                      children: [
                                        // Tracking Card
                                        _EnhancedCard(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AppText.caption(
                                                      'Tracking ID',
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 11.sp,
                                                    ),
                                                    Gap.h4,
                                                    GestureDetector(
                                                      onTap: () {
                                                        final trackingId =
                                                            delivery.trackingId;
                                                        if (trackingId !=
                                                                null &&
                                                            trackingId
                                                                .isNotEmpty) {
                                                          copyToClipboard(
                                                            context,
                                                            trackingId,
                                                            successMessage:
                                                                'Tracking ID copied!',
                                                          );
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          AppText.h5(
                                                            delivery.trackingId ??
                                                                'N/A',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18.sp,
                                                          ),
                                                          Gap.w8,
                                                          Icon(
                                                            Icons
                                                                .copy_all_rounded,
                                                            size: 18.w,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Gap.h4,
                                                    AppText.caption(
                                                      delivery.vehicleRequest ??
                                                          '',
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    ImageAsset.riderBike,
                                                    height: 45.h,
                                                    width: 70.w,
                                                  ),
                                                  Gap.h8,
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 6.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.r),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle,
                                                          color:
                                                              AppColors.primary,
                                                          size: 16.w,
                                                        ),
                                                        Gap.w6,
                                                        AppText.button(
                                                          delivery.deliveryType ??
                                                              'N/A',
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Gap.h16,

                                        // Delivery Agent Card
                                        if (delivery.deliveryAgent != null) ...[
                                          _EnhancedCard(
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: AppColors.primary,
                                                      width: 2.w,
                                                    ),
                                                  ),
                                                  child: CircularNetworkImage(
                                                    imageUrl: delivery
                                                            .deliveryAgent
                                                            ?.imageUrl ??
                                                        'https://via.placeholder.com/150',
                                                    width: 50.w,
                                                    height: 50.w,
                                                  ),
                                                ),
                                                Gap.w16,
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AppText.caption(
                                                        'Your Delivery Agent',
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: 11.sp,
                                                      ),
                                                      Gap.h4,
                                                      AppText.body(
                                                        delivery.deliveryAgent
                                                                ?.fullName ??
                                                            'N/A',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.sp,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      AppText.caption(
                                                        delivery.deliveryAgent
                                                                ?.phone ??
                                                            'N/A',
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: 12.sp,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.r),
                                                  ),
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.call,
                                                      color: Colors.white,
                                                      size: 20.w,
                                                    ),
                                                    onPressed: () {
                                                      if (delivery.deliveryAgent
                                                              ?.phone !=
                                                          null) {
                                                        final validatedPhone =
                                                            validateAndFormatPhoneNumber(
                                                                delivery
                                                                    .deliveryAgent!
                                                                    .phone!);
                                                        if (validatedPhone !=
                                                            null) {
                                                          makePhoneCall(
                                                              validatedPhone);
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Invalid phone number format.'),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Gap.h16,
                                        ],

                                        // Location Card
                                        _EnhancedCard(
                                          child: Column(
                                            children: [
                                              _EnhancedLocationInfo(
                                                icon: Icons.trip_origin,
                                                iconColor: Colors.green,
                                                title: 'Pick-up Location',
                                                address:
                                                    delivery.pickupLocation ??
                                                        'N/A',
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16.h),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: 8.w +
                                                            8.w), // Half of container padding + half of icon container size (8.w padding + ~17w for half the container)
                                                    Container(
                                                      width: 2.w,
                                                      height: 40.h,
                                                      decoration:
                                                          const BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Colors.green,
                                                            AppColors.primary
                                                          ],
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              _EnhancedLocationInfo(
                                                icon: Icons.location_on,
                                                iconColor: AppColors.primary,
                                                title: 'Drop-off Location',
                                                address:
                                                    delivery.dropoffLocation ??
                                                        'N/A',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Gap.h16,

                                        // Package Details Card
                                        _EnhancedCard(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.inventory_2_outlined,
                                                    color: AppColors.primary,
                                                    size: 20.w,
                                                  ),
                                                  Gap.w8,
                                                  AppText.h5(
                                                    'Package Details',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.sp,
                                                  ),
                                                ],
                                              ),
                                              Gap.h16,
                                              _DetailRow(
                                                  label: 'Delivery Fee',
                                                  value: delivery.deliveryFee
                                                          ?.toMoney() ??
                                                      ''),
                                              Gap.h12,
                                              _DetailRow(
                                                label: 'Note',
                                                value: (delivery.note != null &&
                                                        delivery
                                                            .note!.isNotEmpty)
                                                    ? delivery.note!
                                                    : 'No Notes',
                                              ),
                                              Gap.h12,
                                              _DetailRow(
                                                label: 'Date & Time',
                                                value:
                                                    '${delivery.date ?? '-'} • ${delivery.time ?? '-'}',
                                              ),
                                              Gap.h16,
                                              Container(
                                                padding: EdgeInsets.all(16.w),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.lock_outline,
                                                          color:
                                                              AppColors.primary,
                                                          size: 20.w,
                                                        ),
                                                        Gap.w8,
                                                        AppText.body(
                                                          'Delivery Code',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ],
                                                    ),
                                                    AppText.h4(
                                                      delivery.orderOtp
                                                          .toString(),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Gap.h24,
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => Padding(
                              padding: EdgeInsets.all(40.w),
                              child:
                                  const Center(child: DotSpinningIndicator()),
                            ),
                            error: (err, stack) => Padding(
                              padding: EdgeInsets.all(40.w),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.error_outline,
                                        size: 48.w, color: Colors.red),
                                    Gap.h16,
                                    Text(
                                      'Unable to load delivery details',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.sp,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EnhancedCard extends StatelessWidget {
  const _EnhancedCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EnhancedLocationInfo extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String address;

  const _EnhancedLocationInfo({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18.w),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.caption(
                title,
                color: Colors.grey.shade600,
                fontSize: 11.sp,
              ),
              Gap.h4,
              AppText.body(
                address,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.caption(
          label,
          color: Colors.grey.shade600,
          fontSize: 12.sp,
        ),
        Gap.h4,
        AppText.body(
          value,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}
