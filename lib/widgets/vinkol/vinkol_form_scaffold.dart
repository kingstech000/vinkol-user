import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

import 'vinkol_form_field.dart';

/// **The form archetype** — one solution for every form in the app.
///
/// Three rules, and they are the reason this is a widget rather than a pattern people
/// remember:
///
/// 1. **The label sits above the field**, never floating inside it (see [VinkolFormField]).
/// 2. **The error is stated in words and tied to its field** — never a red border alone.
/// 3. **One bottom-anchored primary action**, in a dock that is always visible and never
///    scrolls away. A form whose submit button is somewhere down the page makes the user
///    hunt for it, and on a long form under a soft keyboard they may never find it.
///
/// The dock lifts with the keyboard, so the action stays reachable while typing.
class VinkolFormScaffold extends StatelessWidget {
  const VinkolFormScaffold({
    super.key,
    this.appBar,
    required this.fields,
    required this.primaryAction,
    this.secondaryAction,
    this.footer,
    this.dockCaption,
    this.scrollPadding = const EdgeInsets.symmetric(
      horizontal: VinkolSpace.pageMargin,
    ),
  });

  final PreferredSizeWidget? appBar;

  /// The form body, laid out in a column with the page margin applied.
  ///
  /// Named `fields` rather than `children` on purpose: it keeps `primaryAction` readable at
  /// the call site instead of being pushed to the end by the sort-children lint.
  final List<Widget> fields;

  /// The one thing this screen is for.
  final Widget primaryAction;

  /// A quieter second path in the dock, under the primary.
  final Widget? secondaryAction;

  /// A line of text under the actions — "New here? Create an account".
  final Widget? footer;

  /// Retained for callers that want a caption above the dock's actions, such as an order
  /// total beside a Pay button.
  final Widget? dockCaption;

