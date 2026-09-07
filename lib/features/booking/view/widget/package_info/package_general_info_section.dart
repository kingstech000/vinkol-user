import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/features/booking/view/widget/package_info/package_info_fields.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/modal_form_field.dart';

/// Pickup date, pickup time and vehicle type — the details that apply to the
/// whole order rather than to any one package.
class PackageGeneralInfoSection extends StatelessWidget {
  final String pickupDate;
  final String pickupTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final TextEditingController vehicleController;
  final List<String> vehicleTypes;
  final ValueChanged<String> onVehicleSelected;

  const PackageGeneralInfoSection({
    super.key,
    required this.pickupDate,
    required this.pickupTime,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.vehicleController,
    required this.vehicleTypes,
    required this.onVehicleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.bookingGeneralInformation,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: PackageTimeDatePicker(
                label: context.l10n.bookingPickupDate,
                value: pickupDate,
                icon: Icons.calendar_today_rounded,
                onTap: onSelectDate,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: PackageTimeDatePicker(
                label: context.l10n.bookingPickupTime,
                value: pickupTime,
                icon: Icons.access_time_rounded,
                onTap: onSelectTime,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        const PackageFieldLabel('Vehicle Type'),
        SizedBox(height: 8.h),
        ModalFormField(
          title: vehicleController.text.isEmpty
              ? 'Select vehicle type'
              : vehicleController.text,
          textColor: vehicleController.text.isEmpty
              ? AppColors.darkgrey.withOpacity(0.5)
              : AppColors.black,
          options: vehicleTypes,
          controller: vehicleController,
          onOptionSelected: onVehicleSelected,
        ),
      ],
    );
  }
}
