// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/services/notification_service.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/network_client.dart';
import 'package:starter_codes/core/constants/api_routes.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/features/auth/model/user_model.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/provider/user_provider.dart';

class AuthService {
  final NetworkClient _networkClient;
  final LocalCache _localCache;
  final AppLogger logger;
  final Ref _ref;

  AuthService(this._networkClient, this._localCache, this.logger, this._ref);

  Future<void> login({required String email, required String password}) async {
    try {
      final responseData = await _networkClient.post(
        ApiRoute.login,
        body: {
          "email": email,
          "password": password,
        },
      );
      logger.i(responseData);
      if (responseData.containsKey('token')) {
        await _localCache.saveToken(responseData['token'] as String);
      }
    } catch (e) {
      logger.e('Login failed: $e');
      rethrow;
    }
  }

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    try {
      final responseData = await _networkClient.post(
        ApiRoute.signUp,
        body: SignupRequest(
          email: email,
          password: password,
        ).toJson(),
      );
      logger.i('Signup API response: $responseData');
      if (responseData.containsKey('token')) {
        await _localCache.saveToken(responseData['token'] as String);
      }
    } catch (e) {
      logger.e('Signup failed: $e');
      rethrow;
    }
  }



   Future<void> forgotPassword({required String email}) async {
    try {
      await _networkClient.post(
        ApiRoute.forgotPassword,
        queryParameters: {
          'app':true
        },
        body: {
          "email": email, // Assuming resend OTP also takes email in the body
        },
      );
      logger.i('Reset Password request successful for: $email');
    } catch (e) {
      logger.e('Failed to send reset password: $e');
      rethrow;
    }
  }

    Future<void> setPassword({required String otp,required String password}) async {
    try {
      await _networkClient.patch(
        ApiRoute.resetPassword,
        queryParameters: {
          'app':true
        },
        body: {
          "otp":otp,
          "password":password // Assuming resend OTP also takes email in the body
        },
      );
      logger.i('Reset Password request successful for: $otp');
    } catch (e) {
      logger.e('Failed to send reset password: $e');
      rethrow;
    }
  }

  Future<void> verifyEmail({required String email, required String otp}) async {
    try {
      final responseData = await _networkClient.patch(
        ApiRoute.verifyEmail,
        body: {
          "email": email,
          "otp": otp,
        },
      );

      if (responseData.containsKey('token')) {
        await _localCache.saveToken(responseData['token'] as String);
      }
      logger.i('Email verified successfully for: $email');
    } catch (e) {
      logger.e('Email verification failed: $e');
      rethrow;
    }
  }

  Future<void> resendOtp({required String email}) async {
    try {
      await _networkClient.patch(
        ApiRoute.resendOtp,
        body: {
          "email": email, // Assuming resend OTP also takes email in the body
        },
      );
      logger.i('OTP resend request successful for: $email');
    } catch (e) {
      logger.e('Failed to resend OTP: $e');
      rethrow;
    }
  }

  Future<void> resetPasswordWithToken({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _networkClient.patch(
        '${ApiRoute.resetPassword}/$resetToken',
        body: {
          "password": newPassword,
        },
      );
      logger.i('Password reset successfully with token: $resetToken');
    } catch (e) {
      logger.e('Failed to reset password with token: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? firstname,
    String? state,
    String? lastName,
    String? phoneNumber,
    MultipartFile? avatar,
  }) async {
    try {
      // final token = _localCache.getToken() as String;

      final Map<String, dynamic> data = {};
      if (firstname != null) {
        data['firstname'] = firstname;
      }
       if (lastName != null) {
        data['lastname'] = lastName;
      }
      if (state != null) {
        data['state'] = state;
      }
      if (avatar != null) {
        data['avatar'] = avatar; // Add MultipartFile directly to map
      }
            if (phoneNumber != null) {
        data['phone'] = phoneNumber; // Add MultipartFile directly to map
      }

      final FormData formData = FormData.fromMap(data);

      await _networkClient.put(
        ApiRoute.updateProfile,
        body: formData,
      );
      logger.i('Profile updated successfully!');
      await getUserProfile();
    } catch (e) {
      logger.e('Failed to update profile: $e');
      rethrow;
    }
  }

  Future<User> getUserProfile() async {
    try {
      final responseData = await _networkClient.get(
        ApiRoute.userProfile,
      );
      logger.d(responseData['data']);
      final user = User.fromJson(responseData['data'] as Map<String, dynamic>);
      logger.i('User profile fetched successfully: ${user.email}');
      _ref.read(userProvider.notifier).setUser(user); // Update local user state
      return user;
    } catch (e) {
      logger.e('Failed to fetch user profile: $e');
      rethrow;
    }
  }
  Future<void> sendFcmTokenToBackend() async {
    try {
      String? fcmToken = await NotificationService.instance.getToken();
     
      if ( fcmToken.isNotEmpty ) {
        logger.i('Sending FCM token for user : $fcmToken');
        // Use your NetworkClient to send the FCM token
        final response = await _networkClient.patch(
          ApiRoute.updateToken, // Use your actual API route for updating FCM token
          body: {
            'token': fcmToken,
          },
        );
        final responseData=response  as Map<String, dynamic>;
        logger.i('FCM token update response: $response');
      _localCache.saveToken(responseData['token']);
      await getUserProfile();
      } else {
        logger.w('Cannot send FCM token: FCM token or User ID is missing. FCM: $fcmToken, User ID: ');
      }
    } on Failure catch (e) {
      logger.e('Failed to send FCM token to backend: ${e.message}');
      // Do not rethrow here, as FCM token update failure shouldn't block app initialization
    } 
  }
}

// Riverpod provider for AuthService
final authServiceProvider = Provider((ref) => AuthService(
      NetworkClient(),
      locator<LocalCache>(),
      const AppLogger(AuthService),
      ref,
    ));
