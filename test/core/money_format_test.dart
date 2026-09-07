import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/extensions/double_extension.dart';
import 'package:starter_codes/core/extensions/string_extension.dart';
import 'package:starter_codes/core/money/money.dart';

void main() {
  group('money renders for its market', () {
    test('naira has no decimals', () {
      expect(const Money(3450, Currency.ngn).format(), '₦3,450');
      expect(const Money(69942, Currency.ngn).format(), '₦69,942');
    });

    test('canadian dollars always show cents', () {
      expect(const Money(21.26, Currency.cad).format(), 'C\$21.26');
      expect(const Money(18, Currency.cad).format(), 'C\$18.00');
    });

    test('the worked example from the migration guide', () {
      // C$18.00 fare + C$0.81 processing + C$2.45 HST = C$21.26 charged.
      const fare = Money(18.00, Currency.cad);
      const fee = Money(0.81, Currency.cad);
      const tax = Money(2.45, Currency.cad);
      expect((fare + fee + tax).format(), 'C\$21.26');
    });

    test('the symbol can be suppressed where it is drawn separately', () {
      expect(const Money(21.26, Currency.cad).format(showSymbol: false), '21.26');
      expect(const Money(3450, Currency.ngn).format(showSymbol: false), '3,450');
    });
  });

  group('the toMoney extensions default to naira but accept a market', () {
    test('double', () {
      expect(4836.0.toMoney(), '₦4,836');
      expect(21.26.toMoney(Currency.cad), 'C\$21.26');
      expect(0.0.toMoneyShowFree(), 'Free');
      expect(4836.0.toMoneyWithoutSymbol(), '4,836');
    });

    test('string', () {
      expect('4836'.toMoney(), '₦4,836');
      expect('21.26'.toMoney(Currency.cad), 'C\$21.26');
      expect('not a number'.toMoney(), 'not a number');
    });
  });

  group('no naira symbol can reach a Canadian amount', () {
    test('a CAD amount never renders with the naira sign', () {
      final rendered = const Money(21.26, Currency.cad).format();
      expect(rendered.contains('₦'), isFalse);
      expect(rendered.startsWith('C\$'), isTrue);
    });
  });
}
