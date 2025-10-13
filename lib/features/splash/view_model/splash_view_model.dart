import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/app_logger.dart';
import 'package:starter_codes/core/utils/base_view_model.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/features/auth/data/auth_service.dart';
import 'package:starter_codes/models/app_state/view_model_state.dart';
import 'package:starter_codes/models/failure.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';

class SplashViewModel extends BaseViewModel {
  final NavigationService _navigationService = NavigationService.instance;
  final localCache = locator<LocalCache>();
  final AppLogger _logger = const AppLogger(SplashViewModel);
  final Ref _ref;

  SplashViewModel(this._ref);

  Future<void> initializeApp() async {
    try {
      changeState(const ViewModelState.busy());

      // Get onboarding status
      bool isOnBoarded = await localCache.isOnBoarded();
      _logger.i('=== SPLASH SCREEN DEBUG ===');
      _logger.i('isOnBoarded: $isOnBoarded');

      // If not onboarded, go to onboarding
      if (!isOnBoarded) {
        _logger.i('User not onboarded. Redirecting to onboarding screen.');
        changeState(const ViewModelState.idle());
        _navigationService
            .navigateToReplaceAll(NavigatorRoutes.onboardingScreen);
        return;
      }

      // User is onboarded - check authentication status
      _logger.i('User is onboarded. Checking authentication...');

      // Check if user is in guest mode
      bool isGuestMode = localCache.isGuestMode();
      _logger.i('isGuestMode: $isGuestMode');

      if (isGuestMode) {
        _logger.i('User is in guest mode. Proceeding to dashboard.');
        changeState(const ViewModelState.idle());
        _navigationService
            .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
        return;
      }

      // Not guest mode - check for valid token
      final token = localCache.getToken();
      _logger.i('Token exists: ${token != null && token.isNotEmpty}');

      if (token == null || token.isEmpty) {
        _logger.i('No token found. Redirecting to auth choice.');
        changeState(const ViewModelState.idle());
        _navigationService
            .navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
        return;
      }

      // Token exists - validate it
      try {
        bool hasExpired = JwtDecoder.isExpired(token);
        _logger.i('Token expired: $hasExpired');

        if (hasExpired) {
          _logger
              .i('JWT token expired. Clearing token and redirecting to auth.');
          await localCache.saveToken('');
          changeState(const ViewModelState.idle());
          _navigationService
              .navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
          return;
        }

        // Token is valid - send FCM token and go to dashboard
        _logger.i(
            'JWT token is valid. Sending FCM token and proceeding to dashboard.');

        try {
          await _ref.read(authServiceProvider).sendFcmTokenToBackend();
        } catch (e) {
          // Log FCM error but don't block navigation
          _logger.w('Failed to send FCM token: $e (proceeding anyway)');
        }

        changeState(const ViewModelState.idle());
        _navigationService
            .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
      } catch (e) {
        _logger.e('Error decoding JWT token: $e. Redirecting to auth choice.');
        await localCache.saveToken(''); // Clear invalid token
        changeState(const ViewModelState.idle());
        _navigationService
            .navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
      }
    } on Failure catch (e) {
      _logger.e('Initialization failed: ${e.message}');
      changeState(ViewModelState.error(e));
      _navigationService.navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
    } catch (e) {
      _logger.e('Unexpected error during initialization: $e');
      changeState(const ViewModelState.idle());
      _navigationService.navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
    }
  }
}

final splashViewModelProvider = Provider<SplashViewModel>((ref) {
  return SplashViewModel(ref);
});
