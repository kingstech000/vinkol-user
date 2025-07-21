import 'package:flutter/material.dart';

class DeliveryItemCard extends StatelessWidget {
  final String companyLogo;
  final String deliveryDetails;
  final String status;
  final String price;

  const DeliveryItemCard({
    super.key,
    required this.companyLogo,
    required this.deliveryDetails,
    required this.status,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 10), // Space between cards if multiple
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200], // Placeholder background
              backgroundImage:
                  AssetImage(companyLogo), // Ensure this asset exists
              child: Image.asset(companyLogo,
                  fit: BoxFit.cover), // Use Image.asset directly if you want
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deliveryDetails,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
