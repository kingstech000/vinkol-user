import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';

class PaymentConfirmationDialog extends StatelessWidget {
  const PaymentConfirmationDialog({super.key, required this.isStoreOrder});

  final bool isStoreOrder;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding:
            EdgeInsets.only(top: 24.h, left: 15.w, right: 15.w, bottom: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                child: const Icon(Icons.close),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payment_rounded,
                size: 32.w,
                color: Colors.orange,
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              'Payment in Progress',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 12.h),

            // Description
            Text(
              'Your payment is being processed. What would you like to do?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            SizedBox(height: 28.h),

            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop('verify'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Verify Payment Status',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Primary Button - Continue Payment
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  if (isStoreOrder == true) {
                    Navigator.pop(context);
                    NavigationService.instance.navigateToReplace(
                      NavigatorRoutes.cartScreen,
                      argument: {
                        'isFromWebviewClosing': true,
                      },
                    );
                    log('Routing back to Cart Screen');
                  } else {
                    Navigator.pop(context);
                    NavigationService.instance.navigateToReplace(
                      NavigatorRoutes.mapWithQuoteScreen,
                    );
                    log('Routing back to Map With Quote Screen');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.red, width: 1.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Cancel Payment',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ),

            // Secondary Button - Verify Payment

            SizedBox(height: 10.h),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
              width: 300,
              child: Text(
                'Note that you cannot cancel payment after you have sent money to Paystack',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: Colors.red.withOpacity(.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
