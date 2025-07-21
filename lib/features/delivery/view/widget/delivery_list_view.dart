import 'package:flutter/material.dart';
import 'package:starter_codes/features/delivery/model/delivery_item.dart';
import 'package:starter_codes/features/delivery/view/widget/delivery_list_item.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart'; // Import DeliveryModel

class DeliveryListView extends StatelessWidget {
  final List<DeliveryItem> deliveries;
  final List<DeliveryModel> originalDeliveries; // New: Pass the original DeliveryModel list

  const DeliveryListView({
    super.key,
    required this.deliveries,
    required this.originalDeliveries, // Required
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        return DeliveryListItem(
          item: deliveries[index],
          originalDeliveryModel: originalDeliveries[index], // Pass the corresponding original model
        );
      },
    );
  }
}