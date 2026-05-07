// lib/services/orders_service.dart

// ignore_for_file: unused_field

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/features/booking/model/order_model.dart'; // Contains OrderModel and QuoteResponseModel
import 'package:starter_codes/features/booking/model/request.dart';
import 'package:starter_codes/features/payment/model/order_initiation_response_model.dart'; // Contains CreateOrderRequest and GetQuoteRequest

class BookingService {
  final NetworkClient _networkClient;
  final LocalCache _localCache;
  final AppLogger logger;

  BookingService(this._networkClient, this._localCache, this.logger);

  Future<OrderInitiationResponse> createOrder({
    required CreateOrderRequest orderDetails,
  }) async {
    try {
      logger.i('Order Request: ${orderDetails.toJson()}');
      final responseData = await _networkClient.post(
        ApiRoute.createOrderNew,
        body: orderDetails.toJson(), // Convert the request model to JSON
      );
      logger.i('Order created successfully: $responseData');
      final paymentInitiationDetails =
          OrderInitiationResponse.fromJson(responseData['data']);
      return paymentInitiationDetails; // Return the 'data' part of the response
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

      logger.d(
          'Sending quote request for deliveryType: $deliveryType with body: $requestBody');

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

  /// Fetches an external delivery quote from Chowdeck.
  Future<QuoteResponseModel> _getChowdeckQuote({
    required GetQuoteRequest quoteDetails,
  }) async {
    try {
      final requestBody = {
        "dropoffLocation": {
          "lat": quoteDetails.dropoffLocation.lat,
          "lng": quoteDetails.dropoffLocation.lng
        },
        "pickupLocation": {
          "lat": quoteDetails.pickupLocation.lat,
          "lng": quoteDetails.pickupLocation.lng
        }
      };

      logger.d('Sending Chowdeck quote request: $requestBody');

      final responseData = await _networkClient.post(
        ApiRoute.getChowdeckQuote,
        body: requestBody,
      );

      logger.i('Chowdeck quote generated successfully: $responseData');

      // Map the response to QuoteResponseModel
      final data = responseData['data'];
      return QuoteResponseModel(
        state: quoteDetails.state,
        orderType: quoteDetails.orderType,
        deliveryType: 'priority', // Chowdeck is Priority+
        vehicleRequest: quoteDetails.vehicleRequest,
        price: (data['vinkol_amount'] as num).toDouble(),
        pickupLocation: LatLngLiteral(
          lat: double.parse(quoteDetails.pickupLocation.lat),
          lng: double.parse(quoteDetails.pickupLocation.lng),
        ),
        dropoffLocation: LatLngLiteral(
          lat: double.parse(quoteDetails.dropoffLocation.lat),
          lng: double.parse(quoteDetails.dropoffLocation.lng),
        ),
        id: data['id'],
        vinkolAmount: (data['vinkol_amount'] as num).toDouble(),
        isAvailable: true,
      );
    } catch (e) {
      logger.e('Failed to get Chowdeck quote: $e');
      rethrow;
    }
  }

  /// Fetches quotes for 'regular', 'express', and 'priority' delivery types.
  Future<List<QuoteResponseModel>> getAllQuotesForDeliveryTypes({
    required GetQuoteRequest baseQuoteDetails,
  }) async {
    List<QuoteResponseModel> quotes = [];

    // 1. Regular Quote (Internal)
    try {
      final regularQuote = await _getQuote(
        quoteDetails: baseQuoteDetails,
        deliveryType: 'regular',
      );
      quotes.add(regularQuote);
    } catch (e) {
      logger.e('Error fetching regular quote: $e');
      quotes.add(QuoteResponseModel(
          state: baseQuoteDetails.state,
          orderType: baseQuoteDetails.orderType,
          deliveryType: 'regular',
          vehicleRequest: baseQuoteDetails.vehicleRequest,
          price: 0,
          pickupLocation: LatLngLiteral(lat: 0, lng: 0),
          dropoffLocation: LatLngLiteral(lat: 0, lng: 0),
          isAvailable: false,
          unavailableMessage: "Regular delivery unavailable"));
    }

    // 2. Express Quote (Internal)
    try {
      final expressQuote = await _getQuote(
        quoteDetails: baseQuoteDetails,
        deliveryType: 'express',
      );
      quotes.add(expressQuote);
    } catch (e) {
      logger.e('Error fetching express quote: $e');
      quotes.add(QuoteResponseModel(
          state: baseQuoteDetails.state,
          orderType: baseQuoteDetails.orderType,
          deliveryType: 'express',
          vehicleRequest: baseQuoteDetails.vehicleRequest,
          price: 0,
          pickupLocation: LatLngLiteral(lat: 0, lng: 0),
          dropoffLocation: LatLngLiteral(lat: 0, lng: 0),
          isAvailable: false,
          unavailableMessage: "Express delivery unavailable"));
    }

    // 3. Priority+ Quote (Chowdeck)
    try {
      final priorityQuote = await _getChowdeckQuote(
        quoteDetails: baseQuoteDetails,
      );
      quotes.add(priorityQuote);
    } catch (e) {
      logger.e('Error fetching priority quote: $e');
      quotes.add(QuoteResponseModel(
          state: baseQuoteDetails.state,
          orderType: baseQuoteDetails.orderType,
          deliveryType: 'priority',
          vehicleRequest: baseQuoteDetails.vehicleRequest,
          price: 0,
          pickupLocation: LatLngLiteral(lat: 0, lng: 0),
          dropoffLocation: LatLngLiteral(lat: 0, lng: 0),
          isAvailable: false,
          unavailableMessage: "Priority+ delivery unavailable"));
    }

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
