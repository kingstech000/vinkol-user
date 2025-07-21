import 'package:flutter/material.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              Gap.h32,
              AppText.h3('Password Reset Successfully'),
              Gap.h32,
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  title: 'Back to Login',
                  onTap: () {
                    // TODO: Implement navigation to login screen
                    NavigationService.instance
                        .navigateTo(NavigatorRoutes.loginScreen);
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
