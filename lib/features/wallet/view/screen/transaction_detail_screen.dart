import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/widgets/gap.dart';
import '../../model/payment_history_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TransactionDetailScreen extends StatelessWidget {
  final PaymentHistory transaction;

  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.type == 'Debit';
    final dateFormat = transaction.createdAt.toLocal();
    final formattedDate = '${dateFormat.day}/${dateFormat.month}/${dateFormat.year}';
    final formattedTime = '${dateFormat.hour.toString().padLeft(2, '0')}:${dateFormat.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Transaction Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: isDebit ? Colors.red.shade50 : Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDebit ? PhosphorIconsRegular.arrowDown : PhosphorIconsRegular.arrowUp,
                      color: isDebit ? Colors.red.shade600 : Colors.green.shade600,
                      size: 32.sp,
                    ),
                  ),
                  Gap.h16,
                  Text(
                    transaction.narration.isNotEmpty
                        ? transaction.narration
                        : (isDebit ? 'Payment' : 'Funding'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Gap.h8,
                  Text(
                    '${isDebit ? '-' : '+'}${transaction.money.format()}',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: isDebit ? Colors.red.shade600 : Colors.green.shade600,
                    ),
                  ),
                  Gap.h12,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: transaction.status.toLowerCase() == 'successful' || transaction.status.toLowerCase() == 'success'
                          ? Colors.green.shade50
                          : transaction.status.toLowerCase() == 'pending'
                              ? Colors.orange.shade50
                              : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      transaction.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: transaction.status.toLowerCase() == 'successful' || transaction.status.toLowerCase() == 'success'
                            ? Colors.green.shade700
                            : transaction.status.toLowerCase() == 'pending'
                                ? Colors.orange.shade700
                                : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap.h24,
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Information',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Gap.h20,
                  _buildDetailRow('Date', formattedDate),
                  Gap.h12,
                  _buildDetailRow('Time', formattedTime),
                  Gap.h12,
                  _buildDetailRow('Type', transaction.type),
                  Gap.h12,
                  if (transaction.narration.isNotEmpty)
                    _buildDetailRow('Narration', transaction.narration),
                  if (transaction.narration.isNotEmpty) Gap.h12,
                  _buildDetailRow('Status', transaction.status),
                  Gap.h20,
                  Divider(),
                  Gap.h20,
                  _buildReferenceRow('Reference', transaction.reference),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceRow(String label, String value) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Gap.h8,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIconsRegular.copy, size: 20.sp, color: AppColors.blue),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reference copied to clipboard'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
