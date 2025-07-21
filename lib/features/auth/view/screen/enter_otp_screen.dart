// lib/features/auth/screens/enter_otp_code_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/auth/view_model/enter_otp_view_model.dart';
import 'package:starter_codes/provider/user_provider.dart'; // Assuming this provides User?
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart'; // Ensure PinCodeField is defined or imported from here
import 'package:starter_codes/widgets/gap.dart';

class EnterOTPCodeScreen extends ConsumerStatefulWidget {
  const EnterOTPCodeScreen({super.key});

  @override
  ConsumerState<EnterOTPCodeScreen> createState() => _EnterOTPCodeScreenState();
}

class _EnterOTPCodeScreenState extends ConsumerState<EnterOTPCodeScreen> {
  final TextEditingController _otpController = TextEditingController();

  int _resendCountdown = 30;
  bool _canResend = false;
  // Make _displayedEmail nullable initially or ensure it has a fallback
  late String _displayedEmail;

  @override
  void initState() {
    super.initState();
    final email = ref.read(resetEmailProvider);
    _displayedEmail = email ;

    // Read the ViewModel to call methods that don't trigger a rebuild of the widget itself
    final otpViewModel = ref.read(otpViewModelProvider);
    otpViewModel.setEmail(_displayedEmail);

    _startResendTimer();
  }

  // Timer logic for resend button countdown
  void _startResendTimer() {
    _resendCountdown = 30;
    _canResend = false;
    // Use a Timer instead of Future.delayed for better control over cancellation
    // However, since it's a simple countdown, Future.delayed is acceptable if managed correctly.
    // For simplicity, sticking to Future.delayed as in original, but added mounted check.
    _tickTimer(); // Start ticking immediately
    setState(() {}); // Rebuild to show initial countdown
  }

  void _tickTimer() {
    if (_resendCountdown > 0) {
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            // Double-check mounted after delay
            setState(() {
              _resendCountdown--;
            });
            _tickTimer(); // Call itself to continue the countdown
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel to rebuild when its state changes (e.g., isBusy updates)
    final otpViewModel = ref.watch(otpViewModelProvider);
    final bool isBusy =
        otpViewModel.isBusy; // Access the isBusy state from the ViewModel

    return Scaffold(
      appBar: MiniAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h2('Enter OTP code'),
            Gap.h8,
            AppText.free('We have sent a code to $_displayedEmail'),
            Gap.h32,
            // PinCodeField is assumed to be a custom widget that takes an otpController
            // and has onCompleted/onSubmitted callbacks.
            PinCodeField(
              otpController: _otpController,
              length: 4,
              onCompleted: (v) {
                // Trigger verification automatically when OTP is completed
                if (!isBusy) {
                  // Prevent multiple calls if already busy
                  otpViewModel.verifyOtp(otp: v, context: context);
                }
              },
              onSubmitted: (v) {
                // Optional: You can also use onSubmitted, ensure it's not redundant
                // with onCompleted if both trigger verification.
                if (!isBusy) {
                  otpViewModel.verifyOtp(otp: v, context: context);
                }
              },
            ),
            Gap.h16,
            Align(
              alignment: Alignment.centerLeft,
              child: _canResend
                  ? GestureDetector(
                      onTap:
                          isBusy // Disable resend button if ViewModel is busy
                              ? null
                              : () {
                                  otpViewModel.resendOtp(context: context);
                                  _startResendTimer(); // Restart timer after resend
                                },
                      child: AppText.caption(
                        'Resend Code',
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : AppText.caption('Resend code in ${_resendCountdown}s'),
            ),
            Gap.h32,
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                title: 'Next',
                loading: isBusy,
                onTap: isBusy // Disable "Next" button if ViewModel is busy
                    ? null
                    : () {
                        otpViewModel.verifyOtp(
                          otp: _otpController.text,
                          context: context,
                        );
                      },
              ),
            ),
            Gap.h32,
          ],
        ),
      ),
    );
  }
}
