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
import 'package:starter_codes/features/delivery/view/screen/product_order_modal.dart';
import 'package:starter_codes/features/delivery/view_model/delivery_detail_view_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/provider/navigation_provider.dart';
import 'package:starter_codes/widgets/app_bar/HorizontalDottedLine.dart';
import 'package:starter_codes/widgets/border_icon_button.dart';
import 'package:starter_codes/widgets/circular_network_image.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/dot_spinning_indicator.dart';
import 'package:starter_codes/widgets/reverse_map.dart';

class StoreOrderScreen extends ConsumerStatefulWidget {
  const StoreOrderScreen({super.key});

  @override
  ConsumerState<StoreOrderScreen> createState() => _StoreOrderScreenState();
}

class _StoreOrderScreenState extends ConsumerState<StoreOrderScreen> {
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
                ref.read(comingFromBookingsScreenProvider.notifier).state =
                    false;
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_ios,
                  color: AppColors.black, size: 20.w),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: deliveryDetailsAsync.when(
                data: (delivery) {
                  if (delivery == null) {
                    return Container(color: Colors.grey.shade400);
                  }
                  return ReverseLocationStringMap(
                    pickupLocationString: delivery.store!.address!,
                    dropoffLocationString: delivery.dropoffLocation,
                  );
                },
                loading: () => Container(color: Colors.grey.shade400),
                error: (err, stack) => Container(color: Colors.red.shade100),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Gap.h8,
                          Center(
                            child: Container(
                              width: 40.w,
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                            ),
                          ),
                          Gap.h8,
                          deliveryDetailsAsync.when(
                            data: (delivery) {
                              if (delivery == null) {
                                return const Center(
                                    child: Text('No delivery details found.',
                                        style: TextStyle(color: Colors.white)));
                              }

                              return Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.r),
                                      topRight: Radius.circular(15.r),
                                    ),
                                    child: Container(
                                      color: AppColors.black,
                                      // margin: EdgeInsets.symmetric(
                                      //     horizontal: 10.h, vertical: 5.w),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 15.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(5.r),
                                                decoration: const BoxDecoration(
                                                    color: AppColors.primary,
                                                    shape: BoxShape.circle),
                                                child: Icon(
                                                    Icons.timelapse_outlined,
                                                    color: AppColors.white,
                                                    size: 20.w),
                                              ),
                                              Gap.w8,
                                              AppText.button(
                                                  delivery.status ?? 'Pending',
                                                  color: AppColors.white,
                                                  fontSize: 14.sp),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Gap.h4,
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.r),
                                        topRight: Radius.circular(20.r),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        _WhiteContainer(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
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
                                                                  'Tracking ID copied!');
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'No tracking ID to copy.')));
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
                                                          Gap.w4,
                                                          Icon(
                                                            Icons
                                                                .copy_all_rounded,
                                                            size: 16.w,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    AppText.caption(
                                                        delivery.vehicleRequest ??
                                                            'N/A',
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: 12.sp),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Image.asset(
                                                      ImageAsset.riderBike,
                                                      height: 40.h,
                                                      width: 70.w,
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              AppColors.white,
                                                          boxShadow: const [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black,
                                                                blurRadius: 2)
                                                          ],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .check_circle_outline,
                                                              color:
                                                                  Colors.blue,
                                                              size: 16.w),
                                                          Gap.w4,
                                                          AppText.button(
                                                              delivery.deliveryType ??
                                                                  'N/A',
                                                              fontSize: 12.sp),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Gap.h16,
                                        // Conditionally display rider details
                                        if (delivery.status!.toLowerCase() ==
                                            'picked') ...[
                                          _WhiteContainer(
                                            children: [
                                              Row(
                                                children: [
                                                  // Agent's image and details
                                                  CircularNetworkImage(
                                                    imageUrl: delivery
                                                            .deliveryAgent
                                                            ?.imageUrl ??
                                                        'https://via.placeholder.com/150/FF0000/FFFFFF?Text=User',
                                                  ),
                                                  Gap.w16,
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
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
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Gap.w8,
                                                  // Call and Chat Buttons
                                                  BorderedIconButton(
                                                    icon: Icons.call_outlined,
                                                    onPressed: () {
                                                      LaunchLink.launchPhone(
                                                          delivery.deliveryAgent
                                                                  ?.phone
                                                                  .toString() ??
                                                              '');
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Gap.h16,
                                        ],
                                        // Wrap this GestureDetector around the _WhiteContainer
                                        GestureDetector(
                                          onTap: () {
                                            if (delivery.products != null &&
                                                delivery.products!.isNotEmpty) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductsOrderedModal(
                                                    products:
                                                        delivery.products!,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'No products available for this order.')));
                                            }
                                          },
                                          child: _WhiteContainer(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  AppText.button(
                                                      '${delivery.totalItemsOrdered} Items'),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: AppText.button(
                                                      delivery.totalAmount!
                                                          .toMoney(),
                                                      color: AppColors.primary,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Gap.h8,
                                        _WhiteContainer(
                                          children: [
                                            _LocationInfo(
                                              icon: Icons.location_on,
                                              iconColor: Colors.green,
                                              title: 'Pick-up Location',
                                              address:
                                                  delivery.store?.address ??
                                                      'N/A',
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5.w),
                                                  child: SizedBox(
                                                    height: 60.h,
                                                    child: HorizontalDottedLine(
                                                      direction: Axis.vertical,
                                                      dotSize: 2,
                                                      dotSpace: 5,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Gap.h8,
                                            _LocationInfo(
                                              icon: Icons.location_on,
                                              iconColor: AppColors.primary,
                                              title: 'Drop-off Location',
                                              address:
                                                  delivery.dropoffLocation ??
                                                      'N/A',
                                            ),
                                          ],
                                        ),
                                        Gap.h8,
                                        _WhiteContainer(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                AppText.caption(
                                                    'Delivery Code'),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: AppText.button(
                                                      delivery.orderOtp
                                                          .toString(),
                                                      fontSize: 18),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(child: DotSpinningIndicator()),
                            ),
                            error: (err, stack) => Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                  child: Text('Error: ${err.toString()}',
                                      style:
                                          const TextStyle(color: Colors.red))),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _WhiteContainer extends StatelessWidget {
  const _WhiteContainer({
    this.children = const [],
  });
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.w,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _LocationInfo extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String address;

  const _LocationInfo({
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
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Icon(icon, color: Colors.grey.shade500, size: 15.w),
        ),
        Gap.w8,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.body(title, fontWeight: FontWeight.bold, fontSize: 16.sp),
              AppText.caption(
                address,
                color: Colors.grey.shade600,
                fontSize: 12.sp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
