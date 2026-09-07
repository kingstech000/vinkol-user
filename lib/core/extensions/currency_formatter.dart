import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/market/market_scope.dart';

/// Amount entry, market-aware.
///
/// Grouping and separators come from the active market's locale rather than `en_US`, and the
/// field accepts as many decimal places as the currency has. Nigeria (NGN, 0 decimals) still
/// takes digits only and still groups as `1,000` — unchanged. Canada (CAD, 2 decimals) can
/// take `1,000.50`, which the old integer-only formatter made impossible to type.
class CurrencyFormatter {
  static String formatAmount(double amount) => MarketFormat.amount(amount);

  static double parseAmount(String formattedAmount) =>
      MarketFormat.parse(formattedAmount);

  static TextInputFormatter get amountFormatter => AmountInputFormatter();
}

class AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final maxDecimals = MarketScope.market.currency.decimalDigits;
    final decimalSeparator = MarketFormat.decimalSeparator;

    // Keep digits, and the market's decimal separator only where the currency has decimals.
    final allowed = maxDecimals > 0
        ? RegExp('[^0-9${RegExp.escape(decimalSeparator)}]')
        : RegExp('[^0-9]');
    var cleaned = newValue.text.replaceAll(allowed, '');
    if (cleaned.isEmpty) return const TextEditingValue();

    // One separator, at most `maxDecimals` places after it.
    var fraction = '';
    final separatorAt = cleaned.indexOf(decimalSeparator);
    if (separatorAt >= 0) {
      fraction =
          cleaned.substring(separatorAt + 1).replaceAll(decimalSeparator, '');
      if (fraction.length > maxDecimals) {
        fraction = fraction.substring(0, maxDecimals);
      }
      cleaned = cleaned.substring(0, separatorAt);
    }

    final whole = int.tryParse(cleaned.isEmpty ? '0' : cleaned);
    if (whole == null) return oldValue;

    // Group the whole part only. The fraction is echoed back as typed so a trailing separator
    // or a half-entered `.5` does not get reformatted out from under the caret.
    final grouped = MarketFormat.amount(whole, decimalDigits: 0);
    final formatted =
        separatorAt >= 0 ? '$grouped$decimalSeparator$fraction' : grouped;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

extension AmountControllerExtension on TextEditingController {
  double get numericValue => CurrencyFormatter.parseAmount(text);
}
