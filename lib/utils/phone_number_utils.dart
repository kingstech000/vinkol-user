

import 'package:flutter/services.dart';

/// Utility class for phone number validation and formatting
class PhoneNumberUtils {
  static const String defaultCountryCode = '+234';
  static const int expectedPhoneNumberLength = 10;

  /// Validates and formats a Nigerian phone number
  /// Ensures the number starts with +234 and has exactly 10 additional digits
  static String? validateAndFormatPhoneNumber(
      String phoneNumber, String countryCode) {
    // Remove any whitespace and special characters except +
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Ensure country code is +234
    if (countryCode != defaultCountryCode) {
      return null; // Invalid country code
    }

    // Check if the number already starts with +234
    if (cleanedNumber.startsWith('+234')) {
      // Extract the number part after +234
      String numberPart = cleanedNumber.substring(4);

      // Validate that it's exactly 10 digits and all numeric
      if (numberPart.length == expectedPhoneNumberLength &&
          RegExp(r'^\d{10}$').hasMatch(numberPart)) {
        return cleanedNumber; // Return the full number with +234
      }
    } else if (cleanedNumber.startsWith('234')) {
      // Handle case where + is missing
      String numberPart = cleanedNumber.substring(3);

      if (numberPart.length == expectedPhoneNumberLength &&
          RegExp(r'^\d{10}$').hasMatch(numberPart)) {
        return '+$cleanedNumber'; // Add the + prefix
      }
    } else if (cleanedNumber.startsWith('0')) {
      // Handle case where number starts with 0 (local format)
      String numberPart = cleanedNumber.substring(1);

      if (numberPart.length == expectedPhoneNumberLength &&
          RegExp(r'^\d{10}$').hasMatch(numberPart)) {
        return '$countryCode$numberPart'; // Combine country code with number
      }
    } else {
      // Handle case where only the 10-digit number is provided
      if (cleanedNumber.length == expectedPhoneNumberLength &&
          RegExp(r'^\d{10}$').hasMatch(cleanedNumber)) {
        return '$countryCode$cleanedNumber'; // Combine country code with number
      }
    }

    return null; // Invalid format
  }

  /// Validates if a phone number is in the correct format
  static bool isValidPhoneNumber(String phoneNumber, String countryCode) {
    return validateAndFormatPhoneNumber(phoneNumber, countryCode) != null;
  }

  /// Formats a phone number for display (e.g., +234 801 234 5678)
  static String formatForDisplay(String phoneNumber) {
    if (phoneNumber.startsWith('+234') && phoneNumber.length == 14) {
      String numberPart = phoneNumber.substring(4);
      return '+234 ${numberPart.substring(0, 3)} ${numberPart.substring(3, 6)} ${numberPart.substring(6)}';
    }
    return phoneNumber;
  }

  /// Extracts the local number part (10 digits) from a full international number
  static String extractLocalNumber(String fullPhoneNumber) {
    if (fullPhoneNumber.startsWith('+234') && fullPhoneNumber.length == 14) {
      return fullPhoneNumber.substring(4);
    }
    return fullPhoneNumber;
  }

  /// Validates Nigerian phone number patterns
  static bool isValidNigerianNumber(String phoneNumber) {
    // Remove any formatting
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Check if it's a valid Nigerian mobile number pattern
    if (cleaned.length == 13 && cleaned.startsWith('234')) {
      // Nigerian mobile numbers typically start with 70, 80, 81, 90, 91
      return RegExp(r'^234(70|80|81|90|91)\d{7}$').hasMatch(cleaned);
    }

    return false;
  }
}

class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    // Remove leading zeros
    while (newText.startsWith('0') && newText.length > 1) {
      newText = newText.substring(1);
    }

    // If user types only zero, clear it
    if (newText == '0') {
      newText = '';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

