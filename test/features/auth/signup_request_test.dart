import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/features/auth/model/user_model.dart';

void main() {
  group('the register payload carries the market', () {
    test('a Nigerian signup sends NG', () {
      final json = SignupRequest(
        email: 'ada@example.com',
        password: 'hunter2',
        country: Country.ng,
      ).toJson();

      expect(json, {
        'email': 'ada@example.com',
        'password': 'hunter2',
        'country': 'NG',
      });
    });

    test('a Canadian signup sends CA, not the Nigerian default', () {
      final json = SignupRequest(
        email: 'ada@example.com',
        password: 'hunter2',
        country: Country.ca,
      ).toJson();

      expect(json['country'], 'CA');
    });
  });

  group('reading a payload back', () {
    test('an absent country reads as Nigeria, as legacy records do', () {
      final request = SignupRequest.fromJson({
        'email': 'ada@example.com',
        'password': 'hunter2',
      });

      expect(request.country, Country.ng);
    });

    test('a country is read off the payload when present', () {
      final request = SignupRequest.fromJson({
        'email': 'ada@example.com',
        'password': 'hunter2',
        'country': 'CA',
      });

      expect(request.country, Country.ca);
    });
  });
}
