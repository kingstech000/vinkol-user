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

  /// Fetches the user's payment history from the API.
  Future<List<PaymentHistory>> fetchPaymentHistory() async {
    _logger.d('WalletService: Attempting to fetch payment history from API...');
    try {
      final response = await _apiClient.get(ApiRoute.wallet);

      // Log the full response data for debugging purposes
      _logger.d('WalletService: Raw API response data: $response');

      // Check if the response data is a Map and contains a 'data' key
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> responseDataList =
            response['data']; // Access the 'data' array

        _logger.d(
            'WalletService: Successfully received ${responseDataList.length} payment history items from the "data" array.');

        // Map the list of dynamic items to PaymentHistory objects
        return responseDataList
            .map((json) => PaymentHistory.fromJson(json))
            .toList();
      } else {
        _logger.w(
            'WalletService: API response did not contain expected "data" array or was not a Map.');
        // Return an empty list if the structure is not as expected, or throw a specific error
        return [];
      }
    } catch (e, st) {
      _logger.e('WalletService: Failed to fetch payment history.',
          error: e, stackTrace: st);
      rethrow; // Re-throw the error for the ViewModel to handle
    }
  }

  /// Fetch the wallet balance for the current user
  Future<double> fetchWalletBalance() async {
    _logger.d('WalletService: Attempting to fetch wallet balance from API...');
    try {
      final response = await _apiClient.get(ApiRoute.walletBalance);
      _logger.d('WalletService: Raw wallet balance response: $response');

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        final balance =
            data != null && data['balance'] != null ? data['balance'] : 0;
        if (balance is num) return balance.toDouble();
        return double.tryParse(balance.toString()) ?? 0.0;
      }

      return 0.0;
    } catch (e, st) {
      _logger.e('WalletService: Failed to fetch wallet balance.',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Request a fund-wallet payment link from the backend
  /// Returns the data map containing `authorization_url` and `reference` on success
  Future<Map<String, dynamic>> fundWallet(
      double amount, String? paymentSource) async {
    _logger.d(
        'WalletService: Generating fund-wallet link for amount: $amount with source: $paymentSource');
    try {
      final body = {
        'amount': amount,
        if (paymentSource != null) 'paymentSource': paymentSource
      };
      final response = await _apiClient.post(ApiRoute.fundWallet, body: body);
      _logger.d('WalletService: Raw fund-wallet response: $response');

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return Map<String, dynamic>.from(response['data']);
      }

      throw Exception('Unexpected response from fund-wallet endpoint');
    } catch (e, st) {
      _logger.e('WalletService: Failed to generate fund-wallet link.',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal(
    double amount, {
    String? reason,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiRoute.withdraw,
        body: {
          'amount': amount,
        },
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      throw Exception('Withdrawal request failed');
    } catch (e) {
      throw Exception('Withdrawal error: $e');
    }
  }

  Future<Map<String, dynamic>> getWithdrawalHistory({
    int page = 1,
    int limit = 10,
  }) async {
    _logger.d(
        'WalletService: Fetching withdrawal history (page=$page, limit=$limit)');
    try {
      final response = await _apiClient.get(
        ApiRoute.withdrawalHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      _logger.d('WalletService: Raw withdrawal history response: $response');
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is List) {
        // Handle case where it returns a direct list
        _logger.w(
            'WalletService: Withdrawal history response is a List, wrapping in a map.');
        return {'data': response};
      }
      _logger.w(
          'WalletService: Unexpected response type for withdrawal history: ${response.runtimeType}');
      return {};
    } catch (e, st) {
      _logger.e('WalletService: Failed to fetch withdrawal history',
          error: e, stackTrace: st);
      return {};
    }
  }
}
