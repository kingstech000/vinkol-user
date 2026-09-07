import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/services/navigation_service.dart';

/// **Back plus centred title** — the prototype's `bar()` form, and the app bar for every
/// pushed screen.
///
/// The back control is a 42pt circular `ico` button: a hairline-bordered surface disc, not a
/// bare chevron. That gives it a real 44pt touch target and makes it the same object as the
/// map controls and the header actions, which is what stops the chrome looking assembled from
/// different kits.
///
/// A trailing spacer of the same width balances the row so the title is optically centred
/// rather than centred-with-a-lean.
///
/// Public API unchanged (decision D-03): 13 files construct this. Only what it produces has
/// changed.
class MiniAppBar extends StatelessWidget implements PreferredSizeWidget {
  MiniAppBar({
    super.key,
    this.color = Colors.transparent,
    this.icon = Icons.arrow_back,
    this.actions,
    this.title = '',
    this.leading = true,
  });

  /// Retained for source compatibility. The bar takes its ink from the theme now — a caller
  /// passing a colour here was working around the absence of a theme layer.
  final Color color;

  final IconData icon;
  final String? title;
  final bool leading;
  final List<Widget>? actions;

  final NavigationService _navigationService = NavigationService.instance;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final hasActions = actions != null && actions!.isNotEmpty;

    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: v.canvas,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: preferredSize.height,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.xl),
        child: Row(
          children: <Widget>[
            if (leading)
              VinkolIconButton(
                icon: icon,
                semanticLabel: 'Back',
                onTap: _navigationService.goBack,
              )
            else
              const SizedBox(width: VinkolIconButton.size),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: VinkolSpace.md),
                child: Text(
                  title ?? '',
                  style: VinkolType.h3.copyWith(color: v.textPrimary),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Balances the back button so the title sits on the true centre. Without it a
            // longer title drifts toward the end edge.
            if (hasActions)
              Row(mainAxisSize: MainAxisSize.min, children: actions!)
            else
              const SizedBox(width: VinkolIconButton.size),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);
}

/// The `.ico` control: a 42pt disc with a hairline border, used for back, map controls and
/// header actions alike.
class VinkolIconButton extends StatefulWidget {
  const VinkolIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.selected = false,
  });

  static const double size = 42;

  final IconData icon;

  /// An icon-only control needs a name. Required, not optional.
  final String semanticLabel;

  final VoidCallback? onTap;

  /// Fills with the brand. At most one control on screen should be selected.
  final bool selected;

  @override
  State<VinkolIconButton> createState() => _VinkolIconButtonState();
}

class _VinkolIconButtonState extends State<VinkolIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = widget.onTap == null;

    final Color fill;
    final Color ink;
    if (widget.selected) {
      fill = v.brand;
      ink = v.onBrand;
    } else {
      fill = _pressed ? v.surfaceAlt : v.surface;
      ink = disabled ? v.textTertiary : v.textSecondary;
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          width: VinkolIconButton.size,
          height: VinkolIconButton.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: widget.selected ? v.brand : v.borderSubtle),
            ),
          ),
          child: Icon(widget.icon, size: 19, color: ink),
        ),
      ),
    );
  }
}
