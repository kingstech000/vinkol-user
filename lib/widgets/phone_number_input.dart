import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/utils/phone_number_utils.dart';
import 'package:starter_codes/widgets/app_textfield.dart';

/// Phone input that splits the dial code from the local number.
///
/// Both the dial code and the number of digits accepted come from the device's
/// market, so a Canadian customer is offered `+1` and ten digits rather than
/// `+234`.
class PhoneNumberInput extends ConsumerStatefulWidget {
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
  ConsumerState<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends ConsumerState<PhoneNumberInput> {
  late TextEditingController _localNumberController;
  late String _countryCode;
  String _localNumber = '';

  @override
  void initState() {
    super.initState();
    _countryCode = ref.read(marketProfileProvider).dialCode;
    _parseInitialPhoneNumber();
    _localNumberController = TextEditingController(text: _localNumber);

    // Add listener to update the parent when local number changes
    _localNumberController.addListener(() {
      _localNumber = _localNumberController.text;
      _notifyParent();
    });
  }

  void _parseInitialPhoneNumber() {
    String phoneNumber = widget.initialPhoneNumber.trim();

    // A stored number may carry any market's dial code, not just this device's
    // — a customer who moved keeps the number they signed up with.
    final digits = _countryCode.replaceAll('+', '');
    if (phoneNumber.startsWith(_countryCode)) {
      _localNumber = phoneNumber.substring(_countryCode.length);
    } else if (phoneNumber.startsWith(digits)) {
      _localNumber = phoneNumber.substring(digits.length);
    } else if (phoneNumber.startsWith('0')) {
      // Local form: the trunk prefix is dropped in international form.
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
    final localDigits = ref.watch(marketProfileProvider).localPhoneDigits;
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(localDigits),
                NoLeadingZeroFormatter(),
              ],
              controller: _localNumberController,
              enabled: widget.enabled,
              keyboardType: TextInputType.phone,
              autofillHints: widget.enabled
                  ? const [AutofillHints.telephoneNumberLocal]
                  : null,
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
              maxLength: localDigits,
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

/// Alternative implementation using AppTextField with prefix.
///
/// Unused as of Sep 2026, and still hardcoded to `+234`. Convert it the same way
/// as [PhoneNumberInput] before using it, or delete it.
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
