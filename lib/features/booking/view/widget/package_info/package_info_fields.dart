import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/widgets/app_textfield.dart';

/// The small caption sitting above every field on the package-info form.
class PackageFieldLabel extends StatelessWidget {
  final String label;

  const PackageFieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

/// A labelled text field with an optional leading icon.
class PackageInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int? maxLines;
  final IconData? icon;

  const PackageInputField(
    this.label,
    this.controller, {
    super.key,
    this.hintText,
    this.maxLines,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PackageFieldLabel(label),
        SizedBox(height: 8.h),
        AppTextField(
          controller: controller,
          maxLines: maxLines,
          hint: hintText,
          prefixIcon: icon != null
              ? Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Icon(
                    icon,
                    size: 20.w,
                    color: AppColors.greyLight,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

/// A read-only field that opens a date or time picker when tapped.
class PackageTimeDatePicker extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const PackageTimeDatePicker({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PackageFieldLabel(label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    size: 15.w,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
