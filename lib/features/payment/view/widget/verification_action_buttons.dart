import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/payment/model/verification_status.dart';

/// The actions offered at the foot of the verification screen.
///
/// What is on offer depends on where the payment stands: nothing while we are
/// still waiting (until waiting has gone on long enough to offer a way out),
/// a retry when it failed or timed out, and always a way back.
class VerificationActionButtons extends StatelessWidget {
  final VerificationStatus status;
  final bool canCancel;
  final int pollCount;
  final bool isStoreOrder;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onViewOrders;
  final VoidCallback onGoBack;

  const VerificationActionButtons({
    super.key,
    required this.status,
    required this.canCancel,
    required this.pollCount,
    required this.isStoreOrder,
    required this.onCancel,
    required this.onRetry,
    required this.onViewOrders,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    // Show cancel button during verification if taking too long
    if (status == VerificationStatus.verifying) {
      if (canCancel && pollCount >= 5) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(color: Colors.grey[300]!, width: 1.5.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.grey[700],
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Cancel & Go Back',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    if (status == VerificationStatus.success) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (status == VerificationStatus.failed ||
            status == VerificationStatus.timeout)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 22.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Retry Verification',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 12.h),
        if (status == VerificationStatus.timeout)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewOrders,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: AppColors.primary, width: 2.w),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt_rounded,
                      color: AppColors.primary, size: 22.w),
                  SizedBox(width: 8.w),
                  Text(
                    'View My Orders',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (status == VerificationStatus.timeout) SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onGoBack,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(color: Colors.grey[300]!, width: 1.5.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              isStoreOrder ? 'Back to Cart' : 'Back to Home',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
