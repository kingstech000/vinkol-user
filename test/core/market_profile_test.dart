import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/market/market_profile.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/utils/phone_number_utils.dart';

void main() {
  group('every market has a complete client profile', () {
    test('Nigeria', () {
      final p = Country.ng.profile;
      expect(p.placesCountryCode, 'NG');
      expect(p.dialCode, '+234');
      expect(p.regionLabel, 'State');
      expect(p.regions, contains('Lagos'));
      expect(p.clampPickToRegion, isTrue);
      expect(p.usesPostalCode, isFalse);
      // The placeholder has to be a number of the shape the field accepts,
      // or it teaches the wrong length.
      expect(p.phoneExample.replaceAll(' ', '').length, p.localPhoneDigits);
    });

    test('Canada', () {
      final p = Country.ca.profile;
      expect(p.placesCountryCode, 'CA');
      expect(p.dialCode, '+1');
      expect(p.regionLabel, 'Province');
      expect(p.regions, contains('Ontario'));
      expect(p.regions, contains('Quebec'));
      // No region boundary data outside Nigeria, so the pin must not be clamped.
      expect(p.clampPickToRegion, isFalse);
      expect(p.usesPostalCode, isTrue);
      expect(p.phoneExample.replaceAll(' ', '').length, p.localPhoneDigits);
    });

    test('no market opens its map in another market', () {
      // Toronto is west of the prime meridian; Lagos is east of it.
      expect(Country.ca.profile.defaultLng, lessThan(0));
      expect(Country.ng.profile.defaultLng, greaterThan(0));
    });
  });

  group('detecting a market from what Google returns', () {
    test('accepts the spelled-out country and the codes', () {
      expect(countryFromPlaceName('Nigeria'), Country.ng);
      expect(countryFromPlaceName('Canada'), Country.ca);
      expect(countryFromPlaceName('canada'), Country.ca);
      expect(countryFromPlaceName('CA'), Country.ca);
    });

    test('an unserved country resolves to null, not to Nigeria', () {
      // Null means "leave the market alone". Defaulting here would silently
      // reset a traveller's market every time they opened the app.
      expect(countryFromPlaceName('Ghana'), isNull);
      expect(countryFromPlaceName(''), isNull);
      expect(countryFromPlaceName(null), isNull);
    });
  });

  group('phone numbers validate against their own market', () {
    test('a Canadian number is accepted, which it was not before', () {
      // The old implementation returned null for any code that was not +234.
      expect(
        PhoneNumberUtils.validateAndFormatPhoneNumber('6479460011', '+1'),
        '+16479460011',
      );
    });

    test('Nigerian numbers still work in every form they are typed', () {
      const expected = '+2348012345678';
      for (final input in [
        '08012345678',
        '8012345678',
        '2348012345678',
        '+2348012345678',
        '+234 801 234 5678',
      ]) {
        expect(
          PhoneNumberUtils.validateAndFormatPhoneNumber(input, '+234'),
          expected,
          reason: 'failed for "$input"',
        );
      }
    });

    test('the wrong number of digits is rejected', () {
      expect(
        PhoneNumberUtils.validateAndFormatPhoneNumber('801234567', '+234'),
        isNull,
      );
      expect(
        PhoneNumberUtils.validateAndFormatPhoneNumber('80123456789', '+234'),
        isNull,
      );
    });

    test('display grouping follows the dial code it is given', () {
      expect(
        PhoneNumberUtils.formatForDisplay('+16479460011', '+1'),
        '+1 647 946 0011',
      );
      expect(
        PhoneNumberUtils.formatForDisplay('+2348012345678', '+234'),
        '+234 801 234 5678',
      );
    });
  });
}
