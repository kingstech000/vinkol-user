import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// The body of the location search screen: the spinner while a query is in
/// flight, the list of matches, or the reason there is nothing to show.
class LocationSearchResults extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> predictions;
  final String searchText;
  final ValueChanged<Map<String, dynamic>> onSelect;

  const LocationSearchResults({
    super.key,
    required this.isLoading,
    required this.predictions,
    required this.searchText,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && predictions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50.w,
              height: 50.w,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              context.l10n.bookingSearchingLocations,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (predictions.isEmpty && searchText.isNotEmpty) {
      return _emptyState(
        icon: Icons.search_off_rounded,
        title: context.l10n.bookingNoResultsFound,
        subtitle: context.l10n.bookingTrySearchingWithADifferent,
      );
    }

    if (predictions.isEmpty && searchText.isEmpty) {
      return _emptyState(
        icon: Icons.location_searching_rounded,
        title: context.l10n.bookingStartSearching,
        subtitle: context.l10n.bookingTypeAnAddressOrLocation,
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      itemCount: predictions.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final prediction = predictions[index];
        return _locationItem(context, prediction);
      },
    );
  }

  Widget _locationItem(BuildContext context, Map<String, dynamic> prediction) {
    final description = prediction['description'] ?? 'No description';
    final secondaryText =
        prediction['structured_formatting']?['secondary_text'] ?? '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: () {
          if (prediction['place_id'] != null) {
            FocusScope.of(context).unfocus();
            onSelect(prediction);
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (secondaryText.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        secondaryText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.w,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 48.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50.w,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
