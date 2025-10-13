import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Main Promotion Banner with two states
class PromotionBanner extends StatelessWidget {
  final bool hasPromotion;
  final int completedBookings;
  final int requiredBookings;
  final int discountPercentage;
  final VoidCallback? onTap;

  const PromotionBanner({
    super.key,
    required this.hasPromotion,
    this.completedBookings = 0,
    this.requiredBookings = 3,
    this.discountPercentage = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return hasPromotion
        ? _PromotionEarnedBanner(
            discountPercentage: discountPercentage,
            onTap: onTap,
          )
        : _PromotionProgressBanner(
            completedBookings: completedBookings,
            requiredBookings: requiredBookings,
            discountPercentage: discountPercentage,
            onTap: onTap,
          );
  }
}

// Banner when user HAS earned the promotion
class _PromotionEarnedBanner extends StatelessWidget {
  final int discountPercentage;
  final VoidCallback? onTap;

  const _PromotionEarnedBanner({
    required this.discountPercentage,
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
          gradient: const LinearGradient(
            colors: [
              Color(0xFF10B981), // Emerald green
              Color(0xFF059669), // Dark green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Celebration emoji and badge
                Row(
                  children: [
                    Text(
                      '🎉',
                      style: TextStyle(fontSize: 28.sp),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'REWARD UNLOCKED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Main heading
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: 8.h),

                // Promo details
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 15.sp,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'You\'ve earned '),
                      TextSpan(
                        text: '$discountPercentage% OFF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          color: Colors.yellow.shade300,
                        ),
                      ),
                      const TextSpan(
                          text: ' on your next\nbooking! Use it now! 🚀'),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // CTA Button
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Book Now',
                            style: TextStyle(
                              color: const Color(0xFF10B981),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Banner when user HASN'T earned the promotion yet (Progress state)
class _PromotionProgressBanner extends StatelessWidget {
  final int completedBookings;
  final int requiredBookings;
  final int discountPercentage;
  final VoidCallback? onTap;

  const _PromotionProgressBanner({
    required this.completedBookings,
    required this.requiredBookings,
    required this.discountPercentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = requiredBookings - completedBookings;
    final progress = completedBookings / requiredBookings;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFF8B5CF6), // Purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gift emoji and badge
                Row(
                  children: [
                    Text(
                      '🎁',
                      style: TextStyle(fontSize: 28.sp),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'UNLOCK REWARD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Main heading
                Text(
                  'Almost There!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: 8.h),

                // Promo details
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 15.sp,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Complete '),
                      TextSpan(
                        text: remaining == 1
                            ? '1 more booking'
                            : '$remaining more bookings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: Colors.yellow.shade300,
                        ),
                      ),
                      const TextSpan(text: '\nto unlock '),
                      TextSpan(
                        text: '$discountPercentage% OFF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          color: Colors.yellow.shade300,
                        ),
                      ),
                      const TextSpan(text: ' your next booking! 🔥'),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$completedBookings/$requiredBookings bookings',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.yellow.shade300,
                        ),
                        minHeight: 8.h,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // CTA Button
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start Booking',
                            style: TextStyle(
                              color: const Color(0xFF6366F1),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF6366F1),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
