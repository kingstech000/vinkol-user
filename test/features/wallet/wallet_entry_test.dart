import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/features/wallet/model/payment_history_model.dart';
import 'package:starter_codes/features/wallet/model/withdrawal_model.dart';
import 'package:starter_codes/features/wallet/view/widget/wallet_ui.dart';

void main() {
  group('WalletEntry.stateOf', () {
    test('folds every backend spelling of success', () {
      for (final s in ['successful', 'SUCCESS', 'Approved', 'completed', 'paid']) {
        expect(WalletEntry.stateOf(s), WalletEntryState.succeeded, reason: s);
      }
    });

    test('pending and processing are still moving', () {
      expect(WalletEntry.stateOf('pending'), WalletEntryState.pending);
      expect(WalletEntry.stateOf('Processing'), WalletEntryState.pending);
    });

    test('anything else is a failure, never silently a success', () {
      for (final s in ['failed', 'rejected', 'reversed', '', 'weird']) {
        expect(WalletEntry.stateOf(s), WalletEntryState.failed, reason: s);
      }
    });
  });

  group('WalletEntry.fromPayment', () {
    PaymentHistory payment({String type = 'Debit', String narration = ''}) =>
        PaymentHistory(
          id: 'p1',
          orderId: 'o1',
          userId: 'u1',
          amount: 3200,
          status: 'successful',
          reference: 'REF-1',
          type: type,
          narration: narration,
          createdAt: DateTime(2026, 9, 13, 14, 2),
          updatedAt: DateTime(2026, 9, 13, 14, 2),
        );

    test('a debit is money out and carries a minus', () {
      final e = WalletEntry.fromPayment(payment());
      expect(e.isCredit, isFalse);
      expect(e.sign, '−');
      expect(e.title, 'Payment');
      expect(e.kind, 'Payment');
    });

    test('a credit is a top-up with a plus', () {
      final e = WalletEntry.fromPayment(payment(type: 'Credit'));
      expect(e.isCredit, isTrue);
      expect(e.sign, '+');
      expect(e.title, 'Top-up');
    });

    test('narration becomes the title and is not repeated as a note', () {
      final e = WalletEntry.fromPayment(payment(narration: 'Delivery to Lekki'));
      expect(e.title, 'Delivery to Lekki');
      expect(e.note, isNull);
    });

    test('money carries the record currency and sentence-cases the status', () {
      final e = WalletEntry.fromPayment(payment());
      expect(e.money, const Money(3200, Currency.ngn));
      expect(e.statusLabel, 'Successful');
      expect(e.dateLabel, '13 Sep 2026');
      expect(e.timeLabel, '14:02');
    });
  });

  group('WalletEntry.fromWithdrawal', () {
    test('the bank is the title; the id is the reference', () {
      final e = WalletEntry.fromWithdrawal(Withdrawal(
        id: 'w1',
        amount: 2500,
        status: 'pending',
        bankName: 'Guaranty Trust Bank',
        accountNumber: '0123456789',
        reason: 'Weekly payout',
      ));
      expect(e.title, 'Guaranty Trust Bank');
      expect(e.kind, 'Withdrawal');
      expect(e.isCredit, isFalse);
      expect(e.state, WalletEntryState.pending);
      expect(e.reference, 'w1');
      expect(e.note, 'Weekly payout');
      expect(e.accountNumber, '0123456789');
    });

    test('no bank name still reads as a withdrawal, and no date is a dash', () {
      final e = WalletEntry.fromWithdrawal(Withdrawal(amount: 1, status: 'approved'));
      expect(e.title, 'Withdrawal');
      expect(e.dateLabel, '—');
      expect(e.timeLabel, '—');
    });
  });

  test('BankAccountRow.lastFour handles short numbers', () {
    expect(BankAccountRow.lastFour('0123456789'), '6789');
    expect(BankAccountRow.lastFour('12'), '12');
  });
}
