import 'package:starter_codes/utils/phone_number_utils.dart';

/// Example usage of phone number validation
class PhoneNumberValidationExample {
  static void demonstratePhoneNumberValidation() {
    print('=== Phone Number Validation Examples ===\n');

    // Test cases for Nigerian phone numbers
    List<String> testNumbers = [
      '08012345678', // Local format with 0
      '8012345678', // 10 digits without 0
      '+2348012345678', // Full international format
      '2348012345678', // International without +
      '07012345678', // Another valid local format
      '09012345678', // Another valid local format
      '1234567890', // Invalid - doesn't start with valid prefix
      '0801234567', // Invalid - only 9 digits after 0
      '080123456789', // Invalid - 11 digits after 0
    ];

    for (String number in testNumbers) {
      String? formatted =
          PhoneNumberUtils.validateAndFormatPhoneNumber(number, '+234');
      bool isValid = PhoneNumberUtils.isValidPhoneNumber(number, '+234');

      print('Input: $number');
      print('Valid: $isValid');
      print('Formatted: ${formatted ?? 'INVALID'}');
      print(
          'Display Format: ${formatted != null ? PhoneNumberUtils.formatForDisplay(formatted) : 'N/A'}');
      print('---');
    }

    print('\n=== Expected Results ===');
    print('✅ 08012345678 → +2348012345678 (Valid)');
    print('✅ 8012345678 → +2348012345678 (Valid)');
    print('✅ +2348012345678 → +2348012345678 (Valid)');
    print('✅ 2348012345678 → +2348012345678 (Valid)');
    print('✅ 07012345678 → +2347012345678 (Valid)');
    print('✅ 09012345678 → +2349012345678 (Valid)');
    print('❌ 1234567890 → INVALID (Invalid prefix)');
    print('❌ 0801234567 → INVALID (Wrong length)');
    print('❌ 080123456789 → INVALID (Wrong length)');
  }

  static void testNigerianNumberPatterns() {
    print('\n=== Nigerian Number Pattern Validation ===\n');

    List<String> testNumbers = [
      '2348012345678', // Valid Nigerian mobile
      '2347012345678', // Valid Nigerian mobile
      '2349012345678', // Valid Nigerian mobile
      '2348112345678', // Valid Nigerian mobile
      '2349112345678', // Valid Nigerian mobile
      '2346012345678', // Invalid - 60 is not a valid mobile prefix
      '2345012345678', // Invalid - 50 is not a valid mobile prefix
    ];

    for (String number in testNumbers) {
      bool isValidNigerian = PhoneNumberUtils.isValidNigerianNumber(number);
      print('$number → ${isValidNigerian ? '✅ Valid Nigerian' : '❌ Invalid'}');
    }
  }
}
