import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/profile/view/widget/settings_group.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

/// Everything that decides who can get into this account.
///
/// Today that is one credential and the address it is recovered through, so the
/// screen says both rather than showing a lone row under a large title. There
/// is no 2FA, no device list and no biometric lock in the backend, and none is
/// implied here.
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: MiniAppBar(title: 'Security'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsGroup(
              label: 'Sign in',
              footnote: 'Changing your password sends a code to your email '
                  'address to confirm it is you.',
              children: [
                if (user != null)
                  SettingsRow(
                    icon: PhosphorIconsRegular.envelopeSimple,
                    title: 'Email',
                    subtitle: user.email,
                    affordance: RowAffordance.none,
                  ),
                SettingsRow(
                  icon: PhosphorIconsRegular.lockKey,
                  title: 'Password',
                  value: '•' * 8,
                  onTap: () => NavigationService.instance
                      .navigateTo(NavigatorRoutes.resetPasswordScreen),
                ),
              ],
            ),
            Gap.h24,
          ],
        ),
      ),
    );
  }
}
