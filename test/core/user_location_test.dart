import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/market/market_profile.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/models/location_model.dart';

void main() {
  group('a chosen location decides the market', () {
    test('a Canadian address resolves to the Canadian market', () {
      final toronto = LocationModel(
        formattedAddress: '100 Queen St W, Toronto, ON, Canada',
        state: 'Ontario',
        country: 'Canada',
      );
      expect(countryFromPlaceName(toronto.country), Country.ca);
      expect(countryFromPlaceName(toronto.country)!.profile.dialCode, '+1');
      expect(countryFromPlaceName(toronto.country)!.profile.regionLabel,
          'Province');
    });

    test('a Nigerian address resolves to the Nigerian market', () {
      final lagos = LocationModel(
        formattedAddress: 'Victoria Island, Lagos, Nigeria',
        state: 'Lagos',
        country: 'Nigeria',
      );
      expect(countryFromPlaceName(lagos.country), Country.ng);
      expect(countryFromPlaceName(lagos.country)!.profile.dialCode, '+234');
    });

    test('an address we do not serve leaves the market unchanged', () {
      final accra = LocationModel(country: 'Ghana');
      // Null means "keep what you had" — the caller must not default to NG.
      expect(countryFromPlaceName(accra.country), isNull);
    });

    test('a location with no country resolves to nothing', () {
      expect(countryFromPlaceName(LocationModel().country), isNull);
    });
  });

  group('the stored location survives a round trip', () {
    test('json keeps the country, which is what the market reads', () {
      final original = LocationModel(
        formattedAddress: '100 Queen St W, Toronto, ON, Canada',
        state: 'Ontario',
        country: 'Canada',
      );
      final restored = LocationModel.fromJson(original.toJson());
      expect(restored.country, 'Canada');
      expect(restored.state, 'Ontario');
      expect(countryFromPlaceName(restored.country), Country.ca);
    });
  });
}
