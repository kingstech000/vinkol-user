// lib/features/wallet/widgets/payment_history_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:starter_codes/core/extensions/double_extension.dart'; // For toMoney() extension
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';// Import your PaymentHistory model
import 'package:starter_codes/features/wallet/model/payment_history_model.dart';
import 'package:starter_codes/widgets/gap.dart';

class PaymentHistoryItem extends StatelessWidget {
  final PaymentHistory payment; // Takes the PaymentHistory model directly

  const PaymentHistoryItem({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the color based on status
    Color statusColor;
    switch (payment.status.toLowerCase()) {
      case 'successful':
        statusColor = AppColors.green; // Assuming you have a green color defined
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'failed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppColors.greyLight;
    }

    // Format the date and time from the createdAt DateTime object
    final String formattedDate = DateFormat('dd MMM yyyy').format(payment.createdAt); // e.g., 05 Jul 2025
    final String formattedTime = DateFormat('hh:mm a').format(payment.createdAt); // e.g., 03:22 AM

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.button(
                  'Order ID: ${payment.orderId}', // Displaying order ID
                  fontSize: 14,
                ),
                Gap.h4,
                AppText.button(
                  payment.reference, // Displaying reference
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                Gap.h4,
                AppText.button(
                  'Type: ${payment.type}', // Displaying type (Debit/Credit)
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText.button(
                payment.amount.toMoney(), // Using toMoney() extension for amount
                color: AppColors.primary, // Primary color for amount
                fontSize: 14,
              ),
              Gap.h4,
              AppText.caption(
                payment.status ?? 'Unknown', // Displaying status
                fontSize: 12,
                color: statusColor, // Color based on status
              ),
              Gap.h4,
              AppText.caption(
                '$formattedDate $formattedTime', // Formatted date and time
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}