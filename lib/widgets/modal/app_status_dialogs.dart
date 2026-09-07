import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// The app's dialogs, on the token system.
///
/// The static API is unchanged (decision D-03) — `dialog_service.dart`,
/// `copy_to_clipboard_util.dart` and several view models call these. What changed is what
/// they produce: token colours, `lg` radius, no hand-written shadow, tabular-free type from
/// the scale, and a `full`-radius pill for the primary action.
///
/// One dialog only ever asks one question. A dialog with two competing primary buttons is a
/// screen that has not been decided.
class AppStatusDialogs {
  static void showError(BuildContext context, String title, String message) {
    _show(
      context: context,
      title: title,
      message: message,
      icon: Icons.error_outline,
      tone: _Tone.danger,
    );
  }

  static void showSuccess(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onClosed,
  }) {
    _show(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
      tone: _Tone.success,
      onClosed: onClosed,
    );
  }

  static void showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',

    /// Whether confirming destroys something. A destructive confirm is the one place the
    /// danger fill is allowed on a button.
    bool destructive = true,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final v = context.vinkol;
        return _Shell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _Glyph(icon: Icons.help_outline, tone: _Tone.warning),
              const SizedBox(height: VinkolSpace.lg),
              _Title(title),
              const SizedBox(height: VinkolSpace.sm),
              _Message(message),
              const SizedBox(height: VinkolSpace.xxl),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _DialogButton(
                      label: cancelText,
                      onTap: () => Navigator.pop(context),
                      fill: Colors.transparent,
                      ink: v.textSecondary,
                      border: v.borderSubtle,
                    ),
                  ),
                  const SizedBox(width: VinkolSpace.md),
                  Expanded(
                    child: _DialogButton(
                      label: confirmText,
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      fill: destructive ? v.dangerFill : v.brand,
                      ink: VinkolPalette.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// A blocking spinner. Prefer a skeleton in the page wherever the layout is known — this
  /// is for an action whose result replaces the screen, not for loading a list.
  static void showLoading(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final v = context.vinkol;
        return Center(
          child: Container(
            padding: const EdgeInsets.all(VinkolSpace.xxl),
            decoration: BoxDecoration(
              color: v.surface,
              borderRadius: VinkolRadius.brLg,
              border: VinkolElevation.hairline(v),
              boxShadow: VinkolElevation.e2(v),
            ),
            child: Semantics(
              label: 'Working',
              liveRegion: true,
              child: SizedBox(
                width: 28,
                height: 28,
                child:
                    CircularProgressIndicator(color: v.brand, strokeWidth: 2.5),
              ),
            ),
          ),
        );
      },
    );
  }

  static void closeLoading(BuildContext context) => Navigator.pop(context);

  static void _show({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required _Tone tone,
    VoidCallback? onClosed,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => _Shell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Glyph(icon: icon, tone: tone),
            const SizedBox(height: VinkolSpace.lg),
            _Title(title),
            const SizedBox(height: VinkolSpace.sm),
            _Message(message),
            const SizedBox(height: VinkolSpace.xxl),
            _DialogButton(
              label: 'Close',
              onTap: () {
                Navigator.pop(context);
                onClosed?.call();
              },
              fill: context.vinkol.brand,
              ink: context.vinkol.onBrand,
            ),
          ],
        ),
      ),
    );
  }
}

enum _Tone { success, warning, danger }

/// The dialog surface: `lg` radius, a hairline, and the single lifted shadow — which is
/// nothing at all in dark mode, where depth is surface lightness.
class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

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
        child: child,
      ),
    );
  }
}

/// A 52pt well with a 24pt icon — the same treatment as the state screens, not a 64pt
/// tinted circle. The glyph labels the dialog; it does not decorate it.
class _Glyph extends StatelessWidget {
  const _Glyph({required this.icon, required this.tone});

  final IconData icon;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final (Color ink, Color well) = switch (tone) {
      _Tone.success => (v.success, v.successGround),
      _Tone.warning => (v.warning, v.warningGround),
      _Tone.danger => (v.danger, v.dangerGround),
    };
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: well,
        borderRadius: VinkolRadius.brSm,
        border: VinkolElevation.hairline(v),
      ),
      child: Icon(icon, size: 24, color: ink),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: VinkolType.h3.copyWith(color: context.vinkol.textPrimary),
        textAlign: TextAlign.center,
      );
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: VinkolType.body.copyWith(color: context.vinkol.textSecondary),
        textAlign: TextAlign.center,
      );
}

class _DialogButton extends StatefulWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    required this.fill,
    required this.ink,
    this.border,
  });

  final String label;
  final VoidCallback onTap;
  final Color fill;
  final Color ink;
  final Color? border;

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
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
            constraints: const BoxConstraints(minHeight: 48),
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
