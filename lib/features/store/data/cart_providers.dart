import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/model/store_response_model.dart';
import 'package:starter_codes/models/location_model.dart';

/// What a shopping delivery quote depends on.
///
/// Equatable on purpose: this keys a `family` provider, so two structurally equal params must
/// hit the same cache entry or every rebuild refetches the quote.
class DeliveryFeeParams extends Equatable {
  const DeliveryFeeParams({
    required this.dropOffLocation,
    required this.products,
  });

  final LocationModel? dropOffLocation;
  final List<StoreProduct> products;

  @override
  List<Object?> get props => <Object?>[dropOffLocation, products];
}

/// The delivery options for a cart, **quoted** by `orders/shopping-delivery-fee`.
///
/// This is the difference between shopping and booking that most shapes the screen: the fee
/// is not computed from a distance the app knows, it comes back from the server, and it comes
/// back as a list — a Vinkol rider and, where one covers the route, a partner courier. Until
/// there is a drop-off address there is nothing to ask for, so the provider returns empty
/// rather than throwing.
final AutoDisposeFutureProviderFamily<List<QuoteResponseModel>,
        DeliveryFeeParams> deliveryFeeProvider =
    FutureProvider.autoDispose
        .family<List<QuoteResponseModel>, DeliveryFeeParams>(
  (Ref ref, DeliveryFeeParams params) async {
    final AppLogger logger = ref.read(appLoggerProvider);
    final LocationModel? dropOffLocation = params.dropOffLocation;

    if (dropOffLocation == null || params.products.isEmpty) {
      return <QuoteResponseModel>[];
    }

    // One store per cart is enforced by the cart itself, so the first product's store is
    // the store, and it is also the pickup point — the user never chooses one.
    final String? storeId = params.products.first.store;
    if (storeId == null || storeId.isEmpty) {
      throw Exception('Store ID not found');
    }

    try {
      return await ref.read(storeServiceProvider).fetchDeliveryQuote(
            storeId: storeId,
            dropoffLocation: dropOffLocation,
          );
    } catch (e, st) {
      logger.e('Failed to fetch delivery quotes: $e', error: e, stackTrace: st);
      rethrow;
    }
  },
);

final FutureProviderFamily<SingleStoreData, String> storeDetailsProvider =
    FutureProvider.family<SingleStoreData, String>(
        (Ref ref, String storeId) async {
  return ref.read(storeServiceProvider).getSingleStore(storeId);
});
