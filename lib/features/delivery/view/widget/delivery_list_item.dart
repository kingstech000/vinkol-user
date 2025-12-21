import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/model/delivery_item.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart';
import 'package:starter_codes/widgets/gap.dart';

class DeliveryListItem extends ConsumerWidget {
  // Changed to ConsumerWidget
  final DeliveryItem item;
  final DeliveryModel originalDeliveryModel; // Add original DeliveryModel

  const DeliveryListItem({
    super.key,
    required this.item,
    required this.originalDeliveryModel, // Require the original model
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPackageDelivery =
        originalDeliveryModel.orderType?.toLowerCase() == 'delivery';
    final orderIcon =
        isPackageDelivery ? Icons.inventory_2_rounded : Icons.store_rounded;

    return GestureDetector(
      onTap: () {
        ref.read(selectedDeliveryProvider.notifier).state =
            originalDeliveryModel;

        if (originalDeliveryModel.orderType?.toLowerCase() == 'delivery') {
          NavigationService.instance
              .navigateTo(NavigatorRoutes.bookingOrderScreen);
        } else if (originalDeliveryModel.orderType?.toLowerCase() ==
            'storedelivery') {
          NavigationService.instance
              .navigateTo(NavigatorRoutes.storeOrderScreen);
        } else {
          debugPrint('Unknown order type: ${originalDeliveryModel.orderType}');
          NavigationService.instance
              .navigateTo(NavigatorRoutes.storeOrderScreen);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(selectedDeliveryProvider.notifier).state =
                  originalDeliveryModel;

              if (originalDeliveryModel.orderType?.toLowerCase() ==
                  'delivery') {
                NavigationService.instance
                    .navigateTo(NavigatorRoutes.bookingOrderScreen);
              } else if (originalDeliveryModel.orderType?.toLowerCase() ==
                  'storedelivery') {
                NavigationService.instance
                    .navigateTo(NavigatorRoutes.storeOrderScreen);
              } else {
                debugPrint(
                    'Unknown order type: ${originalDeliveryModel.orderType}');
                NavigationService.instance
                    .navigateTo(NavigatorRoutes.storeOrderScreen);
              }
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Order Type Icon + Name + Status Badge
                  Row(
                    children: [
                      // Order Type Icon
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: isPackageDelivery
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          orderIcon,
                          color: isPackageDelivery
                              ? AppColors.primary
                              : Colors.orange,
                          size: 24.w,
                        ),
                      ),
                      Gap.w12,
                      // Order Type Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.h3(
                              item.customerName,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            if (item.orderId.isNotEmpty) ...[
                              Gap.h(2),
                              AppText.caption(
                                'ID: ${item.orderId.substring(0, item.orderId.length > 8 ? 8 : item.orderId.length)}',
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: item.statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: item.statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: AppText.caption(
                          item.status,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: item.statusColor,
                        ),
                      ),
                    ],
                  ),
                  Gap.h16,
                  // Amount Section
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.05),
                          AppColors.primary.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        AppText.caption(
                          'Amount:',
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                        Gap.w8,
                        AppText.h2(
                          item.amount,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  Gap.h16,
                  // Address Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 18.w,
                          color: Colors.grey[700],
                        ),
                      ),
                      Gap.w10,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.caption(
                              'Delivery Address',
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                            Gap.h(4),
                            AppText.body(
                              item.address,
                              fontSize: 13,
                              color: Colors.grey[800],
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (item.timestamp.isNotEmpty) ...[
                    Gap.h12,
                    // Timestamp Section
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16.w,
                          color: Colors.grey[500],
                        ),
                        Gap.w6,
                        AppText.caption(
                          item.timestamp,
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
