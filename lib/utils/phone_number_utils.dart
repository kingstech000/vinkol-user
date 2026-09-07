

import 'package:flutter/services.dart';

/// Utility class for phone number validation and formatting.
///
/// Every entry point takes the market's dial code and digit count rather than
/// assuming Nigeria's. The old version rejected any code that was not `+234`
/// outright, which made onboarding in another market impossible.
class PhoneNumberUtils {
  static const String defaultCountryCode = '+234';
  static const int expectedPhoneNumberLength = 10;

  /// Validates a number and returns it in international form, or null.
  ///
  /// Accepts the number however the customer typed it — already
  /// international, without the `+`, in local trunk form with a leading zero,
  /// or as bare local digits.
  static String? validateAndFormatPhoneNumber(
    String phoneNumber,
    String countryCode, {
    int expectedLength = expectedPhoneNumberLength,
  }) {
    // Remove any whitespace and special characters except +
    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (countryCode.isEmpty) return null;

    final dialDigits = countryCode.replaceAll('+', '');
    String local;

    if (cleaned.startsWith(countryCode)) {
      local = cleaned.substring(countryCode.length);
    } else if (cleaned.startsWith(dialDigits)) {
      local = cleaned.substring(dialDigits.length);
    } else if (cleaned.startsWith('0')) {
      // Local trunk form; the leading zero is dropped internationally.
      local = cleaned.substring(1);
    } else {
      local = cleaned;
    }

    if (local.length != expectedLength ||
        !RegExp('^\\d{$expectedLength}\$').hasMatch(local)) {
      return null;
    }
    return '$countryCode$local';
  }

  /// Validates if a phone number is in the correct format
  static bool isValidPhoneNumber(
    String phoneNumber,
    String countryCode, {
    int expectedLength = expectedPhoneNumberLength,
  }) {
    return validateAndFormatPhoneNumber(phoneNumber, countryCode,
            expectedLength: expectedLength) !=
        null;
  }

  /// Groups the local part in threes for display, e.g. `+1 647 946 0011`.
  static String formatForDisplay(String phoneNumber, String countryCode) {
    if (!phoneNumber.startsWith(countryCode)) return phoneNumber;
    final local = phoneNumber.substring(countryCode.length);
    if (local.length < 7) return phoneNumber;
    final head = local.substring(0, 3);
    final mid = local.substring(3, 6);
    final tail = local.substring(6);
    return '$countryCode $head $mid $tail';
  }

  /// Extracts the local part from a full international number.
  static String extractLocalNumber(
      String fullPhoneNumber, String countryCode) {
    if (fullPhoneNumber.startsWith(countryCode)) {
      return fullPhoneNumber.substring(countryCode.length);
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

