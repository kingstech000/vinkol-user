import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/booking/data/ride_notifier.dart';
import 'package:starter_codes/features/booking/model/item_details.dart';
import 'package:starter_codes/features/booking/view/widget/package_info/package_info_fields.dart';
import 'package:starter_codes/l10n/l10n.dart';

/// The package form for a single delivery.
///
/// Empty for multi-drop and batch: those collect a package and a recipient per stop, in
/// their own editors, so there is nothing left to ask here.
class PackageItemsSection extends StatelessWidget {
  final List<ItemDetails> items;
  final RideLocationState state;

  const PackageItemsSection({
    super.key,
    required this.items,
    required this.state,
  });

  /// Names the card so the user can tell which stop it belongs to.
  String _itemLabel(int index) {
    if (state.orderType == OrderType.bulk) {
      final dropoff = state.stops.where((s) => !s.isPickup).toList()[index];
      return 'Dropoff to: ${dropoff.location?.formattedAddress ?? "Location ${index + 1}"}';
    }
    if (state.orderType == OrderType.multi) {
      final pickup = state.stops[index * 2];
      final dropoff = state.stops[index * 2 + 1];
      return 'Order ${index + 1}: ${pickup.location?.formattedAddress ?? "P"}  -→  ${dropoff.location?.address ?? "D"}';
    }
    return 'Item ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    const String title = 'Package Details';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        ...List.generate(items.length, (index) {
          final item = items[index];

          return Container(
            margin:
                EdgeInsets.only(bottom: index < items.length - 1 ? 24.h : 0),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                  color: AppColors.greyLight.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (items.length > 1) ...[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _itemLabel(index),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                PackageInputField(
                  'Package Name',
                  item.packageNameController,
                  hintText: context.l10n.bookingEnterPackageName,
                  icon: Icons.inventory_2_outlined,
                ),
                if (state.orderType != OrderType.standard) ...[
                  SizedBox(height: 16.h),
                  PackageInputField(
                    'Recipient Name',
                    item.recipientNameController,
                    hintText: context.l10n.bookingName,
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 12.w),
                  PackageInputField(
                    'Recipient Phone',
                    item.recipientPhoneController,
                    hintText: context.l10n.commonPhone,
                    icon: Icons.phone_outlined,
                  ),
                ],
                SizedBox(height: 16.h),
                PackageInputField(
                  'Special Instructions',
                  item.noteController,
                  hintText: context.l10n.bookingAddAnySpecialInstructionsOr,
                  maxLines: 2,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
