import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/core/extensions/string_extension.dart';
// Imported file-by-file rather than through the `market.dart` barrel on purpose: the
// formatting engine must not depend on Riverpod, the service locator or the network layer,
// and importing the barrel here would hide it if it ever did.
import 'package:starter_codes/core/market/market_format.dart';
import 'package:starter_codes/core/market/market_scope.dart';
import 'package:starter_codes/core/market/markets.dart';

void main() {
  setUp(() => MarketScope.resolve(Markets.nigeria));

  group('Nigeria renders exactly what it rendered before the market layer', () {
    // Golden values measured from the pre-WP2 formatters. Nigeria is the live market: any
    // change here is a regression, not a refactor.
    test('double.toMoney is the symbol plus a grouped integer', () {
      expect(2500.0.toMoney(), '₦2,500');
      expect(0.0.toMoney(), '₦0');
      expect(1000000.0.toMoney(), '₦1,000,000');
      expect(1234.5.toMoney(), '₦1,235'); // rounds, as it always did
    });

    test('String.toMoney keeps two decimal places', () {
      expect('1234.5'.toMoney(), '₦1,234.50');
      expect('not a number'.toMoney(), 'not a number');
    });

    test('toMoneyShowFree and toMoneyWithoutSymbol are unchanged', () {
      expect(0.0.toMoneyShowFree(), 'Free');
      expect(2500.0.toMoneyShowFree(), '₦2,500');
      expect(2500.0.toMoneyWithoutSymbol(), '2,500');
    });

    test('the two AmountTextFormatter registers keep their precision', () {
      expect(MarketFormat.money(2500), '₦2,500');
      expect(MarketFormat.moneyPrecise(2500), '₦2,500.00');
    });
  });

  group('Canada', () {
    setUp(() => MarketScope.resolve(Markets.canada));

    test('same call site, different currency, decimals and grouping', () {
      expect(2500.0.toMoney(), r'CA$2,500.00');
      expect(1234.5.toMoney(), r'CA$1,234.50');
      expect(2500.0.toMoneyWithoutSymbol(), '2,500.00');
    });
  });

  group('tax is a region property, not a market one', () {
    test('Nigeria displays no tax line at all', () {
      expect(MarketFormat.tax(10000), isNull);
    });

    test('two provinces of one country produce different tax', () {
      MarketScope.resolve(Markets.canada,
          region: Markets.canada.regionByCode('ON'));
      final ontario = MarketFormat.tax(100)!;
      expect(ontario.label, 'HST');
      expect(ontario.amount, closeTo(13.0, 0.0001));

      MarketScope.resolveRegion(Markets.canada.regionByCode('AB'));
      final alberta = MarketFormat.tax(100)!;
      expect(alberta.label, 'GST');
      expect(alberta.amount, closeTo(5.0, 0.0001));
    });

    test('a label can name two taxes', () {
      MarketScope.resolve(Markets.canada,
          region: Markets.canada.regionByCode('QC'));
      final quebec = MarketFormat.tax(100)!;
      expect(quebec.label, 'GST + QST');
      expect(quebec.amount, closeTo(14.975, 0.0001));
    });
  });

  group('address is an ordered field set, not a struct', () {
    test('the two markets disagree on both count and order', () {
      expect(
        Markets.nigeria.addressFields.map((f) => f.key),
        <String>['street', 'area', 'state'],
      );
      expect(
        Markets.canada.addressFields.map((f) => f.key),
        <String>['street', 'city', 'province', 'postalCode'],
      );
      expect(Markets.nigeria.usesPostalCode, isFalse);
      expect(Markets.canada.usesPostalCode, isTrue);
    });

    test('Canada cannot deliver without a valid postal code', () {
      final field = Markets.canada.addressField('postalCode')!;
      expect(field.isRequired, isTrue);
      expect(field.validate('K1A 0B1'), isTrue);
      expect(field.validate('k1a0b1'), isTrue);
      expect(field.validate('D1A 0B1'), isFalse); // D is never used
      expect(field.validate('12345'), isFalse); // a US ZIP
      expect(field.validate(''), isFalse); // required
    });

    test('the region label is market copy', () {
      expect(Markets.nigeria.regionLabel, 'State');
      expect(Markets.canada.regionLabel, 'Province');
    });
  });

  group('regions', () {
    test('Nigeria still lists all 37 states, by the names the API stores', () {
      expect(Markets.nigeria.regions, hasLength(37));
      expect(Markets.nigeria.regionNames, contains('Lagos'));
      expect(Markets.nigeria.regionNames, contains('FCT'));
      expect(Markets.nigeria.regionByName('Lagos')?.code, 'LA');
    });

    test('an unrecognised region resolves to null rather than a default', () {
      expect(Markets.nigeria.regionByName('Ontario'), isNull);
      expect(Markets.canada.regionByName('Lagos'), isNull);
    });

    test('switching market drops a region that does not belong to it', () {
      MarketScope.resolve(Markets.canada,
          region: Markets.canada.regionByCode('ON'));
      expect(MarketScope.region.name, 'Ontario');
      MarketScope.resolve(Markets.nigeria,
          region: Markets.canada.regionByCode('ON'));
      expect(MarketScope.region.name, isNot('Ontario'));
      expect(Markets.nigeria.regions, contains(MarketScope.region));
    });
  });

  group('amount entry', () {
    test('parse round-trips what the formatter produced', () {
      expect(MarketFormat.parse('1,234'), 1234);
      expect(MarketFormat.parse('₦1,234'), 1234);
      expect(MarketFormat.parse(''), 0);
      MarketScope.resolve(Markets.canada);
      expect(MarketFormat.parse(r'CA$1,234.56'), closeTo(1234.56, 0.0001));
    });
  });
}
