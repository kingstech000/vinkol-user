import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/gap.dart';

class OrderListItem extends StatelessWidget {
  final String storeName;
  final String status;
  final Color statusColor;
  final String location;
  final String amount;
  final String dateTime;

  const OrderListItem({
    super.key,
    required this.storeName,
    required this.status,
    required this.statusColor,
    required this.location,
    required this.amount,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // This Expanded now contains the storeName and its status indicator
                Expanded(
                  flex:
                      3, // Give storeName's group more space (e.g., 3 parts out of 4)
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText.body(
                          storeName,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Gap.w8,
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Gap.w4,
                      Flexible(
                        child: AppText.caption(
                          status,
                          color: statusColor,
                          maxLines: 1,
                          fontSize: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // This Expanded now contains the amount, taking less space (e.g., 1 part out of 4)
                Expanded(
                  flex: 1, // Give amount's group less space
                  child: Align(
                    // Align the amount to the right within its allocated space
                    alignment: Alignment.centerRight,
                    child: AppText.body(
                      amount,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: AppText.caption(
                    location,
                    color: Colors.grey.shade600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: AppText.caption(
                    dateTime,
                    color: Colors.grey.shade600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
