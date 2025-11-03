import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/features/store/data/store_service.dart';
import 'package:starter_codes/features/store/model/store_request_model.dart';
import 'package:starter_codes/features/payment/model/order_initiation_response_model.dart';

class StoreOrderState {
  final bool isLoading;
  final String? error;

  StoreOrderState({
    this.isLoading = false,
    this.error,
  });

  StoreOrderState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return StoreOrderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StoreOrderViewModel extends StateNotifier<StoreOrderState> {
  final StoreService _storeService;
  final AppLogger _logger;

  StoreOrderViewModel(this._storeService, this._logger)
      : super(StoreOrderState());

  Future<OrderInitiationResponse?> createOrder(
    CreateStoreOrderPayload orderPayload,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    _logger.d('===== CREATING STORE ORDER ON BACKEND =====');

    try {
      final orderInitiationResponse =
          await _storeService.createStoreOrder(orderPayload);

      _logger.i(
          'Store order created. Order ID: ${orderInitiationResponse.order.id}');

      state = state.copyWith(isLoading: false);

      return orderInitiationResponse; // Return the response
    } catch (e, st) {
      _logger.e('Error creating store order: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().split(':').first,
      );
      return null; // Return null on error
    }
  }
}

final storeOrderViewModelProvider =
    StateNotifierProvider<StoreOrderViewModel, StoreOrderState>(
  (ref) => StoreOrderViewModel(
    ref.read(storeServiceProvider),
    const AppLogger(StoreOrderViewModel),
  ),
);
