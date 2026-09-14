import 'package:flutter_test/flutter_test.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/features/store/model/store_response_model.dart';

/// A store trades in one market. Whatever its product records say, a
/// customer sees the store's currency — never a naira sign on a Toronto shelf.
void main() {
  Map<String, dynamic> response({
    required String storeCountry,
    required String productCountry,
    required String productCurrency,
  }) =>
      {
        'store': {
          '_id': 's1',
          'name': 'Cole World Stores',
          'country': storeCountry,
          'currency': storeCountry == 'CA' ? 'CAD' : 'NGN',
        },
        'storeProducts': [
          {
            '_id': 'p1',
            'title': 'Green Striped flannel shirt',
            'price': 24.5,
            'store': 's1',
            'image': {'imageUrl': '', 'cloudinaryId': ''},
            'category': 'clothing-and-fashion',
            'slug': 'shirt',
            'country': productCountry,
            'currency': productCurrency,
          },
        ],
      };

  group('a store is the source of truth for its products\' market', () {
    test('a product recorded as NG under a Canadian store renders in CAD', () {
      final data = SingleStoreData.fromJson(response(
        storeCountry: 'CA',
        productCountry: 'NG',
        productCurrency: 'NGN',
      ));
      final product = data.storeProducts.single;

      expect(product.country, Country.ca);
      expect(product.currency, Currency.cad);
      expect(product.unitPrice.format(), 'C\$24.50');
    });

    test('a store naming its country but no currency trades in that market', () {
      final data = SingleStoreData.fromJson({
        'store': {'_id': 's1', 'name': 'Cole World Stores', 'country': 'CA'},
        'storeProducts': [
          {
            '_id': 'p1',
            'title': 'Ergonomic chair',
            'price': 65,
            'image': {'imageUrl': '', 'cloudinaryId': ''},
            'category': 'others',
            'slug': 'chair',
            'country': 'NG',
            'currency': 'NGN',
          },
        ],
      });
      expect(data.store.currency, Currency.cad);
      expect(data.storeProducts.single.unitPrice.format(), 'C\$65.00');
    });

    test('a matching country but wrong currency is corrected too', () {
      final data = SingleStoreData.fromJson(response(
        storeCountry: 'CA',
        productCountry: 'CA',
        productCurrency: 'NGN',
      ));
      expect(data.storeProducts.single.currency, Currency.cad);
    });

    test('a Nigerian store keeps naira, including legacy records with no market', () {
      final data = SingleStoreData.fromJson({
        'store': {'_id': 's3', 'name': 'Mama Put'},
        'storeProducts': [
          {
            '_id': 'n1',
            'title': 'Jollof rice',
            'price': 3500,
            'image': {'imageUrl': '', 'cloudinaryId': ''},
            'category': 'food',
            'slug': 'jollof',
          },
        ],
      });
      expect(data.storeProducts.single.unitPrice.format(), '₦3,500');
    });
  });
}
