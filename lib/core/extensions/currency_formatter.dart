import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0', 'en_US');

  static String formatAmount(double amount) {
    return _formatter.format(amount);
  }

  static double parseAmount(String formattedAmount) {
    if (formattedAmount.isEmpty) return 0.0;
    String cleaned = formattedAmount.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  static TextInputFormatter get amountFormatter => AmountInputFormatter();
}

class AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    int? number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    String formatted = NumberFormat('#,##0', 'en_US').format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

extension AmountControllerExtension on TextEditingController {
  double get numericValue => CurrencyFormatter.parseAmount(text);
}
