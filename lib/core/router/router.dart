import 'package:flutter/material.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/features/auth/view/screen/enter_otp_screen.dart';
import 'package:starter_codes/features/auth/view/screen/login_screen.dart';
import 'package:starter_codes/features/auth/view/screen/password_reset_success_screen.dart';
import 'package:starter_codes/features/auth/view/screen/profile_setting_screen.dart';
import 'package:starter_codes/features/auth/view/screen/reset_password_screen.dart';
import 'package:starter_codes/features/auth/view/screen/set_new_password_screen.dart';
import 'package:starter_codes/features/auth/view/screen/signup_screen.dart';
import 'package:starter_codes/features/auth/view/screen/verify_email_otp_screen.dart';
import 'package:starter_codes/features/delivery/view/screen/booking_order_screen.dart';
import 'package:starter_codes/features/booking/view/screen/map_with_quote_screen.dart';
import 'package:starter_codes/features/booking/view/screen/package_info_screen.dart';
import 'package:starter_codes/features/dashboard/view/screen/dashboard_screen.dart';
import 'package:starter_codes/features/onboarding/view/screen/onboarding_screen.dart';
import 'package:starter_codes/features/payment/view/payment_screen.dart';
import 'package:starter_codes/features/profile/view/screen/SupportAndHelpScreen.dart';
import 'package:starter_codes/features/profile/view/screen/delete_account_screen.dart';
import 'package:starter_codes/features/profile/view/screen/notification_settings_screen.dart';
import 'package:starter_codes/features/profile/view/screen/personal_info_screen.dart';
import 'package:starter_codes/features/profile/view/screen/security_screen.dart';
import 'package:starter_codes/features/profile/view/screen/settings_screen.dart';
import 'package:starter_codes/features/splash/view/screen/splash_screen.dart';
import 'package:starter_codes/features/store/view/screen/cart_screen.dart';
import 'package:starter_codes/features/store/view/screen/product_list_screen.dart';
import 'package:starter_codes/features/delivery/view/screen/store_order_screen.dart';

enum TransitionType { SlideUp, Side, Breeze }

class AppRouter {
  static PageRoute _getPageRoute({
    required RouteSettings settings,
    required Widget viewToShow,
    TransitionType transition = TransitionType.Side, // default to Side
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => viewToShow,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transition) {
          case TransitionType.SlideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // Start from the bottom
                end: Offset.zero, // Slide to the center
              ).animate(animation),
              child: child,
            );

          case TransitionType.Side:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0), // Start from the right
                end: Offset.zero, // Slide to the center
              ).animate(animation),
              child: child,
            );

          case TransitionType.Breeze:
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.9, // Slight zoom-in effect
                  end: 1.0,
                ).animate(animation),
                child: child,
              ),
            );

        
        }
      },
    );
  }

  static Route<dynamic> generateRoute(
    RouteSettings settings, {
    TransitionType transition = TransitionType.Side,
  }) {
    // Map<String, dynamic> routeArgs = settings.arguments != null
    //     ? settings.arguments as Map<String, dynamic>
    //     : {};

    switch (settings.name) {
      case NavigatorRoutes.splashScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const SplashScreen(),
            transition: transition);
      case NavigatorRoutes.onboardingScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const OnboardingScreen(),
            transition: transition);
      case NavigatorRoutes.loginScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const LoginScreen(),
            transition: transition);
      case NavigatorRoutes.signupScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const SignUpScreen(),
            transition: transition);
      case NavigatorRoutes.resetPasswordScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const ResetPasswordScreen(),
            transition: transition);
      case NavigatorRoutes.enterOtpCodeScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const EnterOTPCodeScreen(),
            transition: transition);
      case NavigatorRoutes.passwordResetSuccessScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const PasswordResetSuccessScreen(),
            transition: TransitionType.SlideUp);
      case NavigatorRoutes.setNewPasswordScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const SetNewPasswordScreen(),
            transition: transition);
      case NavigatorRoutes.profileSettingScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const ProfileSettingScreen(),
            transition: transition);

      case NavigatorRoutes.verifyEmailOtpScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const VerifyEmailOtpScreen(),
            transition: transition);

      // DASHBOARD
      case NavigatorRoutes.dashboardScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const DashboardScreen(),
            transition: transition);
      // PROFILE
      case NavigatorRoutes.securityScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const SecurityScreen(),
            transition: transition);
      case NavigatorRoutes.personalInfoScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const PersonalInfoScreen(),
            transition: transition);
      case NavigatorRoutes.notificationSettingsScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const NotificationSettingScreen(),
            transition: transition);
      case NavigatorRoutes.settingsScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const SettingsScreen(),
            transition: transition);
      case NavigatorRoutes.supportAndHelpScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const SupportHelpScreen(),
            transition: transition);
      case NavigatorRoutes.deleteAccountScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const DeleteAccountScreen(),
            transition: transition);

      //BOOKING
      case NavigatorRoutes.packageInfoScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const PackageInfoScreen(),
            transition: transition);
      case NavigatorRoutes.mapWithQuoteScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const MapWithQuotesScreen(),
            transition: transition);
      case NavigatorRoutes.bookingOrderScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const BookingOrderScreen(),
            transition: transition);

          //PAYMENT SCREEN
                case NavigatorRoutes.deliveryPaymentScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const PaymentScreen(),
            transition: transition); 
      // STORE
      case NavigatorRoutes.productListScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const ProductListScreen(),
            transition: transition);
      case NavigatorRoutes.cartScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const CartScreen(),
            transition: transition);
      case NavigatorRoutes.storeOrderScreen:
        return _getPageRoute(
            settings: settings,
            viewToShow: const StoreOrderScreen(),
            transition: transition);

      default:
        return _getPageRoute(settings: settings, viewToShow: const Scaffold());
    }
  }
}
