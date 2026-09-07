import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// **Security** — two rows, because two is what exists.
///
/// There is no two-factor sign-in, no biometric unlock, no device list and no session
/// management: none has an endpoint (D-10), and a settings screen that offers a switch the
/// server has never heard of is worse than one that offers nothing.
///
/// Changing a password goes through the same reset-by-email flow the login screen uses —
/// there is no separate change-password endpoint, and the row says so rather than implying
/// an in-place form.
///
/// **Transaction PIN is present but not actionable.** `transaction_pin_modal.dart` exists and
/// collects the four digits a recipient reads out to confirm a delivery, but `ApiRoute` has
/// no PIN endpoint at all — nothing sets one, changes one or verifies one, and the modal has
/// no call site in the app today. The row is here because a user who has heard of the PIN
/// will look for it; it states what the PIN actually is instead of opening a form that
/// cannot save.
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: MiniAppBar(title: l10n.profileSecurity),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          VinkolSpace.pageMargin,
          VinkolSpace.xs,
          VinkolSpace.pageMargin,
          VinkolSpace.xxl,
        ),
        children: <Widget>[
          VinkolSectionHeader(label: l10n.profileSignInGroup),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.lock_reset_outlined,
                title: l10n.profileChangePassword,
                meta: l10n.profileChangePasswordMeta,
                metaMaxLines: 2,
                onTap: () => NavigationService.instance
                    .navigateTo(NavigatorRoutes.resetPasswordScreen),
              ),
            ],
          ),
          VinkolSectionHeader(label: l10n.profileTransactionsGroup),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.pin_outlined,
                title: l10n.profileTransactionPin,
                meta: l10n.profileTransactionPinMeta,
                metaMaxLines: 3,
                enabled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
