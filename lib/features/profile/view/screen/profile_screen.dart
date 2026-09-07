import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/auth/model/user_model.dart';
import 'package:starter_codes/features/profile/view/widget/profile_widgets.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/widgets/app_bar/large_title_app_bar.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/modal/logout_modal.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// **Profile** — the fifth pod destination, and the app's own menu.
///
/// The structure is the one the app already had: identity, then Account, then App, then the
/// way out. What changed is what is on it. The gradient hero with a 100pt bordered avatar and
/// a `state | role` pill is gone: role is an internal field a customer has no use for, and a
/// screen that opens with a coloured slab spends the one saturated object Midnight allows
/// (D-07) on a decoration rather than on something live. Profile has nothing live, so it has
/// no saturated object at all.
///
/// Every row here goes somewhere that exists. Nothing promises saved addresses, payment
/// methods, a notifications inbox, profile stats or a rating — none has an endpoint (D-10).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final User? user = ref.watch(userProvider);
    final bool isGuest = user == null || GuestModeUtils.isGuestMode();

    void go(String route) => NavigationService.instance.navigateTo(route);

    /// Rows that need an account. A guest sees them — hiding them would leave the screen
    /// looking broken rather than locked — and tapping one explains why it is unavailable.
    void goAuthed(String route) {
      final allowed = !isGuest ||
          GuestModeUtils.requireAuthForAction(
            context,
            title: l10n.profileSignInRequired,
            message: l10n.profileSignInRequiredBody,
          );
      if (allowed) go(route);
    }

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: VinkolLargeTitleBar(
        title: l10n.profileTitle,
        trailing: VinkolIconButton(
          icon: Icons.tune,
          semanticLabel: l10n.profileSettings,
          onTap: () => go(NavigatorRoutes.settingsScreen),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          VinkolSpace.pageMargin,
          VinkolSpace.xs,
          VinkolSpace.pageMargin,
          VinkolPod.bodyInsetOf(context),
        ),
        children: <Widget>[
          _IdentityCard(user: user, isGuest: isGuest),
          VinkolSectionHeader(label: l10n.profileAccountSection),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.person_outline,
                title: l10n.profilePersonalInfo,
                meta: l10n.profilePersonalInfoMeta,
                onTap: () => goAuthed(NavigatorRoutes.personalInfoScreen),
              ),
              VinkolRow(
                icon: Icons.lock_outline,
                title: l10n.profileSecurity,
                meta: l10n.profileSecurityMeta,
                onTap: () => goAuthed(NavigatorRoutes.securityScreen),
              ),
              VinkolRow(
                icon: Icons.account_balance_outlined,
                title: l10n.profileBankAccount,
                meta: l10n.profileBankAccountMeta,
                onTap: () => goAuthed(NavigatorRoutes.bankAccountScreen),
              ),
            ],
          ),
          VinkolSectionHeader(label: l10n.profileAppSection),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.tune,
                title: l10n.profileSettings,
                meta: l10n.profileSettingsMeta,
                onTap: () => go(NavigatorRoutes.settingsScreen),
              ),
              VinkolRow(
                icon: Icons.receipt_long_outlined,
                title: l10n.profileDownloadReport,
                meta: l10n.profileDownloadReportMeta,
                onTap: () => goAuthed(NavigatorRoutes.downloadReportScreen),
              ),
              VinkolRow(
                icon: Icons.support_agent_outlined,
                title: l10n.profileSupport,
                meta: l10n.profileSupportMeta,
                onTap: () => go(NavigatorRoutes.supportAndHelpScreen),
              ),
            ],
          ),
          const SizedBox(height: VinkolSpace.xxl),
          if (isGuest)
            VinkolPrimaryButton(
              label: l10n.profileSignIn,
              onPressed: () async {
                await GuestModeUtils.clearGuestMode();
                NavigationService.instance
                    .navigateToReplaceAll(NavigatorRoutes.authChoiceScreen);
              },
            )
          else
            VinkolPrimaryButton(
              label: l10n.profileLogOut,
              tone: VinkolButtonTone.danger,
              onPressed: () => showLogoutModal(context),
            ),
          const SizedBox(height: VinkolSpace.lg),
          const Center(child: _VersionLine()),
        ],
      ),
    );
  }
}

/// Who is signed in. A guest gets the same block with the reason they are seeing less.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user, required this.isGuest});

  final User? user;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    final l10n = context.l10n;

    // A profile with no name yet falls back to the email rather than to "Guest User" — the
    // account is real, it is just incomplete, and calling it a guest is wrong.
    final String fullName = <String?>[user?.firstname, user?.lastname]
        .whereType<String>()
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .join(' ');

    final String name = isGuest
        ? l10n.profileGuestName
        : (fullName.isNotEmpty
            ? fullName
            : (user?.email ?? l10n.profileGuestName));

    final String meta = isGuest ? l10n.profileGuestBody : (user?.email ?? '');

    return Container(
      padding: const EdgeInsets.all(VinkolSpace.lg),
      decoration: BoxDecoration(
        color: v.surface,
        borderRadius: VinkolRadius.brLg,
        border: VinkolElevation.hairline(v),
        boxShadow: VinkolElevation.e1(v),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ProfileAvatar(
            initials: isGuest
                ? '–'
                : profileInitials(
                    first: user?.firstname,
                    last: user?.lastname,
                    email: user?.email,
                  ),
            imageUrl: isGuest ? null : user?.avatar?.imageUrl,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  name,
                  style: VinkolType.h3.copyWith(color: v.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  style: VinkolType.bodyS.copyWith(color: v.textTertiary),
                  // The guest line is a sentence; the email is one line and elides.
                  maxLines: isGuest ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isGuest) ...<Widget>[
            const SizedBox(width: VinkolSpace.md),
            VinkolIconButton(
              icon: Icons.chevron_right,
              semanticLabel: l10n.profilePersonalInfo,
              onTap: () => NavigationService.instance
                  .navigateTo(NavigatorRoutes.personalInfoScreen),
            ),
          ],
        ],
      ),
    );
  }
}

/// The build actually running, read from the bundle rather than a constant that goes stale
/// the next time someone bumps `pubspec.yaml`. It is the first thing support asks for.
class _VersionLine extends StatelessWidget {
  const _VersionLine();

  @override
  Widget build(BuildContext context) {
    final v = context.vinkol;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        final PackageInfo? info = snapshot.data;
        if (info == null) return const SizedBox(height: 16);
        return Text(
          context.l10n.profileVersion('${info.version} (${info.buildNumber})'),
          style: VinkolType.caption.copyWith(color: v.textTertiary),
        );
      },
    );
  }
}
