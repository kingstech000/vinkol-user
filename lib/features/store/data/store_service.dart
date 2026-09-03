import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/features/payment/model/order_initiation_response_model.dart';
import 'package:starter_codes/features/store/model/store_model.dart';
import 'package:starter_codes/features/store/model/store_request_model.dart';
import 'package:starter_codes/features/store/model/store_response_model.dart';
import 'package:starter_codes/features/store/model/store_tag_model.dart';
import 'package:starter_codes/models/location_model.dart';
import 'package:starter_codes/features/booking/model/order_model.dart';

class StoreService {
  final NetworkClient _networkClient;
  final AppLogger logger;

  StoreService(this._networkClient, this.logger);

  /// Fetches a list of stores with optional filters.
  Future<StoreResponse> getStores({
    String? state,
    String? search,
    String? tags,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };

      if (state != null && state.trim().isNotEmpty) {
        queryParameters['state'] = state.trim();
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      if (tags != null && tags.trim().isNotEmpty) {
        queryParameters['tags'] = tags.trim();
      }

      logger.d('Fetching stores with query parameters: $queryParameters');

      final responseData = await _networkClient.get(
        '/stores/all',
        queryParameters: queryParameters,
      );

      logger.i('Stores API response: $responseData');

      if (responseData['data'] is Map<String, dynamic>) {
        final data = responseData['data'] as Map<String, dynamic>;
        final stores = data['fetchedData'] as List?;
        logger.d('Response contains ${stores?.length ?? 0} stores');
        if (tags != null && tags.isNotEmpty && stores != null) {
          final matchingStores = stores.where((store) {
            final storeTags = store['tags'] as List?;
            return storeTags != null && storeTags.contains(tags);
          }).length;
          logger.d(
              'API returned $matchingStores stores matching tag "$tags" out of ${stores.length} total stores.');
        }
      }

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
  Future<SingleStoreData> getSingleStore(String storeId) async {
    try {
      final responseData = await _networkClient.get(
        '${ApiRoute.stores}/$storeId',
      );

      logger.i('Single Store API response: $responseData');

      final SingleStoreResponse singleStoreResponse =
          SingleStoreResponse.fromJson(responseData);

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
    try {
      final responseData = await _networkClient.get(
        '${ApiRoute.products}/$productId',
      );

      logger.i('Single Product API response: $responseData');

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

  /// Fetches the shopping delivery fee (Legacy / Regular logic support).
  /// Used internally as fallback for Express logic.
  Future<double> fetchShoppingDeliveryFee({
    required String storeId,
    required LocationModel dropoffLocation,
    required String deliveryType,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "store": storeId,
        "deliveryType": deliveryType,
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

  /// Fetches delivery quotes for store orders.
  /// Returns a list containing Internal (Express) and External (Priority/Chowdeck) quotes.
  Future<List<QuoteResponseModel>> fetchDeliveryQuote({
    required String storeId,
    required LocationModel dropoffLocation,
  }) async {
    // 1. Fetch Store Details to get Pickup Coordinates
    final singleStoreData = await getSingleStore(storeId);
    final store = singleStoreData.store;

    if (store.lat == null || store.lng == null) {
      throw Exception("Store location coordinates are missing.");
    }

    List<QuoteResponseModel> quotes = [];

    // 2. Fetch Internal Express Quote (Always try to get this)
    try {
      final internalFee = await fetchShoppingDeliveryFee(
        storeId: storeId,
        dropoffLocation: dropoffLocation,
        deliveryType: 'express',
      );

      quotes.add(QuoteResponseModel(
        price: internalFee,
        deliveryType: 'express',
        vinkolAmount: internalFee,
        state: '',
        orderType: 'Shopping',
        vehicleRequest: 'bike',
        id: null, // Internal provider
        pickupLocation: LatLngLiteral(lat: store.lat!, lng: store.lng!),
        dropoffLocation: LatLngLiteral(
            lat: dropoffLocation.coordinates!.latitude,
            lng: dropoffLocation.coordinates!.longitude),
        isAvailable: true,
      ));
    } catch (e) {
      logger.e('Internal Express quote failed: $e');
      // Add an unavailable placeholder if needed, or just don't add it.
      // For now, let's add it as unavailable so the UI shows it.
      quotes.add(QuoteResponseModel(
        price: 0,
        deliveryType: 'express',
        vinkolAmount: 0,
        state: '',
        orderType: 'Shopping',
        vehicleRequest: 'bike',
        id: null,
        pickupLocation: LatLngLiteral(lat: store.lat!, lng: store.lng!),
        dropoffLocation: LatLngLiteral(
            lat: dropoffLocation.coordinates!.latitude,
            lng: dropoffLocation.coordinates!.longitude),
        isAvailable: false,
        unavailableMessage: 'Express delivery unavailable',
      ));
    }

    // 3. Fetch Chowdeck Quote (Priority+)
    try {
      final chowdeckQuote = await _getChowdeckQuote(
        pickupLat: store.lat!,
        pickupLng: store.lng!,
        dropoffLat: dropoffLocation.coordinates!.latitude,
        dropoffLng: dropoffLocation.coordinates!.longitude,
      );

      // Override deliveryType to 'priority' for the UI/logic to recognize it as Premium
      final priorityQuote = chowdeckQuote.copyWith(deliveryType: 'priority');
      quotes.add(priorityQuote);
    } catch (e) {
      logger.w('Chowdeck (Priority) quote failed: $e');
      quotes.add(QuoteResponseModel(
        price: 0,
        deliveryType: 'priority',
        vinkolAmount: 0,
        state: '',
        orderType: 'Shopping',
        vehicleRequest: 'bike',
        id: null, // No ID means no external booking possible
        pickupLocation: LatLngLiteral(lat: store.lat!, lng: store.lng!),
        dropoffLocation: LatLngLiteral(
            lat: dropoffLocation.coordinates!.latitude,
            lng: dropoffLocation.coordinates!.longitude),
        isAvailable: false,
        unavailableMessage: 'Priority delivery unavailable',
      ));
    }

    return quotes;
  }

  Future<QuoteResponseModel> _getChowdeckQuote({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    try {
      final requestBody = {
        "dropoffLocation": {
          "lat": dropoffLat.toString(),
          "lng": dropoffLng.toString()
        },
        "pickupLocation": {
          "lat": pickupLat.toString(),
          "lng": pickupLng.toString()
        }
      };

      logger.d('Sending Chowdeck quote request: $requestBody');

      final responseData = await _networkClient.post(
        ApiRoute.getChowdeckQuote,
        body: requestBody,
      );

      logger.i('Chowdeck quote generated successfully: $responseData');

      final data = responseData['data'];
      return QuoteResponseModel(
        state: '',
        orderType: 'Shopping',
        deliveryType: 'express',
        vehicleRequest: 'bike',
        price: (data['vinkol_amount'] as num).toDouble(),
        pickupLocation: LatLngLiteral(lat: pickupLat, lng: pickupLng),
        dropoffLocation: LatLngLiteral(lat: dropoffLat, lng: dropoffLng),
        id: data[
            'id'], // If using External, this should map to externalDeliveryFeeId
        vinkolAmount: (data['vinkol_amount'] as num).toDouble(),
      );
    } catch (e) {
      logger.e('Failed to get Chowdeck quote: $e');
      rethrow;
    }
  }

  Future<OrderInitiationResponse> createStoreOrder(
      CreateStoreOrderPayload orderPayload) async {
    logger.i('Creating store order with payload: ${orderPayload.toJson()}');

    try {
      final responseData = await _networkClient.post(
        ApiRoute.storeOrderNew,
        body: orderPayload.toJson(),
      );

      logger.i('Store order creation response: $responseData');

      final orderInitiation = OrderInitiationResponse.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );

      logger.i(
          'Store order created successfully. Order ID: ${orderInitiation.order?.id}');
      logger.i('Payment URL: ${orderInitiation.authorizationUrl}');

      return orderInitiation;
    } on DioException catch (e) {
      logger.e(
          'DioException creating store order: ${e.response?.data ?? e.message}');
      throw Exception(
          'Network error creating order: ${e.response?.data?['message'] ?? e.message}');
    } catch (e, st) {
      logger.e('Error creating store order: $e\n$st');
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  /// Fetches all store tags from the API.
  Future<List<StoreTag>> getStoreTags() async {
    try {
      final responseData = await _networkClient.get(ApiRoute.storeTags);

      logger.i('Store tags API response: $responseData');

      final tagsResponse = StoreTagsResponse.fromJson(responseData);
      return tagsResponse.data;
    } on DioException catch (e) {
      logger.e('Failed to fetch store tags: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch store tags: $e');
      rethrow;
    }
  }
}

// Riverpod provider for StoreService
final storeServiceProvider = Provider((ref) => StoreService(
      NetworkClient(),
      const AppLogger(StoreService),
    ));
