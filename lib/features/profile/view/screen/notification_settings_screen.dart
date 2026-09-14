import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/features/profile/view/widget/settings_group.dart';
import 'package:starter_codes/provider/notification_preferences_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';

/// Notification preferences, limited to what the client can actually honour.
///
/// The backend has no notification-preferences endpoint, so there is no
/// "email notifications" switch here: one would change nothing and the customer
/// would go on receiving the mail. What is offered instead is the one thing the
/// app really decides — whether an alert it draws itself makes a noise — and a
/// straight reading of the permission the operating system holds.
class NotificationSettingScreen extends ConsumerWidget {
  const NotificationSettingScreen({super.key});

  /// Plain words for the permission, never the enum name.
  static String _describe(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized => 'Allowed',
      AuthorizationStatus.provisional => 'Quiet delivery',
      AuthorizationStatus.denied => 'Blocked',
      AuthorizationStatus.notDetermined => 'Not set',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final push = ref.watch(pushAuthorizationProvider);

    return Scaffold(
      appBar: MiniAppBar(title: 'Notifications'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsGroup(
              label: 'In Vinkol',
              footnote: 'Turning sound off does not hide anything — alerts '
                  'still arrive and still show, they just stay quiet.',
              children: [
                SettingsToggle(
                  icon: PhosphorIconsRegular.speakerHigh,
                  title: 'Sound and vibration',
                  subtitle: 'For alerts that arrive while Vinkol is open.',
                  value: prefs.soundAndVibration,
                  onChanged: (value) => ref
                      .read(notificationPreferencesProvider.notifier)
                      .setSoundAndVibration(value),
                ),
              ],
            ),
            Gap.h28,
            SettingsGroup(
              label: 'On this device',
              footnote: 'Your phone owns this one. Change it in Settings, '
                  'under Vinkol. Delivery updates are also sent by email to '
                  'the address on your account.',
              children: [
                SettingsRow(
                  icon: PhosphorIconsRegular.bell,
                  title: 'Push notifications',
                  // Never an empty string: a value row with nothing in it
                  // reads as a title someone forgot to finish.
                  value: push.when(
                    data: _describe,
                    loading: () => 'Checking…',
                    error: (_, __) => 'Unavailable',
                  ),
                  affordance: RowAffordance.none,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
