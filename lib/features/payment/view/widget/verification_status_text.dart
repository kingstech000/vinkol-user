import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/features/payment/model/verification_status.dart';

/// The headline under the status badge.
class VerificationStatusText extends StatelessWidget {
  final String message;

  const VerificationStatusText(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: -0.5,
      ),
    );
  }
}

/// The explanatory line under the headline — what the current state means and
/// what the user can do about it.
class VerificationSubtitleText extends StatelessWidget {
  final VerificationStatus status;
  final bool canCancel;
  final int pollCount;

  const VerificationSubtitleText({
    super.key,
    required this.status,
    required this.canCancel,
    required this.pollCount,
  });

  String get _subtitle {
    switch (status) {
      case VerificationStatus.verifying:
        if (canCancel && pollCount >= 5) {
          return 'Taking longer than expected? You can go back and check your order status later in the Deliveries section.';
        }
        return 'Please wait while we confirm your payment status...';
      case VerificationStatus.success:
        return 'Your order has been confirmed successfully!';
      case VerificationStatus.failed:
        return 'Unfortunately, your payment could not be processed. Please try again.';
      case VerificationStatus.timeout:
        return 'Payment verification is taking longer than usual. If you\'ve completed payment, your order will be processed. Check the Deliveries section for updates.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        _subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.grey[600],
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
