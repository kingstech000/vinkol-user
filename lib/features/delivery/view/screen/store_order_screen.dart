import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sliding_sheet2/sliding_sheet2.dart';
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
        ref.read(deliveryDetailsViewModelProvider.notifier).fetchDeliveryById(selectedDelivery.id!);
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
      canPop: !isFromBookingScreen, // Prevent pop if coming from booking screen
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (isFromBookingScreen) {
             ref.read(comingFromBookingsScreenProvider.notifier).state = false;
       
          NavigationService.instance.navigateToReplaceAll(NavigatorRoutes.dashboardScreen); // Navigate to dashboard
        } else {
          NavigationService.instance.goBack(); // Normal go back
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
                NavigationService.instance.navigateToReplaceAll(NavigatorRoutes.dashboardScreen); // Navigate to dashboard
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
              child: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.w),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: deliveryDetailsAsync.when(
                data: (delivery) {
                  if (delivery == null) {
                    return Container(color: Colors.grey.shade400); // Placeholder
                  }
                  return ReverseLocationStringMap(
                    pickupLocationString: delivery.store!.address!,
                    dropoffLocationString: delivery.dropoffLocation,
                  );
                },
                loading: () => Container(color: Colors.grey.shade400), // Placeholder for map
                error: (err, stack) => Container(color: Colors.red.shade100), // Error placeholder
              ),
            ),
            SlidingSheet(
              elevation: 8,
              cornerRadius: 20.r,
              snapSpec: const SnapSpec(
                snap: true,
                initialSnap: 0.35,
                snappings: [0.35, 0.5, 0.8, 1.0],
                positioning: SnapPositioning.relativeToSheetHeight,
              ),
              builder: (context, state) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black, // Dark background for the top part of the sheet
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
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
                      Gap.h4,
                      deliveryDetailsAsync.when(
                        data: (delivery) {
                          if (delivery == null) {
                            debugPrint(delivery.toString());
                            return const Center(child: Text('No delivery details found.', style: TextStyle(color: Colors.white)));
                          }

                          bool isPending = delivery.status?.toLowerCase() == 'pending';

                          return Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.w),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(5.r),
                                          decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle),
                                          child: Icon(Icons.timelapse_outlined,
                                              color: AppColors.white, size: 20.w),
                                        ),
                                        Gap.w8,
                                        AppText.button(
                                            isPending ? (delivery.status ?? 'Pending') : 'You are on route to pick up',
                                            color: AppColors.white, fontSize: 14.sp),
                                      ],
                                    ),
                                  ],
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
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                  GestureDetector(
                                                  onTap: () {
                                                    final trackingId = delivery.trackingId;
                                                    if (trackingId != null && trackingId.isNotEmpty) {
                                                      copyToClipboard(context, trackingId,
                                                          successMessage: 'Tracking ID copied!');
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('No tracking ID to copy.')),
                                                      );
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min, // Important! Prevents Row from taking full width
                                                    children: [
                                                      AppText.h5(
                                                        delivery.trackingId ?? 'N/A',
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18.sp,
                                                      ),
                                                      Gap.w4, // Small space between text and icon
                                                      Icon(
                                                        Icons.copy_all_rounded, // Or Icons.content_copy, Icons.copy
                                                        size: 16.w, // Adjust size as needed
                                                        color: Colors.grey.shade600, // Adjust color as needed
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // 
                                                AppText.caption(delivery.vehicleRequest ?? 'N/A',
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12.sp),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  ImageAsset.riderBike, // Placeholder, dynamically choose based on vehicleType
                                                  height: 40.h,
                                                  width: 70.w,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: AppColors.white,
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.black,
                                                            blurRadius: 2)
                                                      ],
                                                      borderRadius:
                                                      BorderRadius.circular(10)),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.check_circle_outline,
                                                          color: Colors.blue, size: 16.w),
                                                      Gap.w4,
                                                      AppText.button(delivery.deliveryType ?? 'N/A', // e.g., 'Express drop off'
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
                                    if (!isPending) ...[
                                    _WhiteContainer(
              children: [
                Row(
                  // Use MainAxisAlignment.spaceBetween to push buttons to the end
                  // and Expanded for the column
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Agent's image and details
                    Row(
                      mainAxisSize: MainAxisSize.min, // Keep this row as small as possible
                      children: [
                        CircularNetworkImage(
                          imageUrl: delivery.deliveryAgent?.imageUrl ??
                              'https://via.placeholder.com/150/FF0000/FFFFFF?Text=User',
                        ),
                        Gap.w16,
                        Expanded( // <--- THIS IS THE KEY CHANGE
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.body(
                                delivery.deliveryAgent?.fullName ?? 'N/A',
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                maxLines: 1, // Limit lines for name
                                overflow: TextOverflow.ellipsis, // Add ellipsis if it overflows
                              ),
                              AppText.caption(
                                delivery.deliveryAgent?.phone ?? 'N/A',
                                color: Colors.grey.shade600,
                                fontSize: 12.sp,
                                maxLines: 1, // Limit lines for phone
                                overflow: TextOverflow.ellipsis, // Add ellipsis if it overflows
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Call and Chat Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min, // Keep this row as small as possible
                      children: [
                        BorderedIconButton(
                          icon: Icons.call_outlined,
                          onPressed: () {
                            LaunchLink.launchPhone(delivery.deliveryAgent!.phone.toString());
                          },
                        ),
             
                      ],
                    ),
                  ]
                ),
              ],
            ),    Gap.h16,
                                    ],
                                    // Wrap this GestureDetector around the _WhiteContainer
                                    GestureDetector(
                                      onTap: () {
                                        if (delivery.products != null && delivery.products!.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductsOrderedModal(
                                                products: delivery.products!,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('No products available for this order.')),
                                          );
                                        }
                                      },
                                      child: _WhiteContainer(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              AppText.button('${delivery.totalItemsOrdered} Items'),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: AppText.button(
                                                  delivery.totalAmount!.toMoney(),
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
                                        Gap.h16,
                                        _LocationInfo(
                                          icon: Icons.location_on,
                                          iconColor: AppColors.primary,
                                          title: 'Delivery Location',
                                          address: delivery.dropoffLocation ?? 'N/A',
                                        ),
                                      ],
                                    ),
                                    Gap.h8,
                                    _WhiteContainer(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            AppText.caption('Delivery Code'),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: AppText.button(delivery.orderOtp.toString(), fontSize: 18),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
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
                          child: Center(child: Text('Error: ${err.toString()}', style: const TextStyle(color: Colors.red))),
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