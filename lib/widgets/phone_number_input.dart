import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_textfield.dart';

/// Custom phone number input widget that splits +234 prefix from the local number
class PhoneNumberInput extends StatefulWidget {
  final String initialPhoneNumber;
  final ValueChanged<String> onPhoneNumberChanged;
  final bool enabled;
  final String hint;

  const PhoneNumberInput({
    super.key,
    required this.initialPhoneNumber,
    required this.onPhoneNumberChanged,
    this.enabled = true,
    this.hint = 'Phone Number',
  });

  @override
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  late TextEditingController _localNumberController;
  String _countryCode = '+234';
  String _localNumber = '';

  @override
  void initState() {
    super.initState();
    _parseInitialPhoneNumber();
    _localNumberController = TextEditingController(text: _localNumber);

    // Add listener to update the parent when local number changes
    _localNumberController.addListener(() {
      _localNumber = _localNumberController.text;
      _notifyParent();
    });
  }

  void _parseInitialPhoneNumber() {
    String phoneNumber = widget.initialPhoneNumber;

    // Remove any whitespace
    phoneNumber = phoneNumber.trim();

    if (phoneNumber.startsWith('+234')) {
      // Extract the local number part (everything after +234)
      _localNumber = phoneNumber.substring(4);
    } else if (phoneNumber.startsWith('234')) {
      // Handle case where + is missing
      _localNumber = phoneNumber.substring(3);
    } else if (phoneNumber.startsWith('0')) {
      // Handle local format (remove the leading 0)
      _localNumber = phoneNumber.substring(1);
    } else {
      // Assume it's already the local number
      _localNumber = phoneNumber;
    }
  }

  void _notifyParent() {
    // Concatenate country code with local number
    String fullPhoneNumber = '$_countryCode$_localNumber';
    widget.onPhoneNumberChanged(fullPhoneNumber);
  }

  @override
  void dispose() {
    _localNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.lightgrey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // Country code prefix (non-editable)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.lightgrey.withOpacity(0.3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                bottomLeft: Radius.circular(8.r),
              ),
            ),
            child: AppText.body(
              _countryCode,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 40.h,
            color: AppColors.lightgrey,
          ),
          // Local number input field
          Expanded(
            child: TextField(
              controller: _localNumberController,
              enabled: widget.enabled,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 16.h,
                ),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.black,
              ),
              maxLength: 10, // Limit to 10 digits for Nigerian numbers
              buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) {
                return null; // Hide character counter
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Alternative implementation using AppTextField with prefix
class PhoneNumberInputWithPrefix extends StatefulWidget {
  final String initialPhoneNumber;
  final ValueChanged<String> onPhoneNumberChanged;
  final bool enabled;
  final String hint;

  const PhoneNumberInputWithPrefix({
    super.key,
    required this.initialPhoneNumber,
    required this.onPhoneNumberChanged,
    this.enabled = true,
    this.hint = 'Phone Number',
  });

  @override
  State<PhoneNumberInputWithPrefix> createState() =>
      _PhoneNumberInputWithPrefixState();
}

class _PhoneNumberInputWithPrefixState
    extends State<PhoneNumberInputWithPrefix> {
  late TextEditingController _localNumberController;
  String _countryCode = '+234';
  String _localNumber = '';

  @override
  void initState() {
    super.initState();
    _parseInitialPhoneNumber();
    _localNumberController = TextEditingController(text: _localNumber);

    // Add listener to update the parent when local number changes
    _localNumberController.addListener(() {
      _localNumber = _localNumberController.text;
      _notifyParent();
    });
  }

  void _parseInitialPhoneNumber() {
    String phoneNumber = widget.initialPhoneNumber;

    // Remove any whitespace
    phoneNumber = phoneNumber.trim();

    if (phoneNumber.startsWith('+234')) {
      // Extract the local number part (everything after +234)
      _localNumber = phoneNumber.substring(4);
    } else if (phoneNumber.startsWith('234')) {
      // Handle case where + is missing
      _localNumber = phoneNumber.substring(3);
    } else if (phoneNumber.startsWith('0')) {
      // Handle local format (remove the leading 0)
      _localNumber = phoneNumber.substring(1);
    } else {
      // Assume it's already the local number
      _localNumber = phoneNumber;
    }
  }

  void _notifyParent() {
    // Concatenate country code with local number
    String fullPhoneNumber = '$_countryCode$_localNumber';
    widget.onPhoneNumberChanged(fullPhoneNumber);
  }

  @override
  void dispose() {
    _localNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _localNumberController,
      hint: widget.hint,
      enabled: widget.enabled,
      keyboardType: TextInputType.phone,
      prefixIcon: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: AppText.body(
          _countryCode,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      maxLength: 10, // Limit to 10 digits for Nigerian numbers
    );
  }
}
