import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart'; // Import Dio
import 'package:starter_codes/core/constants/api_routes.dart'; // Ensure this is correctly defined
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Keep if you want to define the provider here

// You might still want an interface for testing purposes
abstract class IPaystackService {
  Future<String?> initializePayment({
    required double amount,
    required String email,
    required String reference,
    String? currency,
    String? callbackUrl,
    Map<String, dynamic>? metadata,
  });

  Future<bool?> verifyPayment({
    required String reference,
  });
}

class PaystackService implements IPaystackService {
  final Dio _dio; // Use Dio instead of NetworkClient
  final AppLogger _logger = const AppLogger(PaystackService);

  PaystackService({required Dio dio}) : _dio = dio; // Inject Dio

  String? _getSecretKey() {
    // It's generally good to load dotenv once, typically in main.dart
    // and ensure it's loaded before accessing it.
    return dotenv.env['PAYSTACK_TEST_LIVE_KEY'];
    // return  dotenv.env['PAYSTACK_SECRET_LIVE_KEY'];
  }

  @override
  Future<String?> initializePayment({
    required double amount,
    required String email,
    required String reference,
    String? currency,
    String? callbackUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final secretKey = _getSecretKey();
    if (secretKey == null) {
      _logger.e(
          'Paystack secret key not found in .env. Cannot initialize payment.');
      throw Exception('Payment configuration error: Secret key missing.');
    }

    final int amountInSmallestUnit = (amount * 100).toInt();

    final Map<String, dynamic> body = {
      'email': email,
      'amount': amountInSmallestUnit, // Amount in kobo/cents
      'reference': reference,
      'currency': currency ?? 'NGN',
    };

    if (callbackUrl != null) {
      body['callback_url'] = callbackUrl;
    }
    if (metadata != null) {
      body['metadata'] = metadata;
    }

    _logger.i('Initializing Paystack transaction: ${jsonEncode(body)}');

    try {
      final response = await _dio.post(
        ApiRoute
            .paystackGenerateLink, // This should be 'https://api.paystack.co/transaction/initialize'
        data: body, // Use 'data' for POST body with Dio
        options: Options(
          headers: {
            'Authorization': 'Bearer $secretKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _logger.i('Paystack initialize response: ${response.data}');
        final responseData =
            response.data as Map<String, dynamic>; // Cast to Map
        if (responseData['status'] == true &&
            responseData['data'] != null &&
            responseData['data']['authorization_url'] != null) {
          return responseData['data']['authorization_url'] as String;
        } else {
          final String errorMessage =
              responseData['message'] ?? 'Unknown error initializing payment.';
          _logger.e(
              'Failed to get authorization_url: $errorMessage. Response: ${response.data}');
          throw Exception(errorMessage);
        }
      } else {
        final String errorMessage = response.data?['message'] ??
            'Unexpected response status: ${response.statusCode}';
        _logger.e(
            'Unexpected response during Paystack initialization: $errorMessage. Response: ${response.data}');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Catch Dio-specific exceptions
      _logger.e('DioException during Paystack initialization: $e');
      if (e.response != null) {
        _logger.e('Response data: ${e.response?.data}');
        final String errorMessage = e.response?.data?['message'] ??
            'Network error or Paystack API error.';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, st) {
      _logger.e('Generic Exception during Paystack initialization: $e\n$st');
      throw Exception('Failed to connect to payment gateway: ${e.toString()}');
    }
  }

  @override
  Future<bool?> verifyPayment({
    required String reference,
  }) async {
    final secretKey = _getSecretKey();
    if (secretKey == null) {
      _logger
          .e('Paystack secret key not found in .env. Cannot verify payment.');
      throw Exception('Payment configuration error: Secret key missing.');
    }

    final url =
        '${ApiRoute.paystackVerifyPayment}/$reference'; // This should be 'https://api.paystack.co/transaction/verify/{reference}'
    _logger
        .i('Verifying Paystack payment for reference: $reference at URL: $url');

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $secretKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _logger.i('Paystack verification response: ${response.data}');
        final responseData =
            response.data as Map<String, dynamic>; // Cast to Map
        if (responseData['status'] == true && responseData['data'] != null) {
          return responseData['data']['status'] ==
              'success'; // True if transaction status is 'success'
        } else {
          final String errorMessage =
              responseData['message'] ?? 'Unknown error verifying payment.';
          _logger.e(
              'Payment verification failed for reference $reference: $errorMessage. Response: ${response.data}');
          return false; // Indicate verification failed
        }
      } else {
        final String errorMessage = response.data?['message'] ??
            'Unexpected response status: ${response.statusCode}';
        _logger.e(
            'Unexpected response during Paystack verification: $errorMessage. Response: ${response.data}');
        return false; // Treat unexpected status as verification failure
      }
    } on DioException catch (e) {
      _logger.e('DioException during Paystack verification: $e');
      if (e.response != null) {
        _logger.e('Response data: ${e.response?.data}');
        final String errorMessage = e.response?.data?['message'] ??
            'Network error or Paystack API error.';
        throw Exception(errorMessage); // Propagate specific error message
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, st) {
      _logger.e('Generic Exception during Paystack verification: $e\n$st');
      throw Exception(
          'Failed to connect to payment gateway for verification: ${e.toString()}');
    }
  }
}

// Provider for Dio
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    // You can set a base URL here if all your Paystack API calls share one
    // baseUrl: 'https://api.paystack.co/',
    connectTimeout: const Duration(seconds: 15), // 15 seconds
    receiveTimeout: const Duration(seconds: 15), // 15 seconds
  ));
});

// Provider for PaystackService
final paystackServiceProvider = Provider<IPaystackService>((ref) {
  final dio = ref.watch(dioProvider);
  return PaystackService(dio: dio);
});
