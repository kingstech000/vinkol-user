import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/extensions/extensions.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/gap.dart';

/// One delivery tier the courier network quoted for, as a card the user picks.
///
/// A tier the network cannot serve on this route is dimmed and carries the
/// reason it came back with, rather than being hidden.
class QuoteOptionCard extends StatelessWidget {
  final String title;
  final String time;
  final double price;
  final String description;
  final bool isExpress;
  final bool isSelected;
  final double? discountedPrice;
  final bool? hasDiscount;
  final bool isAvailable;
  final String? unavailableMessage;

  const QuoteOptionCard({
    super.key,
    required this.title,
    required this.time,
    required this.price,
    required this.description,
    required this.isExpress,
    required this.isSelected,
    this.discountedPrice,
    this.hasDiscount,
    this.isAvailable = true,
    this.unavailableMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Opacity for unavailable state
    final double opacity = isAvailable ? 1.0 : 0.5;

    // Determine type based on title/isExpress
    final bool isPriority = title.toLowerCase().contains('priority');
    final bool isDarkTheme = isExpress || isPriority;

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 200.w,
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color:
              isPriority ? null : (isExpress ? AppColors.black : Colors.white),
          gradient: isPriority
              ? const LinearGradient(
                  colors: [
                    Color(0xFF9C27B0),
                    Color(0xFF00C853)
                  ], // Purple to Green
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 3.w)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2.w,
              blurRadius: 5.w,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image/Header Section
                Container(
                  height: 100.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isPriority || isExpress
                        ? Colors.black
                            .withOpacity(0.1) // Subtle overlay for dark themes
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    // We need AssetImage to work, make sure path is correct
                    image: const DecorationImage(
                      image: AssetImage(ImageAsset.riderBikeImg),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          // Badge Text
                          isPriority
                              ? "Priority+"
                              : (isExpress ? "Express" : "Regular"),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        isPriority
                            ? "Priority Delivery"
                            : title.toLowerCase() == 'express'
                                ? "Express Delivery"
                                : "Regular Delivery",
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      Gap.h4,
                      // Price Row
                      if (hasDiscount == true &&
                          discountedPrice != null &&
                          isAvailable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              discountedPrice!.toMoney(),
                              style: TextStyle(
                                color: isDarkTheme
                                    ? Colors.white
                                    : AppColors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            isAvailable ? price.toMoney() : 'Unavailable',
                            style: TextStyle(
                              decoration: discountedPrice != null &&
                                      hasDiscount == true &&
                                      isAvailable
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor:
                                  isDarkTheme ? Colors.white : AppColors.black,
                              decorationThickness: 3,
                              color:
                                  isDarkTheme ? Colors.white : AppColors.black,
                              fontSize: (discountedPrice != null &&
                                      hasDiscount == true)
                                  ? 14.sp
                                  : 20.sp,
                              fontWeight: (discountedPrice != null &&
                                      hasDiscount == true)
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          if (discountedPrice != null &&
                              hasDiscount == true &&
                              isAvailable) ...[
                            Gap.w8,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.withOpacity(.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.deepOrange.withOpacity(.4),
                                ),
                              ),
                              child: Text(
                                context.l10n.bookingTwentyPercentOff,
                                style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        unavailableMessage ?? "Unavailable",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
