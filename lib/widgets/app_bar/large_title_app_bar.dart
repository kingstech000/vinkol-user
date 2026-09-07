import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// **Large title** — the prototype's `title()` form, for a screen a user arrives at rather
/// than pushes onto: a tab root, a section landing.
///
/// No back control, because there is nowhere to go back to. The title is `h1`,
/// start-aligned, with an optional trailing control on the end axis.
class VinkolLargeTitleBar extends StatelessWidget
    implements PreferredSizeWidget {
  const VinkolLargeTitleBar({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;

  /// One supporting line under the title, in the tertiary ink.
  final String? subtitle;

  /// Usually a [VinkolIconButton].
  final Widget? trailing;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: VinkolType.h1.copyWith(color: v.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: VinkolSpace.xs),
                    Text(
                      subtitle!,
                      style: VinkolType.bodyS.copyWith(color: v.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: VinkolSpace.md),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 62 : 76);
}
