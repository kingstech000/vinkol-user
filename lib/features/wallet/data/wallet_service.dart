// lib/features/wallet/data/wallet_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/core/utils/network_client.dart'; // Your specified NetworkClient
import 'package:starter_codes/features/wallet/model/payment_history_model.dart';
import 'package:starter_codes/core/utils/app_logger.dart';



final walletServiceProvider = Provider((ref) => WalletService(
      NetworkClient(),
      const AppLogger(WalletService),
    ));


class WalletService {
  final NetworkClient _apiClient;
  final AppLogger _logger;

  WalletService(this._apiClient, this._logger);

  /// Fetches the user's withdrawal history from the API.
 Future<List<PaymentHistory>> fetchWithdrawalHistory() async {
    _logger.d('WalletService: Attempting to fetch withdrawal history from API...');
    try {
      final response = await _apiClient.get(ApiRoute.wallet);

      // Log the full response data for debugging purposes
      _logger.d('WalletService: Raw API response data: $response');

      // Check if the response data is a Map and contains a 'data' key
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> responseDataList = response['data']; // Access the 'data' array

        _logger.d('WalletService: Successfully received ${responseDataList.length} withdrawal history items from the "data" array.');

        // Map the list of dynamic items to WithdrawalHistory objects
        return responseDataList.map((json) => PaymentHistory.fromJson(json)).toList();
      } else {
        _logger.w('WalletService: API response did not contain expected "data" array or was not a Map.');
        // Return an empty list if the structure is not as expected, or throw a specific error
        return [];
      }
    } catch (e, st) {
      _logger.e('WalletService: Failed to fetch withdrawal history.', error: e, stackTrace: st);
      rethrow; // Re-throw the error for the ViewModel to handle
    }
  }

}