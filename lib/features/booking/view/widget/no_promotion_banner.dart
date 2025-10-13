import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


// Alternative Design - Card Style
class PromotionBannerAlt extends StatelessWidget {
  final int discountPercentage;
  final int bookingsCount;
  final VoidCallback? onTap;

  const PromotionBannerAlt({
    super.key,
    this.discountPercentage = 10,
    this.bookingsCount = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left side - Badge
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$discountPercentage%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Right side - Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '🎉 ',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      Text(
                        'Congratulations!',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'You\'ve earned a discount on your next $bookingsCount bookings',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap to book now →',
                    style: TextStyle(
                      color: const Color(0xFF6366F1),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Minimal Design
class PromotionBannerMinimal extends StatelessWidget {
  final int discountPercentage;
  final int bookingsCount;
  final VoidCallback? onTap;

  const PromotionBannerMinimal({
    super.key,
    this.discountPercentage = 10,
    this.bookingsCount = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF), // Light blue
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '🎉',
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
            
            SizedBox(width: 12.w),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Congratulations!',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.sp,
                      ),
                      children: [
                        TextSpan(
                          text: '$discountPercentage% OFF ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        TextSpan(text: 'on next $bookingsCount bookings'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF6366F1),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}