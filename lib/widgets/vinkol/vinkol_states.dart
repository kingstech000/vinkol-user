import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// What a state screen offers the user to do about it.
class VinkolStateAction {
  const VinkolStateAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// The base for every "there is nothing here" screen: empty, error and offline.
///
/// Two rules shape it, both from the banned-aesthetics list:
///
/// 1. **No generic empty states.** [title], [message] and [action] are all required. A screen
///    that cannot say what is missing and what to do about it has not been designed, and the
///    old `EmptyContent` — one 120pt tinted circle and a line of grey text, no action —
///    is exactly what that looks like.
/// 2. **No decorative illustration.** The icon is 24pt in a hairline well, the same treatment
///    every other surface in Midnight gets. It labels the state; it does not perform it.
class VinkolStateView extends StatelessWidget {
  const VinkolStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    this.secondaryAction,
    this.tone = VinkolStateTone.neutral,
  });

  /// An empty state — nothing has gone wrong, there is just nothing yet.
  const VinkolStateView.empty({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    this.secondaryAction,
  }) : tone = VinkolStateTone.neutral;

  /// A failure, with the cause stated. Pass the real reason as [message] — "Something went
  /// wrong" tells a user nothing they did not already know.
  const VinkolStateView.error({
    super.key,
    required this.title,
    required this.message,
    required this.action,
    this.secondaryAction,
    this.icon = Icons.error_outline,
  }) : tone = VinkolStateTone.danger;

  /// No connection. Distinct from [VinkolStateView.error] because the cause is known, the
  /// fix is the user's, and retrying is worth offering rather than explaining.
  VinkolStateView.offline({
    super.key,
    required VoidCallback onRetry,
    String? title,
    String? message,
  })  : icon = Icons.wifi_off_outlined,
        title = title ?? 'No connection',
        message = message ??
            'Vinkol needs a connection to load this. Check your network and try again.',
        action = VinkolStateAction(label: 'Try again', onPressed: onRetry),
        secondaryAction = null,
        tone = VinkolStateTone.warning;

  final IconData icon;

  /// What the state is, in three or four words.
  final String title;

  /// Why, and what happens next. One or two sentences.
  final String message;

  /// The way out. Required — an empty state with no action is a dead end.
  final VinkolStateAction action;

  /// An optional lesser path: "Go back", "Contact support".
  final VinkolStateAction? secondaryAction;

  final VinkolStateTone tone;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    final Color accent;
    final Color well;
    switch (tone) {
      case VinkolStateTone.neutral:
        accent = v.textSecondary;
        well = v.surfaceAlt;
      case VinkolStateTone.success:
        accent = v.success;
        well = v.successGround;
      case VinkolStateTone.danger:
        accent = v.danger;
        well = v.dangerGround;
      case VinkolStateTone.warning:
        accent = v.warning;
        well = v.warningGround;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: VinkolSpace.xl,
          vertical: VinkolSpace.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: well,
                borderRadius: VinkolRadius.brSm,
                border: VinkolElevation.hairline(v),
              ),
              child: Icon(icon, size: 24, color: accent),
            ),
            const SizedBox(height: VinkolSpace.xl),
            Text(
              title,
              style: VinkolType.h2.copyWith(color: v.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: VinkolSpace.sm),
            // Capped near 64 characters: past that, centred body copy stops being readable.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                message,
                style: VinkolType.body.copyWith(color: v.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: VinkolSpace.xxl),
            _StateButton(action: action, primary: true),
            if (secondaryAction != null) ...<Widget>[
              const SizedBox(height: VinkolSpace.md),
              _StateButton(action: secondaryAction!, primary: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// How a state screen is toned. `success` is here because a confirmation — a saved
/// password, a placed order — has the same shape as an empty state: one message and one way
/// onward.
enum VinkolStateTone { neutral, success, warning, danger }

/// A pill button, sized to its label rather than the screen — a full-width button in the
/// middle of an empty screen reads as the page's primary action, which this is not.
class _StateButton extends StatefulWidget {
  const _StateButton({required this.action, required this.primary});

  final VinkolStateAction action;
  final bool primary;

  @override
  State<_StateButton> createState() => _StateButtonState();
}

class _StateButtonState extends State<_StateButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final fill = widget.primary
        ? (_pressed ? v.brandDeep : v.brand)
        : (_pressed ? v.surfaceAlt : Colors.transparent);
    final ink = widget.primary ? v.onBrand : v.textSecondary;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.action.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: VinkolSpace.xxl,
            vertical: VinkolSpace.md,
          ),
          decoration: BoxDecoration(
            color: fill,
            // Primary buttons are `full`, not `sm` — the pill is part of the Midnight look.
            borderRadius: VinkolRadius.brFull,
            border: widget.primary
                ? null
                : Border.fromBorderSide(BorderSide(color: v.borderSubtle)),
          ),
          child: Center(
            child: Text(
              widget.action.label,
              style: VinkolType.button.copyWith(color: ink),
              textAlign: TextAlign.center,
              // Two lines, so a longer translation wraps rather than clipping.
              maxLines: 2,
            ),
          ),
        ),
      ),
    );
  }
}
