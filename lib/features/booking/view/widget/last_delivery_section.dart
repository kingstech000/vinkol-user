import 'package:flutter/material.dart';
import 'package:starter_codes/features/booking/view/widget/delivery_item_card.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/l10n/l10n.dart';

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
              Text(
                context.l10n.bookingLastDelivery,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle "See all" press
                },
                child: Text(
                  context.l10n.bookingSeeAll,
                  style: const TextStyle(
                    color: Colors.blue, // Or your app's primary color
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Placeholder row. No longer const: the price is written by the active market.
          DeliveryItemCard(
            companyLogo:
                'assets/company_logo.png', // Replace with your asset path
            deliveryDetails: 'Westpalm Hotel - St Albert Ugbo...',
            status: 'With rider',
            price: MarketFormat.money(2500),
          ),
          // You can add more DeliveryItemCard widgets here if you have multiple deliveries
        ],
      ),
    );
  }
}
