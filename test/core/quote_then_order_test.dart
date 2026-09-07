import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/store/model/store_request_model.dart';
import 'package:starter_codes/models/location_model.dart';

CreateOrderRequest _order({String? quoteId}) => CreateOrderRequest(
      pickupLocation: LocationModel(formattedAddress: 'a'),
      dropOffLocation: LocationModel(formattedAddress: 'b'),
      packageType: 'p',
      packageName: 'p',
      priorityType: 'express',
      vehicleType: 'bike',
      estimatedDeliveryTime: '30-60 min',
      price: 4836,
      pickupDate: '2026-09-07',
      pickupTime: 'Anytime',
      note: '',
      state: 'Edo',
      quoteId: quoteId,
    );

void main() {
  group('order creation sends exactly one of quoteId / deliveryFee', () {
    test('sends quoteId and omits deliveryFee when quoted', () {
      final json = _order(quoteId: '6a9e8468305b2a4d15092cdf').toJson();
      expect(json['quoteId'], '6a9e8468305b2a4d15092cdf');
      expect(json.containsKey('deliveryFee'), isFalse);
    });

    test('falls back to deliveryFee for partner quotes with no quoteId', () {
      final json = _order().toJson();
      expect(json['deliveryFee'], 4836);
      expect(json.containsKey('quoteId'), isFalse);
    });

    test('store payload behaves the same way', () {
      final quoted = CreateStoreOrderPayload(
        state: 's', store: 'st', products: const [], amount: 20000,
        deliveryFee: 4836, dropoffLocation: 'd', deliveryType: 'express',
        orderType: 'Shopping', quoteId: 'q1',
      ).toJson();
      expect(quoted['quoteId'], 'q1');
      expect(quoted.containsKey('deliveryFee'), isFalse);

      final unquoted = CreateStoreOrderPayload(
        state: 's', store: 'st', products: const [], amount: 20000,
        deliveryFee: 4836, dropoffLocation: 'd', deliveryType: 'express',
        orderType: 'Shopping',
      ).toJson();
      expect(unquoted['deliveryFee'], 4836);
      expect(unquoted.containsKey('quoteId'), isFalse);
    });
  });

  group('quote parsing', () {
    // The exact staging payload observed on 7 Sep 2026.
    final staging = {
      'price': 69942,
      'distance': 309.735,
      'quoteId': '6a9e8468305b2a4d15092cdf',
      'country': 'NG',
      'currency': 'NGN',
      'taxRate': 0,
      'taxLabel': '',
      'expiresAt': '2026-09-07T09:46:20.066Z',
      'state': 'Edo',
      'orderType': 'Shopping',
      'deliveryType': 'express',
      'vehicleRequest': 'bike',
      'pickupLocation': {'lat': 6.45, 'lng': 3.45},
      'dropoffLocation': {'lat': 6.40, 'lng': 5.61},
    };

    test('reads quoteId, market and expiry off the staging response', () {
      final q = QuoteResponseModel.fromJson(Map<String, dynamic>.from(staging));
      expect(q.quoteId, '6a9e8468305b2a4d15092cdf');
      expect(q.country, Country.ng);
      expect(q.currency, Currency.ngn);
      expect(q.expiresAt, DateTime.parse('2026-09-07T09:46:20.066Z'));
    });

    test('a quote past its expiry is expired, a future one is not', () {
      final base = Map<String, dynamic>.from(staging);
      final stale = QuoteResponseModel.fromJson(
          {...base, 'expiresAt': '2020-01-01T00:00:00.000Z'});
      final fresh = QuoteResponseModel.fromJson({
        ...base,
        'expiresAt':
            DateTime.now().toUtc().add(const Duration(minutes: 10)).toIso8601String()
      });
      expect(stale.isExpired, isTrue);
      expect(fresh.isExpired, isFalse);
    });

    test('a quote with no expiry is never treated as expired', () {
      final base = Map<String, dynamic>.from(staging)..remove('expiresAt');
      expect(QuoteResponseModel.fromJson(base).isExpired, isFalse);
    });

    test('legacy records with no market fields read as Nigerian', () {
      final base = Map<String, dynamic>.from(staging)
        ..remove('country')
        ..remove('currency');
      final q = QuoteResponseModel.fromJson(base);
      expect(q.country, Country.ng);
      expect(q.currency, Currency.ngn);
    });

    test('amountDue prefers grandTotal, else the fare', () {
      final plain = QuoteResponseModel.fromJson(Map<String, dynamic>.from(staging));
      expect(plain.amountDue, const Money(69942, Currency.ngn));

      final canadian = QuoteResponseModel.fromJson({
        ...staging,
        'price': 18.00,
        'currency': 'CAD',
        'country': 'CA',
        'serviceFee': 0.81,
        'taxAmount': 2.45,
        'taxLabel': 'HST',
        'grandTotal': 21.26,
      });
      expect(canadian.amountDue, const Money(21.26, Currency.cad));
      expect(canadian.hasItemisedCharges, isTrue);
      expect(plain.hasItemisedCharges, isFalse);
    });
  });

  group('money', () {
    test('a Canadian total keeps its cents', () {
      expect(Money.parseAmount(21.26), 21.26);
      expect(Money.parseAmount('21.26'), 21.26);
    });

    test('adding across currencies throws rather than silently summing', () {
      expect(() => const Money(1, Currency.ngn) + const Money(1, Currency.cad),
          throwsArgumentError);
    });
  });

  group('stale quote detection', () {
    test('recognises the servers two rejection messages', () {
      expect(isStaleQuoteMessage('Quote has expired'), isTrue);
      expect(isStaleQuoteMessage('This quote has already been used'), isTrue);
      expect(isStaleQuoteMessage('Insufficient wallet balance'), isFalse);
    });
  });
}
