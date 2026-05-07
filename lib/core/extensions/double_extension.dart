import 'package:intl/intl.dart';

extension DoubleX on double {
  String toMoney() {
    var f = NumberFormat.currency(
        symbol: '',
        decimalDigits: 0,
        locale: 'en_US',
        customPattern: '#,##0.00');
    return '₦${f.format(this)}'; // 'this' refers to the double value itself
  }

  String toMoneyShowFree() {
    if (this == 0.0) {
      return "Free";
    }
    return toMoney(); // Returns ₦2,000.00 or similar
  }

  String toMoneyWithoutSymbol() {
    var f = NumberFormat.currency(
        symbol: '',
        decimalDigits: 0,
        locale: 'en_US',
        customPattern: '#,##0.00');
    return f.format(this);
  }

  String toMoneyWithSymbol() {
    return toMoney();
  }
}
