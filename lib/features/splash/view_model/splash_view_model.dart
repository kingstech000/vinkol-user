import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import the jwt_decoder package
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

      bool isOnBoarded = await localCache.isOnBoarded();

      _logger.i('isOnboarded:$isOnBoarded');

      if (isOnBoarded) {
        // Check if user is in guest mode
        bool isGuestMode = localCache.isGuestMode();

        if (isGuestMode) {
          _logger.i('User is in guest mode. Proceeding to dashboard.');
          _navigationService
              .navigateToReplaceAll(NavigatorRoutes.dashboardScreen);
          changeState(const ViewModelState.idle());
          return;
        }

        final token = localCache.getToken(); // Retrieve the token

        if (token != null && token.isNotEmpty) {
          try {
            // Check if the token is expired
            bool hasExpired = JwtDecoder.isExpired(token);

            if (hasExpired) {
              _logger.i('JWT token expired. Redirecting to auth choice.');
              // Clear expired token
              await localCache.saveToken('');
              _navigationService
                  .navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
            } else {
              _logger.i('JWT token is valid. Proceeding to dashboard.');
              // Token is valid, send FCM token and redirect to dashboard
              await _ref
                  .read(authServiceProvider)
                  .sendFcmTokenToBackend(); // Use .read for one-time operations
              _navigationService.navigateToReplaceAll(NavigatorRoutes
                  .dashboardScreen); // Redirect to your main dashboard
            }
          } catch (e) {
            // Handle cases where the token is malformed or invalid
            _logger
                .e('Error decoding JWT token: $e. Redirecting to auth choice.');
            _navigationService
                .navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
          }
        } else {
          _logger.i('No token found. Redirecting to auth choice.');
          _navigationService
              .navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
        }
      } else {
        _logger.i('Not onboarded. Redirecting to onboarding screen.');
        _navigationService
            .navigateToReplaceAll(NavigatorRoutes.onboardingScreen);
      }
      changeState(const ViewModelState.idle());
    } on Failure catch (e) {
      _logger.e('Initialization failed: ${e.message}');
      changeState(ViewModelState.error(e));
      // Optionally navigate to an error screen or auth choice
      _navigationService.navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
    }
  }
}

final splashViewModelProvider = Provider<SplashViewModel>((ref) {
  return SplashViewModel(ref);
});
