import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/delivery/model/delivery_item.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/provider/delivery_provider.dart'; // Import DeliveryModel to set the provider

class DeliveryListItem extends ConsumerWidget { // Changed to ConsumerWidget
  final DeliveryItem item;
  final DeliveryModel originalDeliveryModel; // Add original DeliveryModel

  const DeliveryListItem({
    super.key,
    required this.item,
    required this.originalDeliveryModel, // Require the original model
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef
    return GestureDetector(
      onTap: () {
        // 1. Store the selected delivery model
        ref.read(selectedDeliveryProvider.notifier).state = originalDeliveryModel;

        // 2. Determine which screen to navigate to based on orderType
        // Assuming 'Delivery' for package and 'StoreDelivery' for store orders
        if (originalDeliveryModel.orderType?.toLowerCase() == 'delivery') {
          NavigationService.instance.navigateTo(NavigatorRoutes.bookingOrderScreen); // Assuming you have this route
        } else if (originalDeliveryModel.orderType?.toLowerCase() == 'storedelivery') {
          NavigationService.instance.navigateTo(NavigatorRoutes.storeOrderScreen);
        } else {
          // Fallback or error handling for unknown order types
          debugPrint('Unknown order type: ${originalDeliveryModel.orderType}');
          // You might want to show a general detail screen or an error message
          NavigationService.instance.navigateTo(NavigatorRoutes.storeOrderScreen); // A generic detail screen
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.statusColor
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        color: item.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                
                  AppText.button(
                    item.amount,
                
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.timestamp,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}