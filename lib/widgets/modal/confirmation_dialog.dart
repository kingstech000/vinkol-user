import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';

/// Asked when the payment webview closes and the app does not know whether payment
/// completed.
///
/// Reworked to the token system. Two things changed beyond the styling:
///
/// - **The primary action is the one that helps.** Verifying was previously an
///   `OutlinedButton` filled with the brand and cancelling was an `ElevatedButton` outlined
///   in red — two buttons both claiming primacy, in opposite widget types. Verify is the
///   primary pill now; cancelling is the quiet path.
/// - **The caveat is a warning banner, not orange body text.** The note that an already-paid
///   order still processes is the most important sentence in the dialog, and it was the
///   faintest thing on it.
class PaymentConfirmationDialog extends StatelessWidget {
  const PaymentConfirmationDialog({super.key, required this.isStoreOrder});

  final bool isStoreOrder;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(VinkolSpace.xl),
      child: Container(
        padding: const EdgeInsets.all(VinkolSpace.xl),
        decoration: BoxDecoration(
          color: v.surface,
          borderRadius: VinkolRadius.brLg,
          border: VinkolElevation.hairline(v),
          boxShadow: VinkolElevation.e2(v),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Semantics(
                button: true,
                label: 'Close',
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(VinkolSpace.xs),
                    child: Icon(Icons.close, size: 20, color: v.textTertiary),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v.warningGround,
                  borderRadius: VinkolRadius.brSm,
                  border: VinkolElevation.hairline(v),
                ),
                child:
                    Icon(Icons.payments_outlined, size: 24, color: v.warning),
              ),
            ),
            const SizedBox(height: VinkolSpace.lg),
            Text(
              'Payment in progress',
              style: VinkolType.h3.copyWith(color: v.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: VinkolSpace.sm),
            Text(
              'Have you completed your payment? If you have, verify to see your order. '
              'If not, you can cancel and try again later.',
              style: VinkolType.body.copyWith(color: v.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: VinkolSpace.xl),
            _PillButton(
              label: 'Verify payment status',
              fill: v.brand,
              ink: v.onBrand,
              onTap: () => Navigator.of(context).pop('verify'),
            ),
            const SizedBox(height: VinkolSpace.md),
            _PillButton(
              label: 'Cancel payment',
              fill: Colors.transparent,
              ink: v.danger,
              border: v.borderSubtle,
              onTap: () {
                Navigator.pop(context);
                if (isStoreOrder) {
                  NavigationService.instance.navigateToReplace(
                    NavigatorRoutes.cartScreen,
                    argument: <String, dynamic>{'isFromWebviewClosing': true},
                  );
                  log('Routing back to Cart Screen');
                } else {
                  NavigationService.instance.navigateToReplace(
                    NavigatorRoutes.mapWithQuoteScreen,
                  );
                  log('Routing back to Map With Quote Screen');
                }
              },
            ),
            const SizedBox(height: VinkolSpace.lg),
            // The caveat that matters most, given the weight it deserves.
            Container(
              padding: const EdgeInsets.all(VinkolSpace.md),
              decoration: BoxDecoration(
                color: v.warningGround,
                borderRadius: VinkolRadius.brSm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.info_outline, size: 16, color: v.warning),
                  const SizedBox(width: VinkolSpace.sm),
                  Expanded(
                    child: Text(
                      'If you have already paid, the order is processed even if you cancel '
                      'verification. Check Records later.',
                      style: VinkolType.bodyS.copyWith(color: v.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatefulWidget {
  const _PillButton({
    required this.label,
    required this.fill,
    required this.ink,
    required this.onTap,
    this.border,
  });

  final String label;
  final Color fill;
  final Color ink;
  final Color? border;
  final VoidCallback onTap;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          opacity: _pressed ? 0.78 : 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            alignment: Alignment.center,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: VinkolSpace.lg,
              vertical: VinkolSpace.md,
            ),
            decoration: BoxDecoration(
              color: widget.fill,
              borderRadius: VinkolRadius.brFull,
              border: widget.border != null
                  ? Border.fromBorderSide(BorderSide(color: widget.border!))
                  : null,
            ),
            child: Text(
              widget.label,
              style: VinkolType.button.copyWith(color: widget.ink),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ),
      ),
    );
  }
}
