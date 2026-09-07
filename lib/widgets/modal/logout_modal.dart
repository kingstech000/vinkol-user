// lib/widgets/modal/logout_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/data/local/local_cache.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/locator.dart';
import 'package:starter_codes/provider/dashboard_navigator_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';

/// The log-out confirmation, as a bottom sheet.
///
/// Reworked to the token system. Two behavioural fixes came with it:
///
/// - It no longer watched `userProvider` for a value it never used, which made the sheet
///   rebuild on every user change.
/// - Logging out used `ref.watch` inside a callback to reset the tab index. `watch` outside
///   `build` is a Riverpod misuse; it is `read` now.
class LogoutModal extends ConsumerWidget {
  const LogoutModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final localCache = locator<LocalCache>();

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        VinkolSpace.xl,
        VinkolSpace.md,
        VinkolSpace.xl,
        VinkolSpace.xxl,
      ),
      decoration: BoxDecoration(
        color: v.surface,
        // Sheets are `lg`, top corners only — square where they meet the screen edge.
        borderRadius: VinkolRadius.brSheet,
        border: BorderDirectional(top: BorderSide(color: v.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // The grip: what tells a user this sheet can be dragged away.
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: v.borderStrong,
                  borderRadius: VinkolRadius.brFull,
                ),
              ),
            ),
            const SizedBox(height: VinkolSpace.xl),
            Text(
              'Log out',
              style: VinkolType.h2.copyWith(color: v.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: VinkolSpace.sm),
            Text(
              'You will need to sign in again to book a delivery or use your wallet. '
              'If something is wrong, support can help instead.',
              style: VinkolType.body.copyWith(color: v.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: VinkolSpace.xxl),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SheetButton(
                    label: 'Contact us',
                    fill: Colors.transparent,
                    ink: v.textSecondary,
                    border: v.borderSubtle,
                    onTap: () {
                      NavigationService.instance.goBack();
                      NavigationService.instance
                          .navigateTo(NavigatorRoutes.supportAndHelpScreen);
                    },
                  ),
                ),
                const SizedBox(width: VinkolSpace.md),
                Expanded(
                  child: _SheetButton(
                    label: 'Log out',
                    fill: v.dangerFill,
                    ink: VinkolPalette.white,
                    onTap: () async {
                      await GuestModeUtils.clearGuestMode();
                      await localCache.saveToken('');
                      ref.read(navigationIndexProvider.notifier).state = 0;
                      NavigationService.instance.navigateToReplaceAll(
                          NavigatorRoutes.authChoiceScreen);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatefulWidget {
  const _SheetButton({
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
  State<_SheetButton> createState() => _SheetButtonState();
}

class _SheetButtonState extends State<_SheetButton> {
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
              horizontal: VinkolSpace.md,
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

/// Shows [LogoutModal] as a bottom sheet.
void showLogoutModal(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: const LogoutModal(),
    ),
  );
}
