import 'package:flutter/material.dart';
import 'package:starter_codes/features/booking/view/widget/delivery_item_card.dart';

class LastDeliverySection extends StatelessWidget {
  const LastDeliverySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Last Delivery',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle "See all" press
                },
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: Colors.blue, // Or your app's primary color
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const DeliveryItemCard(
            companyLogo:
                'assets/company_logo.png', // Replace with your asset path
            deliveryDetails: 'Westpalm Hotel - St Albert Ugbo...',
            status: 'With rider',
            price: '₦2,500',
          ),
          // You can add more DeliveryItemCard widgets here if you have multiple deliveries
        ],
      ),
    );
  }
}
