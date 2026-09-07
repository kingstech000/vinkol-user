import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/features/wallet/model/withdrawable_amount_model.dart';

void main() {
  // The exact shape from the migration guide.
  final response = {
    'withdrawableAmount': 7000,
    'balance': 10000,
    'disputedAmount': 0,
    'pendingAmount': 3000,
    'currency': 'NGN',
  };

  group('withdrawable amount', () {
    test('parses the documented response', () {
      final w = WithdrawableAmount.fromJson(Map<String, dynamic>.from(response));
      expect(w.withdrawableAmount, 7000);
      expect(w.balance, 10000);
      expect(w.disputedAmount, 0);
      expect(w.pendingAmount, 3000);
      expect(w.currency, Currency.ngn);
    });

    test('a pending request is what explains the gap', () {
      final w = WithdrawableAmount.fromJson(Map<String, dynamic>.from(response));
      // Withdrawable is less than balance, and the breakdown says why.
      expect(w.withdrawableAmount, lessThan(w.balance));
      expect(w.hasHoldings, isTrue);
      expect(w.pending.format(), '₦3,000');
      expect(w.withdrawable.format(), '₦7,000');
      expect(w.total.format(), '₦10,000');
    });

    test('nothing held back means no breakdown to show', () {
      final w = WithdrawableAmount.fromJson({
        'withdrawableAmount': 10000,
        'balance': 10000,
        'disputedAmount': 0,
        'pendingAmount': 0,
        'currency': 'NGN',
      });
      expect(w.hasHoldings, isFalse);
      expect(w.withdrawableAmount, w.balance);
    });

    test('missing fields default to zero rather than throwing', () {
      final w = WithdrawableAmount.fromJson(const {});
      expect(w.withdrawableAmount, 0);
      expect(w.balance, 0);
      expect(w.hasHoldings, isFalse);
      expect(w.currency, Currency.ngn);
    });

    test('amounts keep their cents and their market', () {
      final w = WithdrawableAmount.fromJson({
        'withdrawableAmount': 21.26,
        'balance': 21.26,
        'disputedAmount': 0,
        'pendingAmount': 0,
        'currency': 'CAD',
      });
      expect(w.withdrawableAmount, 21.26);
      expect(w.withdrawable.format(), 'C\$21.26');
    });
  });
}
