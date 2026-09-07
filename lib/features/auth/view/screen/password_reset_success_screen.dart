import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// The end of the reset flow.
///
/// On the auth archetype like every other screen in the flow, so the mark, the centred
/// heading and the one saturated action stay in the same places they have been for the last
/// four screens. What stands in for the fields is a single tick — the only screen in auth
/// with nothing to fill in.
class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;

    return VinkolAuthScaffold(
      title: l10n.authPasswordSavedTitle,
      body: l10n.authPasswordSavedBody,
      fields: <Widget>[
        Center(
          child: Semantics(
            excludeSemantics: true,
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: v.successGround,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(BorderSide(color: v.success)),
              ),
              child: Icon(Icons.check, size: 34, color: v.success),
            ),
          ),
        ),
      ],
      primaryAction: VinkolPrimaryButton(
        label: l10n.authBackToLogin,
        onPressed: () => NavigationService.instance
            .navigateToReplaceAll(NavigatorRoutes.loginScreen),
      ),
    );
  }
}
