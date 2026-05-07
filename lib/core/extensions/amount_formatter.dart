import 'package:intl/intl.dart';

class AmountTextFormatter {
  static final NumberFormat _nairaFormatter = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _simpleFormatter = NumberFormat('#,##0', 'en_US');

  static String formatCurrency(double amount) {
    return '₦${_simpleFormatter.format(amount)}';
  }

  static String formatCurrencyWithDecimals(double amount) {
    return '₦${_nairaFormatter.format(amount)}';
  }

  static String formatAmount(double amount) {
    return _simpleFormatter.format(amount);
  }

  static String formatAmountWithDecimals(double amount) {
    return _nairaFormatter.format(amount);
  }
}

extension AmountFormatting on num {
  String toCurrency() => AmountTextFormatter.formatCurrency(toDouble());
  String toAmount() => AmountTextFormatter.formatAmount(toDouble());
  String toCurrencyWithDecimals() => AmountTextFormatter.formatCurrencyWithDecimals(toDouble());
  String toAmountWithDecimals() => AmountTextFormatter.formatAmountWithDecimals(toDouble());
}
