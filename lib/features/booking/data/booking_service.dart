// lib/services/orders_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/features/booking/model/order_model.dart'; // Contains OrderModel and QuoteResponseModel
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart'; // Contains CreateOrderRequest and GetQuoteRequest

class BookingService {
  final NetworkClient _networkClient;
  final LocalCache _localCache;
  final AppLogger logger;

  BookingService(this._networkClient, this._localCache, this.logger);

  Future<DeliveryModel> createOrder({
    required CreateOrderRequest orderDetails,
  }) async {
    try {
      logger.i('Order Request: ${orderDetails.toJson()}');
      final responseData = await _networkClient.post(
        ApiRoute.createOrder,
        body: orderDetails.toJson(), // Convert the request model to JSON
      );
      logger.i('Order created successfully: $responseData');
      final delivery= DeliveryModel.fromJson(responseData['data']);
      return delivery; // Return the 'data' part of the response
    } catch (e) {
      logger.e('Failed to create order: $e');
      rethrow;
    }
  }

  /// Fetches details for a single order by its ID.
  ///
  /// This function constructs the URL with the provided order ID and sends a GET request.
  /// It assumes authorization is handled globally by the `NetworkClient`'s interceptors.
  ///
  /// Returns an `OrderModel` object on success.
  /// Throws an exception if fetching the order details fails.
  Future<OrderModel> getOrderDetails({
    required String orderId,
  }) async {
    try {
      // The NetworkClient is assumed to automatically add the Authorization header
      final responseData = await _networkClient.get(
        '${ApiRoute.getSingleOrder}/$orderId', // Construct the URL with the order ID
      );

      // The actual order data is nested under the 'data' key in the response
      final order =
          OrderModel.fromJson(responseData['data'] as Map<String, dynamic>);
      logger.i('Order details fetched successfully for ID: $orderId');
      return order;
    } catch (e) {
      logger.e('Failed to fetch order details for ID $orderId: $e');
      rethrow;
    }
  }

  /// Fetches a delivery quote based on order details.
  ///
  /// This function takes a `GetQuoteRequest` object and sends a POST request
  /// to the get quote endpoint. It assumes authorization is handled globally
  /// by the `NetworkClient`'s interceptors.
  ///
  /// Returns a `QuoteResponseModel` object on success.
  /// Throws an exception if fetching the quote fails.
  Future<QuoteResponseModel> _getQuote({
    required GetQuoteRequest quoteDetails,
    required String deliveryType, // Explicitly pass deliveryType here
  }) async {
    try {
      // Create a mutable map from quoteDetails.toJson()
      final Map<String, dynamic> requestBody = quoteDetails.toJson();
      // Override or add the deliveryType to the request body
      requestBody['deliveryType'] = deliveryType;

      logger.d('Sending quote request for deliveryType: $deliveryType with body: $requestBody');

      final responseData = await _networkClient.post(
        ApiRoute.getQuote,
        body: requestBody, // Use the modified body
      );
      logger.i('Quote generated successfully for $deliveryType: $responseData');

      return QuoteResponseModel.fromJson(
          responseData['data'] as Map<String, dynamic>);
    } catch (e) {
      logger.e('Failed to get quote for $deliveryType: $e');
      rethrow;
    }
  }

  /// Fetches quotes for both 'express' and 'regular' delivery types.
  /// Returns a list of QuoteResponseModel.
  Future<List<QuoteResponseModel>> getAllQuotesForDeliveryTypes({
    required GetQuoteRequest baseQuoteDetails,
  }) async {
    List<QuoteResponseModel> quotes = [];

    // 1. Get quote for 'express'
    try {
      final expressQuote = await _getQuote(
        quoteDetails: baseQuoteDetails,
        deliveryType: 'express',
      );
      quotes.add(expressQuote);
    } catch (e) {
      logger.e('Error fetching express quote, continuing with regular: $e');
      // Decide if you want to rethrow here or just log and continue
      // For now, we'll just log and try for 'regular'
    }

    // 2. Get quote for 'regular'
    try {
      final regularQuote = await _getQuote(
        quoteDetails: baseQuoteDetails,
        deliveryType: 'regular',
      );
      quotes.add(regularQuote);
    } catch (e) {
      logger.e('Error fetching regular quote: $e');
      // If both fail, the list might be empty or contain only one.
      // You might want to throw an error if no quotes are retrieved.
      if (quotes.isEmpty) {
         rethrow; // Re-throw if even the regular quote failed and no express was found
      }
    }

    // You can sort the quotes here if needed, e.g., by price
    // quotes.sort((a, b) => a.totalAmount!.compareTo(b.totalAmount!));

    return quotes;
  }
}

/// Riverpod provider for BookingService
final ordersServiceProvider = Provider((ref) => BookingService(
      NetworkClient(),
      locator<LocalCache>(),
      const AppLogger(BookingService),
    ));

final bookingServiceProvider = Provider((ref) => BookingService(
      NetworkClient(),
      locator<LocalCache>(),
      const AppLogger(BookingService),
    ));
