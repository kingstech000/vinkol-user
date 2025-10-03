import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/utils/colors.dart'; // Assuming AppColors is defined here
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/provider/user_provider.dart'; // For verifyEmailProvider
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/app_textfield.dart'; // Assuming PinCodeField is from app_textfield.dart or similar
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/features/auth/view_model/verify_email_otp_view_model.dart'; // Import your ViewModel

class VerifyEmailOtpScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  const VerifyEmailOtpScreen({super.key});

  @override
  ConsumerState<VerifyEmailOtpScreen> createState() =>
      _VerifyEmailOtpScreenState(); // Changed to ConsumerState
}

class _VerifyEmailOtpScreenState extends ConsumerState<VerifyEmailOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added form key for validation

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to defer provider modifications until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the email from the provider and set it in the ViewModel
      final emailFromProvider = ref.read(verifyEmailProvider);
      ref.read(verifyEmailOtpViewModelProvider).setEmail(emailFromProvider);
      // Start cooldown if it was active previously (e.g. if the user navigated back)
      ref.read(verifyEmailOtpViewModelProvider).startResendCooldown();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel to react to state changes (busy, error, idle, and countdown)
    final verifyEmailOtpViewModel = ref.watch(verifyEmailOtpViewModelProvider);
    // Watch the email provider to display the email
    final email = ref.watch(verifyEmailProvider);

    // Determine if the resend button should be active
    final bool canResend = verifyEmailOtpViewModel.secondsRemaining == 0 &&
        verifyEmailOtpViewModel.state.maybeWhen(
          busy: () => false, // Also disable if the ViewModel is generally busy
          orElse: () => true,
        );

    return Scaffold(
      appBar: MiniAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              // Wrap with Form for validation
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h2('Enter OTP code'),
                  Gap.h8,
                  AppText.free('We have sent a code to $email'),
                  Gap.h32,
                  PinCodeField(
                    otpController: _otpController,
                    length: 4,
                    onCompleted: (v) {
                      // Optionally trigger verification on completion
                      if (_formKey.currentState?.validate() ?? false) {
                        verifyEmailOtpViewModel.verifyEmailOtp(
                          otp: _otpController.text,
                          context: context,
                        );
                      }
                    },
                    onSubmitted: (v) {
                      // Optionally trigger verification on submission
                      if (_formKey.currentState?.validate() ?? false) {
                        verifyEmailOtpViewModel.verifyEmailOtp(
                          otp: _otpController.text,
                          context: context,
                        );
                      }
                    },
                  ),
                  Gap.h16,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: canResend
                          ? () {
                              verifyEmailOtpViewModel.resendEmailOtp(
                                  context: context);
                            }
                          : null, // Disable onTap if not ready to resend
                      child: AppText.caption(
                        canResend
                            ? 'Resend code'
                            : 'Resend code in ${verifyEmailOtpViewModel.secondsRemaining}s', // Show countdown
                        color: canResend
                            ? AppColors.primary
                            : AppColors
                                .darkgrey, // Change color based on availability
                      ),
                    ),
                  ),
                  Gap.h32,
                  AppButton.primary(
                    title: 'Next',
                    loading: verifyEmailOtpViewModel.isBusy,
                    onTap: verifyEmailOtpViewModel.state.maybeWhen(
                      busy: () => null, // Disable button if busy
                      orElse: () => () {
                        // Validate form before calling verifyEmailOtp
                        if (_formKey.currentState?.validate() ?? false) {
                          verifyEmailOtpViewModel.verifyEmailOtp(
                            otp: _otpController.text,
                            context: context,
                          );
                        }
                      },
                    ),
                  ),
                  Gap.h32,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
