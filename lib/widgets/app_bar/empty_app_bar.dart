import 'package:flutter/material.dart';
import 'package:starter_codes/core/design/design.dart';

/// A bar that draws nothing but the status-bar inset, for screens whose own content starts
/// at the top — a full-bleed map, a splash.
///
/// It still exists rather than being omitted so those screens do not have to reason about
/// safe-area insets themselves.
class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmptyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: context.vinkol.canvas,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(30);
}