  final EdgeInsetsGeometry scrollPadding;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: appBar,
      // The dock handles the keyboard inset itself, so the body must not also shrink.
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: scrollPadding,
              // Room to scroll the last field clear of the dock.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ...fields,
                  const SizedBox(height: VinkolSpace.xxl),
                ],
              ),
            ),
          ),
          _Dock(
            caption: dockCaption,
            primary: primaryAction,
            secondary: secondaryAction,
            footer: footer,
          ),
        ],
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  const _Dock(
      {this.caption, required this.primary, this.secondary, this.footer});

  final Widget? caption;
  final Widget primary;
  final Widget? secondary;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: VinkolMotion.respecting(context, VinkolMotion.base),
      curve: VinkolMotion.emphasized,
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(
          VinkolSpace.pageMargin,
          14,
          VinkolSpace.pageMargin,
          VinkolSpace.bottomActionGap,
        ),
        decoration: BoxDecoration(
          color: v.surface,
          // A hairline, not a shadow. The dock is a surface change, not a lifted object.
          border: BorderDirectional(top: BorderSide(color: v.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (caption != null) ...<Widget>[
                caption!,
                const SizedBox(height: VinkolSpace.md),
              ],
              primary,
              if (secondary != null) ...<Widget>[
                const SizedBox(height: 10),
                secondary!,
              ],
              if (footer != null) ...<Widget>[
                const SizedBox(height: VinkolSpace.lg),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// How much a [VinkolPrimaryButton] shouts.
enum VinkolButtonTone {
  /// The saturated pill. One per screen.
  primary,

  /// A surface pill with a hairline — the second choice on the same screen.
  quiet,

  /// A borderless text button, for the third path.
  plain,

  /// The prototype's `.btn--bad`: a hairline pill whose *label* is the danger colour, never a
  /// filled red slab. Logging out and deleting an account are deliberate, not urgent, and a
  /// saturated red button competes with the one saturated object a Midnight screen is allowed.
  danger,
}

/// The pill button the docks use. `full` radius, 54pt tall, one label that wraps rather than
/// clipping.
///
/// This is a new widget rather than a change to [AppButton], whose public API 40-odd files
/// depend on and which decision D-03 keeps stable.
class VinkolPrimaryButton extends StatefulWidget {
  const VinkolPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.tone = VinkolButtonTone.primary,
    this.loading = false,
    this.dense = false,
    this.icon,
  });

  final String label;

  /// Null disables the button. A disabled primary action must still be visible — hiding it
  /// leaves the user with no idea what the screen is for.
  final VoidCallback? onPressed;

  final VinkolButtonTone tone;

  /// Replaces the label with a spinner and blocks the tap.
  final bool loading;

  /// The compact pill — a chrome-level action such as Skip, sized to its label rather than
  /// to the bottom of the screen. Still 44pt tall, so the tap target survives.
  final bool dense;

  final IconData? icon;

  @override
  State<VinkolPrimaryButton> createState() => _VinkolPrimaryButtonState();
}

class _VinkolPrimaryButtonState extends State<VinkolPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = widget.onPressed == null || widget.loading;

    late final Color fill;
    late final Color ink;
    Color? edge;
    switch (widget.tone) {
      case VinkolButtonTone.primary:
        fill = disabled ? v.surfaceAlt : (_pressed ? v.brandDeep : v.brand);
        ink = disabled ? v.textTertiary : v.onBrand;
      case VinkolButtonTone.quiet:
        fill = _pressed ? v.surfaceAlt : v.surface;
        ink = disabled ? v.textTertiary : v.textPrimary;
        edge = v.borderSubtle;
      case VinkolButtonTone.plain:
        fill = _pressed ? v.surfaceAlt : Colors.transparent;
        ink = disabled ? v.textTertiary : v.textSecondary;
      case VinkolButtonTone.danger:
        fill = _pressed ? v.surfaceAlt : Colors.transparent;
        ink = disabled ? v.textTertiary : v.danger;
        edge = v.borderSubtle;
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: disabled ? null : widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          constraints: BoxConstraints(minHeight: widget.dense ? 44 : 54),
          // The full-width pill centres its label inside tight constraints; the dense one
          // must shrink-wrap instead, and a container with an alignment always fills the
          // space it is offered.
          alignment: widget.dense ? null : Alignment.center,
          padding: widget.dense
              ? const EdgeInsetsDirectional.symmetric(
                  horizontal: VinkolSpace.lg,
                  vertical: VinkolSpace.sm,
                )
              : const EdgeInsetsDirectional.symmetric(
                  horizontal: VinkolSpace.xl,
                  vertical: VinkolSpace.md,
                ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: VinkolRadius.brFull,
            border: edge != null
                ? Border.fromBorderSide(BorderSide(color: edge))
                : null,
          ),
          child: widget.loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(color: ink, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (widget.icon != null) ...<Widget>[
                      Icon(widget.icon, size: 19, color: ink),
                      const SizedBox(width: VinkolSpace.sm),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        style: (widget.dense
                                ? VinkolType.label
                                : VinkolType.button)
                            .copyWith(color: ink),
                        textAlign: TextAlign.center,
                        // Two lines: French runs ~40% longer and a button must wrap, not clip.
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// The lead-in at the top of an auth screen: a display title and one line of copy.
class VinkolFormIntro extends StatelessWidget {
  const VinkolFormIntro({super.key, required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 6),
        Text(title, style: VinkolType.displayS.copyWith(color: v.textPrimary)),
        if (body != null) ...<Widget>[
          const SizedBox(height: VinkolSpace.sm),
          Text(body!, style: VinkolType.body.copyWith(color: v.textSecondary)),
        ],
        const SizedBox(height: VinkolSpace.xl),
      ],
    );
  }
}

/// A password field with a visibility toggle. The toggle is a labelled icon button, not a
/// bare glyph — an icon-only control needs an accessible name.
class VinkolPasswordField extends StatefulWidget {
  const VinkolPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.error,
    this.hint,
    this.helper,
    this.autofillHint,
    this.onChanged,
    this.textInputAction = TextInputAction.done,
    this.pill = false,
  });

  final String label;
  final TextEditingController controller;
  final String? error;
  final String? hint;
  final String? helper;
  final String? autofillHint;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  /// The auth shape — see [VinkolFormField.pill].
  final bool pill;

  @override
  State<VinkolPasswordField> createState() => _VinkolPasswordFieldState();
}

class _VinkolPasswordFieldState extends State<VinkolPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return VinkolFormField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      helper: widget.helper,
      error: widget.error,
      pill: widget.pill,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      autofillHints:
          widget.autofillHint == null ? null : <String>[widget.autofillHint!],
      onChanged: widget.onChanged,
      leading: Icon(Icons.lock_outline, size: 18, color: v.textTertiary),
      trailing: Semantics(
        button: true,
        label: _hidden ? 'Show password' : 'Hide password',
        child: GestureDetector(
          onTap: () => setState(() => _hidden = !_hidden),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(VinkolSpace.xs),
            child: Icon(
              _hidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 19,
              color: v.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// "New here? Create an account" — a sentence with one tappable half.
class VinkolFooterLink extends StatelessWidget {
  const VinkolFooterLink({
    super.key,
    required this.lead,
    required this.action,
    required this.onTap,
  });

  final String lead;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return Semantics(
      button: true,
      label: '$lead$action',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: lead,
                style: VinkolType.bodyS.copyWith(color: v.textSecondary),
              ),
              TextSpan(
                text: action,
                style: VinkolType.bodyS.copyWith(
                  color: v.textBrand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
