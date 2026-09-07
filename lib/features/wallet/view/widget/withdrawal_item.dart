import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/withdrawal_model.dart';

import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WithdrawalItem extends StatelessWidget {
  final Withdrawal withdrawal;

  const WithdrawalItem({
    super.key,
    required this.withdrawal,
  });

  Color _getStatusColor() {
    switch (withdrawal.status.toLowerCase()) {
      case 'approved':
      case 'successful':
      case 'success':
        return Colors.green;
      case 'rejected':
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final dateFormat = withdrawal.createdAt?.toLocal();
    final formattedDate = dateFormat != null
        ? '${dateFormat.day}/${dateFormat.month}/${dateFormat.year}'
        : 'N/A';
    final formattedTime = dateFormat != null
        ? '${dateFormat.hour.toString().padLeft(2, '0')}:${dateFormat.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              PhosphorIconsRegular.arrowCircleUpRight, // or account_balance_wallet
              color: Colors.red.shade600,
              size: 20.sp,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Withdrawal',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Gap.h4,
                Text(
                  '${withdrawal.bankName ?? 'Bank Transfer'} • $formattedDate $formattedTime',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${withdrawal.amount.toMoney()}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
              Gap.h4,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  withdrawal.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
