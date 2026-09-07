import 'package:starter_codes/core/money/money.dart';

/// What can actually be withdrawn right now, and why it differs from the
/// balance.
///
/// [withdrawableAmount] is `balance - disputed - pending`, floored at zero. It
/// used to net off disputed orders only, so someone with a withdrawal already in
/// flight was shown a number that `/withdraw` would then refuse. The two now
/// agree, and showing the breakdown explains the gap.
class WithdrawableAmount {
  const WithdrawableAmount({
    required this.withdrawableAmount,
    required this.balance,
    required this.disputedAmount,
    required this.pendingAmount,
    this.currency = Currency.ngn,
  });

  final double withdrawableAmount;
  final double balance;
  final double disputedAmount;
  final double pendingAmount;
  final Currency currency;

  factory WithdrawableAmount.fromJson(Map<String, dynamic> json) {
    return WithdrawableAmount(
      withdrawableAmount: Money.parseAmount(json['withdrawableAmount']) ?? 0,
      balance: Money.parseAmount(json['balance']) ?? 0,
      disputedAmount: Money.parseAmount(json['disputedAmount']) ?? 0,
      pendingAmount: Money.parseAmount(json['pendingAmount']) ?? 0,
      currency: Currency.fromCode(json['currency'] as String?),
    );
  }

  Money get withdrawable => Money(withdrawableAmount, currency);
  Money get total => Money(balance, currency);
  Money get disputed => Money(disputedAmount, currency);
  Money get pending => Money(pendingAmount, currency);

  /// Whether anything is being held back, and the breakdown is worth showing.
  bool get hasHoldings => disputedAmount > 0 || pendingAmount > 0;
}
