import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/features/delivery/data/delivery_service.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';

import 'package:starter_codes/core/utils/app_logger.dart';

// Define a provider for your DeliveryDetailsViewModel
final deliveryDetailsViewModelProvider = StateNotifierProvider<DeliveryDetailsViewModel, AsyncValue<DeliveryModel?>>((ref) {
  final deliveryService = ref.read(deliveryServiceProvider);
  const logger = AppLogger(DeliveryDetailsViewModel);
  return DeliveryDetailsViewModel(deliveryService, logger);
});

class DeliveryDetailsViewModel extends StateNotifier<AsyncValue<DeliveryModel?>> {
  final DeliveryService _deliveryService;
  final AppLogger _logger;

  DeliveryDetailsViewModel(this._deliveryService, this._logger) : super(const AsyncValue.data(null));

  Future<void> fetchDeliveryById(String deliveryId) async {
    state = const AsyncValue.loading();
    try {
      final DeliveryModel delivery = await _deliveryService.getDeliveryOrderById(deliveryId);
      state = AsyncValue.data(delivery);
      _logger.d('Fetched delivery details for ID: $deliveryId');
    } catch (e, st) {
      _logger.e('Error fetching delivery details for ID: $deliveryId', );
      state = AsyncValue.error(e, st);
    }
  }
}