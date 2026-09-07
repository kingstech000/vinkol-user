import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/features/profile/view_model/notification_preference.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// **Notifications** — one switch, and a sentence explaining why there is only one.
///
/// The screen used to offer three: general, email and "sound & vibrate". None was wired to
/// anything — no endpoint stores a notification preference, the app sends no email itself,
/// and sound is an OS setting. Three switches that do nothing is worse than one that does
/// something.
///
/// The one that remains unregisters this device from FCM rather than hiding a list, because
/// there is no list: Vinkol pushes on a status change and stores nothing
/// (`.claude/design/08-backend-gaps.md`). The note says exactly that, so nobody goes looking
/// for a notification history that was never built.
class NotificationSettingScreen extends ConsumerWidget {
  const NotificationSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final bool enabled = ref.watch(notificationPreferenceProvider);

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: MiniAppBar(title: l10n.profileNotifications),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          VinkolSpace.pageMargin,
          VinkolSpace.lg,
          VinkolSpace.pageMargin,
          VinkolSpace.xxl,
        ),
        children: <Widget>[
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.notifications_active_outlined,
                accentIcon: enabled,
                title: l10n.profilePush,
                meta: l10n.profilePushMeta,
                metaMaxLines: 2,
                trailing: VinkolSwitch(
                  value: enabled,
                  label: l10n.profilePush,
                  onChanged: (bool next) => ref
                      .read(notificationPreferenceProvider.notifier)
                      .setEnabled(next),
                ),
              ),
            ],
          ),
          const SizedBox(height: VinkolSpace.lg),
          Text(
            l10n.profileNotificationsNote,
            style: VinkolType.bodyS.copyWith(color: v.textTertiary),
          ),
        ],
      ),
    );
  }
}
