import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// The title and search box at the top of the location search screen.
class LocationSearchHeader extends StatelessWidget {
  final bool isPickupLocation;
  final TextEditingController controller;

  const LocationSearchHeader({
    super.key,
    required this.isPickupLocation,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(24.w, 0.h, 24.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isPickupLocation
                      ? Icons.location_on_rounded
                      : Icons.location_city_rounded,
                  color: AppColors.primary,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPickupLocation
                          ? 'Pick-up Location'
                          : 'Drop-off Location',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.l10n.bookingSearchForAnAddress,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Search Field
          Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            child: TextField(
              controller: controller,
              autofocus: true,
              cursorColor: AppColors.primary,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: isPickupLocation
                    ? 'Search pick-up location...'
                    : 'Search drop-off location...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15.sp,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 24.w,
                  ),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey[400],
                          size: 20.w,
                        ),
                        onPressed: () {
                          controller.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
