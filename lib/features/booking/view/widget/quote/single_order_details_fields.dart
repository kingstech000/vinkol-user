import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';

/// What goes on the order beyond the route and the tier: what is in the
/// package, and — optionally — who is receiving it.
class SingleOrderDetailsFields extends StatelessWidget {
  final String? selectedItemType;
  final List<String> itemTypes;
  final ValueChanged<String> onItemTypeChanged;
  final bool addRecipient;
  final ValueChanged<bool> onAddRecipientChanged;
  final TextEditingController recipientNameController;
  final TextEditingController recipientPhoneController;

  const SingleOrderDetailsFields({
    super.key,
    required this.selectedItemType,
    required this.itemTypes,
    required this.onItemTypeChanged,
    required this.addRecipient,
    required this.onAddRecipientChanged,
    required this.recipientNameController,
    required this.recipientPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.l10n.bookingPackageType,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Gap.h12,
        // Item Type Dropdown
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedItemType,
              isExpanded: true,
              hint: Text(
                context.l10n.bookingSelectItemType,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
              ),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              onChanged: (String? newValue) {
                if (newValue != null) onItemTypeChanged(newValue);
              },
              items: itemTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Gap.h24,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.bookingAddRecipientDetails,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Switch.adaptive(
              value: addRecipient,
              activeColor: AppColors.primary,
              onChanged: onAddRecipientChanged,
            ),
          ],
        ),
        if (addRecipient) ...[
          Gap.h12,
          AppTextField(
            controller: recipientNameController,
            hint: context.l10n.bookingRecipientName,
            keyboardType: TextInputType.name,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Icon(Icons.person_outline, color: Colors.grey.shade600),
            ),
          ),
          Gap.h12,
          AppTextField(
            controller: recipientPhoneController,
            hint: context.l10n.bookingRecipientPhoneNumber,
            keyboardType: TextInputType.phone,
            formatter: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Icon(Icons.phone_outlined, color: Colors.grey.shade600),
            ),
          ),
        ],
      ],
    );
  }
}
