import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';

/// Back plus centred title plus one text action on the end axis — the prototype's `bar()`
/// with its optional `right` slot filled.
///
/// The action is a text pill in the brand ink rather than a grey chip: it is a real action,
/// and the old treatment (grey `Colors.grey.shade300` ground, brand text) read as disabled.
///
/// Public API unchanged (D-03).
class MiniActionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MiniActionAppBar({
    super.key,
    this.icon = Icons.arrow_back,
    this.title,
    required this.action,
    this.actionOnTap,
  });

  final IconData? icon;
  final String action;
  final String? title;
  final VoidCallback? actionOnTap;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;

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
            if (icon != null)
              VinkolIconButton(
                icon: icon!,
                semanticLabel: 'Back',
                onTap: NavigationService.instance.goBack,
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
            _ActionPill(label: action, onTap: actionOnTap),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);
}

class _ActionPill extends StatefulWidget {
  const _ActionPill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final disabled = widget.onTap == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: VinkolMotion.respecting(context, VinkolMotion.instant),
          curve: VinkolMotion.standard,
          constraints: const BoxConstraints(minHeight: VinkolIconButton.size),
          alignment: Alignment.center,
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: VinkolSpace.lg),
          decoration: BoxDecoration(
            color: _pressed ? v.brandSubtle : Colors.transparent,
            borderRadius: VinkolRadius.brFull,
          ),
          child: Text(
            widget.label,
            style: VinkolType.button.copyWith(
              color: disabled ? v.textTertiary : v.textBrand,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
