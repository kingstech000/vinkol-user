import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starter_codes/core/constants/assets.dart';
import 'package:starter_codes/core/constants/link_routes.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/launch_link.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/core/utils/textstyles.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';

/// The first fork in the app: make an account, sign back in, or look around.
///
/// The three routes are deliberately not equal. An account is what the product
/// actually needs — a guest cannot book, buy or hold a wallet — so it leads,
/// signing in sits beside it as the returning-customer path, and the guest
/// route is offered plainly underneath with the catch stated rather than
/// discovered later at the point of booking.
class AuthChoiceScreen extends ConsumerStatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  ConsumerState<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends ConsumerState<AuthChoiceScreen> {
  final localCache = locator<LocalCache>();

  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  bool _startingAsGuest = false;

  @override
  void initState() {
    super.initState();
    // Built once and disposed: a recognizer made inside build() outlives every
    // rebuild that replaces it.
    _termsTap = TapGestureRecognizer()
      ..onTap = () => _openLink(LinkRoutes.termsAndCondition);
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => _openLink(LinkRoutes.privacyPolicy);
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _continueAsGuest() async {
    setState(() => _startingAsGuest = true);
    await localCache.setGuestMode(true);
    if (!mounted) return;
    NavigationService.instance.navigateToReplaceAll(
      NavigatorRoutes.dashboardScreen,
    );
  }

  Future<void> _openLink(String url) async {
    try {
      await LaunchLink.launchURL(url);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.black,
          content: AppText.body(
            'Could not open that link.',
            color: AppColors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Scrolls only when it has to — a short viewport or a large text
            // scale. With room to spare the artwork absorbs the slack and the
            // buttons stay where the thumb expects them.
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Gap.h16,
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                              vertical: 16,
                            ),
                            child: SvgPicture.asset(
                              SvgAsset.onboardingIcon,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        AppText.h1('Welcome to Vinkol', centered: true),
                        Gap.h8,
                        AppText.body(
                          'Choose how you would like to get started',
                          centered: true,
                          color: AppColors.darkgrey,
                        ),
                        Gap.h32,
                        AppButton.primary(
                          title: 'Create an account',
                          onTap: () => NavigationService.instance.navigateTo(
                            NavigatorRoutes.signupScreen,
                          ),
                        ),
                        Gap.h12,
                        AppButton.outline(
                          title: 'Log in',
                          onTap: () => NavigationService.instance.navigateTo(
                            NavigatorRoutes.loginScreen,
                          ),
                        ),
                        Gap.h20,
                        _guestAction(),
                        Gap.h24,
                        _legalFooter(),
                        Gap.h16,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// The third route, stated with its limit attached. A guest reaches the
  /// dashboard but is stopped at booking, buying and the wallet, so saying so
  /// here is cheaper than an auth sheet three screens in.
  Widget _guestAction() {
    return InkWell(
      onTap: _startingAsGuest ? null : _continueAsGuest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_startingAsGuest) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  Gap.w8,
                ],
                AppText.body(
                  'Continue as a guest',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legalFooter() {
    final base = captionStyle.copyWith(color: AppColors.darkgrey);
    final link = base.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'By continuing you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: link,
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: link,
            recognizer: _privacyTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
