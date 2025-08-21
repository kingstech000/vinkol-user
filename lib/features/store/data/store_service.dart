// lib/services/store_service.dart
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/model/store_request_model.dart';
// REMOVED: import 'package:starter_codes/features/store/model/product_model.dart'; // This was not part of the singleStore edit request
import 'package:starter_codes/features/store/model/store_response_model.dart';
import 'package:starter_codes/models/location_model.dart';

class StoreService {
  final NetworkClient _networkClient;
  final AppLogger logger;

  StoreService(this._networkClient, this.logger);

  /// Fetches a list of stores with optional filters.
  ///
  /// [state]: Filters stores by state (e.g., 'lagos').
  /// [search]: Searches for stores by name or description.
  /// [page]: The page number to retrieve.
  /// [limit]: The number of stores per page.
  Future<StoreResponse> getStores({
    String? state,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
        'state': state
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final responseData = await _networkClient.get(
        ApiRoute.stores,
        queryParameters: queryParameters,
      );

      logger.i('Stores API response: $responseData');

      return StoreResponse.fromJson(responseData);
    } on DioException catch (e) {
      logger.e('Failed to fetch stores: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch stores: $e');
      rethrow;
    }
  }

  /// Fetches a single store by its ID.
  ///
  /// [storeId]: The ID of the store to retrieve.
  Future<SingleStoreData> getSingleStore(String storeId) async {
    // CHANGED: Return type from SingleStoreResponseData to SingleStoreData
    try {
      final responseData = await _networkClient.get(
        '${ApiRoute.stores}/$storeId',
      );

      logger.i('Single Store API response: $responseData');

      // NEW LOGIC: Parse the full response into SingleStoreResponse
      final SingleStoreResponse singleStoreResponse =
          SingleStoreResponse.fromJson(responseData);

      // Then, return the nested 'data' object which is SingleStoreData
      return singleStoreResponse.data;
    } on DioException catch (e) {
      logger
          .e('Failed to fetch single store: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch single store: $e');
      rethrow;
    }
  }

  Future<PaginatedStoreProductsResponseData> getStoreProducts({
    required String storeId,
    String? category,
    String? search,
    int? minPrice,
    int? maxPrice,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'pageNo': pageNo,
        'pageSize': pageSize,
      };

      if (category != null && category.isNotEmpty) {
        queryParameters['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (minPrice != null) {
        queryParameters['price'] = 'gte:$minPrice';
      }
      if (maxPrice != null) {
        if (queryParameters.containsKey('price')) {
          queryParameters['price'] =
              '${queryParameters['price']},lte:$maxPrice';
        } else {
          queryParameters['price'] = 'lte:$maxPrice';
        }
      }

      final responseData = await _networkClient.get(
        '${ApiRoute.stores}/$storeId/products',
        queryParameters: queryParameters,
      );

      logger.i('Store Products API response: $responseData');

      final Map<String, dynamic> data =
          responseData['data'] as Map<String, dynamic>;

      return PaginatedStoreProductsResponseData.fromJson(data);
    } on DioException catch (e) {
      logger.e(
          'Failed to fetch store products: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch store products: $e');
      rethrow;
    }
  }

  Future<StoreProduct> getSingleProduct(String productId) async {
    // Reverted back to the original return type as per your instruction to only change singleStore.
    try {
      final responseData = await _networkClient.get(
        '${ApiRoute.products}/$productId', // Assuming this endpoint
      );

      logger.i('Single Product API response: $responseData');

      // Assuming the response for a single product is: { "success": true, "message": "...", "data": { ...product_data... } }
      // If 'SingleProductResponse' is a model that wraps this, then this is how it should be.
      // If 'SingleProductResponse' *is* the product itself, then the previous direct return was better.
      // For now, I'm making a safe assumption and returning the data field after parsing as StoreProduct.
      // You might need to adjust 'SingleProductResponse' if it's a wrapper for StoreProduct.
      // For this edit, I'm assuming 'StoreProduct' is the final desired object.
      if (responseData['data'] is Map<String, dynamic>) {
        return StoreProduct.fromJson(
            responseData['data'] as Map<String, dynamic>);
      } else {
        throw Exception("Invalid data format for single product response.");
      }
    } on DioException catch (e) {
      logger.e(
          'Failed to fetch single product: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch single product: $e');
      rethrow;
    }
  }

  /// Fetches the shopping delivery fee.
  ///
  /// [storeId]: The ID of the store.
  /// [dropoffLocation]: The drop-off location details.
  Future<double> fetchShoppingDeliveryFee({
    required String storeId,
    required LocationModel dropoffLocation,
    required String deliveryType,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "store": storeId,
        "deliveryType": deliveryType, // Assuming this is fixed for now
        "dropoffLocation": {
          "lat": dropoffLocation.coordinates!.latitude.toString(),
          "lng": dropoffLocation.coordinates!.longitude.toString(),
        }
      };

      logger.i('Fetching delivery fee with payload: $data');

      final responseData = await _networkClient.post(
        ApiRoute.shoppingDeliveryFee,
        body: data,
      );

      logger.i('Delivery Fee API response: $responseData');

      if (responseData['data'] != null &&
          responseData['data']['price'] != null) {
        return (responseData['data']['price'] as num).toDouble();
      } else {
        throw Exception("Delivery fee not found in the response.");
      }
    } on DioException catch (e) {
      logger.e(
          'Failed to fetch shopping delivery fee: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch shopping delivery fee: $e');
      rethrow;
    }
  }

  Future<DeliveryModel> createStoreOrder(
      CreateStoreOrderPayload orderPayload) async {
    logger.i(
        'Attempting to create store order with payload: ${orderPayload.toJson()}');
    try {
      final responseData = await _networkClient.post(
        ApiRoute.storeOrders, // Use the new API route constant
        body: orderPayload.toJson(),
      );

      logger.i('Store order creation response: $responseData');

      if (responseData['success'] == true) {
        // Assuming your API returns { "status": true, ... } on success
        logger.i('Store order created successfully.');
        final delivery = DeliveryModel.fromJson(responseData['data']);
        return delivery;
      } else {
        final String errorMessage =
            responseData['message'] ?? 'Unknown error creating order.';
        logger.e(
            'Failed to create store order: $errorMessage. Response: $responseData');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      logger.e(
          'DioException creating store order: ${e.response?.data ?? e.message}');
      throw Exception(
          'Network error or API error creating order: ${e.response?.data?['message'] ?? e.message}');
    } catch (e, st) {
      logger.e('Error creating store order: $e\n$st');
      throw Exception(
          'An unexpected error occurred while creating order: ${e.toString()}');
    }
  }
}

// Riverpod provider for StoreService remains the same
final storeServiceProvider = Provider((ref) => StoreService(
      NetworkClient(),
      const AppLogger(StoreService),
    ));
