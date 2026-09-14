import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/utils/phone_number_utils.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';

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
    return AppTextField(
      controller: _localNumberController,
      hint: widget.hint,
      enabled: widget.enabled,
      keyboardType: TextInputType.phone,
      fillColor: AppColors.white,
      outlineColor: AppColors.lightgrey,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: widget.enabled
          ? const [AutofillHints.telephoneNumberLocal]
          : null,
      formatter: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(localDigits),
        NoLeadingZeroFormatter(),
      ],
      // The dial code belongs to the field, not beside it: same box, same
      // border, separated by a hairline so the number still reads as the input.
      prefixIcon: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.body(
              _countryCode,
              color: AppColors.darkgrey,
              fontWeight: FontWeight.w500,
            ),
            Gap.w12,
            const SizedBox(
              width: 1,
              height: 20,
              child: ColoredBox(color: AppColors.lightgrey),
            ),
          ],
        ),
      ),
      // The prefix carries its own end padding, so the text picks up where it
      // stops rather than after another 16.
      contentPadding: const EdgeInsetsDirectional.only(
        end: 16,
        top: 10,
        bottom: 10,
      ),
    );
  }
}

