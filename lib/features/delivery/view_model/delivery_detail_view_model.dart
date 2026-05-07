import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/delivery/data/delivery_service.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/core/utils/app_logger.dart';

// Defines if specific cancel action is loading
final isCancellingProvider = StateProvider<bool>((ref) => false);

// Define a provider for your DeliveryDetailsViewModel
final deliveryDetailsViewModelProvider =
    StateNotifierProvider<DeliveryDetailsViewModel, AsyncValue<DeliveryModel?>>(
        (ref) {
  final deliveryService = ref.read(deliveryServiceProvider);
  const logger = AppLogger(DeliveryDetailsViewModel);
  return DeliveryDetailsViewModel(deliveryService, logger);
});

class DeliveryDetailsViewModel
    extends StateNotifier<AsyncValue<DeliveryModel?>> {
  final DeliveryService _deliveryService;
  final AppLogger _logger;

  DeliveryDetailsViewModel(this._deliveryService, this._logger)
      : super(const AsyncValue.data(null));

  Future<void> fetchDeliveryById(String deliveryId,
      {bool refresh = false}) async {
    // Only show loading if we are NOT refreshing AND the current data doesn't match the requested ID
    // (i.e. we are fetching a completely new order, or we have no data yet).
    if (!refresh && state.value?.id != deliveryId) {
      state = const AsyncValue.loading();
    }
    try {
      final DeliveryModel delivery =
          await _deliveryService.getDeliveryOrderById(deliveryId);
      state = AsyncValue.data(delivery);
      _logger.d('Fetched delivery details for ID: $deliveryId');
    } catch (e, st) {
      _logger.e(
        'Error fetching delivery details for ID: $deliveryId',
      );
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      await _deliveryService.cancelOrder(orderId);
      _logger.i('Order $orderId cancelled successfully');
      // Refresh the delivery details to update status
      await fetchDeliveryById(orderId, refresh: true);
      return true;
    } catch (e) {
      _logger.e('Error cancelling order: $e');
      // We don't set global error state here to avoid replacing the UI with an error screen,
      // instead we return false and let UI handle the error dialog.
      return false;
    }
  }
}
