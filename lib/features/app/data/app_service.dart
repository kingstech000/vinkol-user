import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/features/app/model/app_details_model.dart';

class AppService {
  final NetworkClient _networkClient;
  final AppLogger logger;

  AppService(this._networkClient, this.logger);

  Future<AppDetailsResponse> getAppDetails() async {
    try {
      final responseData = await _networkClient.get(ApiRoute.appDetails);
      logger.i('App details API response: $responseData');

      if (responseData is Map) {
        return AppDetailsResponse.fromJson(
          responseData as Map<String, dynamic>,
        );
      } else {
        throw Exception('Invalid response format for getAppDetails');
      }
    } on DioException catch (e) {
      logger.e('Error fetching app details: ${e.message}');
      throw Exception(
          'Failed to fetch app details: ${e.response?.data['message'] ?? e.message}');
    } catch (e, _) {
      logger.e('An unexpected error occurred while fetching app details: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

final appServiceProvider = Provider((ref) => AppService(
      NetworkClient(),
      const AppLogger(AppService),
    ));

