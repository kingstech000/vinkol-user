// lib/screens/payment_success_screen.dart
import 'package:flutter/material.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart'; // Assuming AppColors is defined
import 'package:starter_codes/widgets/app_button.dart'; // Your custom button
import 'package:starter_codes/widgets/gap.dart'; // Your custom gap widget

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              Gap.h32, // Your custom gap
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              Gap.h16, // Your custom gap
              const Text(
                'Your payment has been processed successfully. Your order is now confirmed.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Gap.h36, // Your custom gap
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  title: 'Back to Home',
                  onTap: () {
                    // Navigate to home and remove all previous routes
                    NavigationService.instance.navigateToReplaceAll(
                      NavigatorRoutes.dashboardScreen,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}