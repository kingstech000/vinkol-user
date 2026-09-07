import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/money/money.dart';

void main() {
  group('payment sources differ by market', () {
    test('Nigeria takes wallet and Paystack', () {
      expect(Country.ng.paymentSources, ['Wallet', 'Paystack']);
      expect(Country.ng.hasCustomerWallet, isTrue);
      expect(Country.ng.offersPaymentChoice, isTrue);
    });

    test('Canada takes Stripe only, and has no customer wallet', () {
      expect(Country.ca.paymentSources, ['Stripe']);
      expect(Country.ca.hasCustomerWallet, isFalse);
      expect(Country.ca.offersPaymentChoice, isFalse);
    });
  });

  group('what goes on the wire as paymentSource', () {
    test('a legal Nigerian selection is sent as chosen', () {
      expect(Country.ng.paymentSourceOrNull('Wallet'), 'Wallet');
      expect(Country.ng.paymentSourceOrNull('Paystack'), 'Paystack');
    });

    test('Canada sends nothing so the server picks Stripe', () {
      // "Omit paymentSource and the server picks the market's default."
      expect(Country.ca.paymentSourceOrNull('Stripe'), isNull);
    });

    test('a source the market does not offer is never sent', () {
      // Sending one is a 400 naming it, e.g. "Wallet is not available in CA".
      expect(Country.ca.paymentSourceOrNull('Wallet'), isNull);
      expect(Country.ca.paymentSourceOrNull('Paystack'), isNull);
    });

    test('a null selection stays null', () {
      expect(Country.ng.paymentSourceOrNull(null), isNull);
      expect(Country.ca.paymentSourceOrNull(null), isNull);
    });
  });

  group('the partner courier', () {
    test('is Nigeria only, so Canada never asks Chowdeck for a quote', () {
      // get-cd-quote answers a Canadian pickup with a 400, so the option is
      // not requested rather than requested and shown as unavailable.
      expect(Country.ng.offersPartnerCourier, isTrue);
      expect(Country.ca.offersPartnerCourier, isFalse);
    });
  });

  group('refund destination', () {
    test('Nigeria credits the wallet, Canada the card', () {
      expect(Country.ng.refundDestination, contains('wallet'));
      expect(Country.ca.refundDestination, contains('card'));
      expect(Country.ca.refundDestination, contains('5-10 business days'));
      expect(Country.ca.refundDestination.contains('wallet'), isFalse);
    });
  });
}
