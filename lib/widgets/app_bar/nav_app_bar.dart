import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';

/// The home identity header — the prototype's `top` with an avatar, an eyebrow and a name.
///
/// The hierarchy is inverted from the old version on purpose. The greeting is the bold line
/// and the prompt is the eyebrow above it, because the name is the thing a user recognises
/// and the prompt is context. That is what the prototype does, and it also keeps the header
/// two lines tall instead of growing when the prompt is translated.
///
/// Public API unchanged (D-03).
class NavAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const NavAppBar({
    super.key,
    this.userRole = 'Where would you like to deliver to?',
    this.showNotificationBadge = true,
    this.onNotificationTap,
  });

  /// The eyebrow above the greeting.
  final String userRole;

  /// Retained for source compatibility. There is no notifications inbox — `NotificationService`
  /// is FCM push only, with no stored list — so nothing is drawn for it (D-10).
  final bool showNotificationBadge;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final user = ref.watch(userProvider);
    final isGuest = GuestModeUtils.isGuestMode();
    final name = isGuest ? 'Guest' : (user?.firstname ?? 'there');

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
            _Avatar(name: name, isGuest: isGuest),
            const SizedBox(width: VinkolSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    userRole,
                    style: VinkolType.caption.copyWith(color: v.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Hello, $name',
                    style: VinkolType.h3.copyWith(color: v.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

/// The `.av` control: initials on a surface disc with a hairline. No photo — `Avatar` exists
/// on the user model but a missing image must not collapse the header.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.isGuest});

  final String name;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return Semantics(
      label: isGuest ? 'Guest' : name,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: v.surfaceAlt,
          shape: BoxShape.circle,
          border: Border.fromBorderSide(BorderSide(color: v.borderSubtle)),
        ),
        child: Text(
          initial,
          style: VinkolType.h4.copyWith(color: v.textSecondary),
        ),
      ),
    );
  }
}
