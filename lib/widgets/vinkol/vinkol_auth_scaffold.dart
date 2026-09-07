import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';

import 'vinkol_mark.dart';

/// **The auth archetype** — the one shape every screen in the auth flow takes.
///
/// It differs from [VinkolFormScaffold] on purpose, and only here:
///
/// - **The mark, not a title bar.** Sign-up and Login are the first screens a user ever
///   sees, and the thing that has to identify them is the brand, not the word "Login"
///   repeated above a heading that already says it.
/// - **The heading is centred.** Everywhere else in the app content is left-aligned against
///   the page margin, because rows of orders and money read down an edge. An auth screen has
///   no rows — it is one column of two fields — so it centres.
/// - **The action sits in the flow, not in a dock.** The dock exists to keep a submit button
///   reachable on a long form under a keyboard. These forms are two fields; docking the
///   button here would put a hairline and a surface change across a screen that has nothing
///   below it to separate.
/// - **The footer is pinned to the bottom edge.** The way out of Login is Sign up and vice
///   versa. It belongs at the bottom of the screen, not trailing the last field.
///
/// Everything below the mark scrolls, so a small phone at +200% text size still reaches the
/// button.
class VinkolAuthScaffold extends StatelessWidget {
  const VinkolAuthScaffold({
    super.key,
    required this.title,
    required this.fields,
    required this.primaryAction,
    this.body,
    this.aside,
    this.below,
    this.footer,
  });

  /// The screen's name — "Login", "Sign up", "Reset password". Centred, display weight.
  final String title;

  /// One line under the title saying what this screen wants. Optional, but a screen that
  /// asks for something should say why.
  final String? body;

  /// The form body. Named `fields` rather than `children` to keep [primaryAction] readable
  /// at the call site instead of being pushed to the end by the sort-children lint.
  final List<Widget> fields;

  /// The row between the last field and the action: the terms checkbox on Sign up, "Remember
  /// me" and "Forgot password?" on Login.
  final Widget? aside;

  /// The one thing this screen is for.
  final Widget primaryAction;

  /// Anything under the action — the resend countdown on the OTP screens.
  final Widget? below;

  /// "Have an account? Login". Pinned to the bottom edge.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    // The footer is a way out of this screen, not part of filling it in. Leaving it pinned
    // above a raised keyboard puts "Have an account? Login" under the thumb that is typing a
    // password, which is how people tap it by accident.
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: v.canvas,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  VinkolSpace.pageMargin,
                  VinkolSpace.xxl,
                  VinkolSpace.pageMargin,
                  VinkolSpace.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _MarkRow(),
                    const SizedBox(height: VinkolSpace.huge3),
                    Text(
                      title,
                      style: VinkolType.displayL
                          .copyWith(color: v.textPrimary, fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    if (body != null) ...<Widget>[
                      const SizedBox(height: VinkolSpace.md),
                      Text(
                        body!,
                        style: VinkolType.body.copyWith(color: v.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: VinkolSpace.xxxl),
                    ...fields,
                    if (aside != null) ...<Widget>[
                      const SizedBox(height: VinkolSpace.lg),
                      aside!,
                    ],
                    const SizedBox(height: VinkolSpace.xxxl),
                    primaryAction,
                    if (below != null) ...<Widget>[
                      const SizedBox(height: VinkolSpace.xxl),
                      below!,
                    ],
                  ],
                ),
              ),
            ),
            if (footer != null && !keyboardUp)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  VinkolSpace.pageMargin,
                  VinkolSpace.lg,
                  VinkolSpace.pageMargin,
                  VinkolSpace.bottomActionGap,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

/// The mark, optically centred, with a back control at the start when there is somewhere to
/// go back to.
///
/// The back control is not in the reference design, which shows the mark alone. It is here
/// because the reference shows Login and Sign up, which each have a way out through the
/// footer link, and the same layout also has to carry Enter code and Set new password, which
/// do not. A user three screens into a password reset with no back control is stuck, and
/// system back does not exist on iOS. A trailing spacer of the same width keeps the mark on
/// the true centre either way.
class _MarkRow extends StatelessWidget {
  const _MarkRow();

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop();

    return Row(
      children: <Widget>[
        if (canGoBack)
          VinkolIconButton(
            icon: Icons.arrow_back,
            semanticLabel: 'Back',
            onTap: NavigationService.instance.goBack,
          )
        else
          const SizedBox(width: VinkolIconButton.size),
        const Expanded(
          child: Center(child: VinkolMark(height: 30)),
        ),
        const SizedBox(width: VinkolIconButton.size),
      ],
    );
  }
}

/// "Forgot password?" — the quiet text link that sits at the end of Login's aside row.
///
/// A [VinkolPrimaryButton] with `tone: plain` would work, but it carries a 54pt minimum
/// height that throws the row's alignment off against a 44pt checkbox target.
class VinkolTextLink extends StatelessWidget {
  const VinkolTextLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          // Pads the 20pt line out to a 44pt-high target without moving the text.
          padding: const EdgeInsets.symmetric(vertical: VinkolSpace.md),
          child: Text(
            label,
            style: VinkolType.bodyS.copyWith(color: v.textBrand),
          ),
        ),
      ),
    );
  }
}
