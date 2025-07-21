import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart'; // Import the new delivery model

class DeliveryService {
  final NetworkClient _networkClient;
  final AppLogger logger;

  DeliveryService(this._networkClient, this.logger);

  
  Future<List<DeliveryModel>> getOrders({
    required String orderType,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
        'orderType': orderType,
      };

      final responseData = await _networkClient.get(
        ApiRoute.delivery,
        queryParameters: queryParameters,
      );

      logger.i('Orders API response for $orderType: $responseData');

      // Parse the full response into DeliveriesResponse and return the list of data
      final DeliveriesResponse deliveriesResponse = DeliveriesResponse.fromJson(responseData);
      return deliveriesResponse.data;
    } on DioException catch (e) {
      logger.e('Failed to fetch $orderType orders: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      logger.e('Failed to fetch $orderType orders: $e');
      rethrow;
    }
  }
  Future<DeliveryModel> getDeliveryOrderById(String orderId) async {
    try {
      final String endpoint = '${ApiRoute.singleDelivery}/$orderId';
      logger.d('Fetching delivery order by ID: $endpoint');

      final responseData = await _networkClient.get(endpoint);

      logger.i('Single Order API response for ID $orderId: $responseData');

      // Assuming the API returns the single DeliveryModel directly or under a 'data' key.
      // Adjust this parsing logic based on your actual API response structure.
      if (responseData is Map) {
        if (responseData.containsKey('data')) {
          return DeliveryModel.fromJson(responseData['data']);
        } else {
          return DeliveryModel.fromJson(responseData as Map<String, dynamic>);
        }
      } else {
        throw Exception('Invalid response format for getDeliveryOrderById');
      }
    } on DioException catch (e) {
      logger.e('Error fetching single delivery order: ${e.message}');
      throw Exception('Failed to fetch order details: ${e.response?.data['message'] ?? e.message}');
    } catch (e, _) {
      logger.e('An unexpected error occurred while fetching single delivery order: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

final deliveryServiceProvider = Provider((ref) => DeliveryService(
      NetworkClient(),
      const AppLogger(DeliveryService),
    ));