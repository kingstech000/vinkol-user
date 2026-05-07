import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/features/delivery/model/delivery_model.dart'; // Import the new delivery model
import 'package:starter_codes/features/delivery/model/rider_rating_model.dart';

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
      final DeliveriesResponse deliveriesResponse =
          DeliveriesResponse.fromJson(responseData);
      return deliveriesResponse.data;
    } on DioException catch (e) {
      logger.e(
          'Failed to fetch $orderType orders: ${e.response?.data ?? e.message}');
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
      throw Exception(
          'Failed to fetch order details: ${e.response?.data['message'] ?? e.message}');
    } catch (e, _) {
      logger.e(
          'An unexpected error occurred while fetching single delivery order: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<RiderRatingModel> getRiderAverageRating(String riderId) async {
    try {
      final String endpoint = '${ApiRoute.riderAverageRating}/$riderId';
      logger.d('Fetching rider average rating: $endpoint');

      final responseData = await _networkClient.get(endpoint);

      logger.i('Rider rating API response for ID $riderId: $responseData');

      if (responseData is Map) {
        final ratingResponse = RiderRatingResponse.fromJson(
          responseData as Map<String, dynamic>,
        );
        return ratingResponse.data;
      } else {
        throw Exception('Invalid response format for getRiderAverageRating');
      }
    } on DioException catch (e) {
      logger.e('Error fetching rider rating: ${e.message}');
      throw Exception(
          'Failed to fetch rider rating: ${e.response?.data['message'] ?? e.message}');
    } catch (e, _) {
      logger.e('An unexpected error occurred while fetching rider rating: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> submitRiderRating(RiderRatingRequest ratingRequest) async {
    try {
      logger.d('Submitting rider rating: ${ratingRequest.toJson()}');

      final responseData = await _networkClient.post(
        ApiRoute.submitRiderRating,
        body: ratingRequest.toJson(),
      );

      logger.i('Rider rating submitted successfully: $responseData');
    } on DioException catch (e) {
      logger.e('Error submitting rider rating: ${e.message}');
      throw Exception(
          'Failed to submit rating: ${e.response?.data['message'] ?? e.message}');
    } catch (e, _) {
      logger
          .e('An unexpected error occurred while submitting rider rating: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> downloadReport(String startDate, String endDate) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'startDate': startDate,
        'endDate': endDate,
      };

      logger.d(
          'Downloading report: ${ApiRoute.downloadReport} with $queryParameters');

      final List<int> pdfBytes = await _networkClient.downloadFile(
        ApiRoute.downloadReport,
        queryParameters: queryParameters,
      );

      // Save the PDF bytes to a file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/vinkol_report_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      logger.i('Report downloaded and saved to: $filePath');

      // Open the file
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Could not open the report: ${result.message}');
      }
    } on DioException catch (e) {
      logger.e('Error downloading report: ${e.message}');
      final errorMessage = (e.response?.data is Map)
          ? (e.response?.data['message'] ?? e.message)
          : (e.response?.data?.toString() ?? e.message);
      throw Exception(errorMessage);
    } catch (e, _) {
      logger.e('An unexpected error occurred while downloading report: $e');
      throw Exception(e.toString());
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final String endpoint = '${ApiRoute.singleDelivery}/$orderId/cancel';
      logger.d('Cancelling order: $endpoint');

      final responseData = await _networkClient.patch(endpoint);

      logger.i('Order cancelled successfully: $responseData');
    } on DioException catch (e) {
      logger.e('Error cancelling order: ${e.message}');
      throw Exception(
          'Failed to cancel order: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      logger.e('An unexpected error occurred while cancelling order: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

final deliveryServiceProvider = Provider((ref) => DeliveryService(
      NetworkClient(),
      const AppLogger(DeliveryService),
    ));
