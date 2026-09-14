import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/constants/link_routes.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/core/utils/app_version_checker.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/launch_link.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/features/auth/model/user_model.dart';
import 'package:starter_codes/features/profile/view/widget/settings_group.dart';
import 'package:starter_codes/provider/app_provider.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/provider/user_provider.dart';
import 'package:starter_codes/utils/guest_mode_utils.dart';
import 'package:starter_codes/widgets/app_bar/empty_app_bar.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/modal/logout_modal.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// The account hub.
///
/// Identity first, then the settings themselves rather than a row that leads to
/// them: Country used to sit one tap deeper behind a Settings screen that held
/// nothing else, so it was brought up here and that screen retired. Every row
/// goes somewhere real — there is no row here for a preference the app cannot
/// actually honour. Country is shown but not editable: a customer's market is
/// changed by support, never by the customer, so the row carries no affordance.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(userProvider);
    final marketName = ref.watch(marketProfileProvider).displayName;

    // Guest is what the cache says, not what the absence of a user says: the
    // profile arrives a moment after the screen does, and a returning customer
    // must never be told they are browsing as a guest in the meantime.
    final isGuest = GuestModeUtils.isGuestMode();
    final isLoading = !isGuest && user == null;

    return Scaffold(
      appBar: const EmptyAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h1('Profile'),
            Gap.h20,
            if (isGuest)
              const _GuestCard()
            else if (isLoading)
              const _IdentityPlaceholder()
            else
              _IdentityCard(user: user!),
            Gap.h28,
            if (!isGuest) ...[
              SettingsGroup(
                label: 'Account',
                children: [
                  SettingsRow(
                    icon: PhosphorIconsRegular.userCircle,
                    title: 'Personal info',
                    onTap: () => NavigationService.instance
                        .navigateTo(NavigatorRoutes.personalInfoScreen),
                  ),
                  SettingsRow(
                    icon: PhosphorIconsRegular.lockKey,
                    title: 'Security',
                    onTap: () => NavigationService.instance
                        .navigateTo(NavigatorRoutes.securityScreen),
                  ),
                ],
              ),
              Gap.h28,
            ],
            SettingsGroup(
              label: 'Preferences',
              footnote: '',
              children: [
                SettingsRow(
                  icon: PhosphorIconsRegular.bell,
                  title: 'Notifications',
                  onTap: () => NavigationService.instance
                      .navigateTo(NavigatorRoutes.notificationSettingsScreen),
                ),
                SettingsRow(
                  icon: PhosphorIconsRegular.globeHemisphereWest,
                  title: 'Country',
                  value: marketName,
                  affordance: RowAffordance.none,
                ),
              ],
            ),
            Gap.h28,
            SettingsGroup(
              label: 'About',
              children: [
                SettingsRow(
                  icon: PhosphorIconsRegular.lifebuoy,
                  title: 'Help & support',
                  onTap: () => NavigationService.instance
                      .navigateTo(NavigatorRoutes.supportAndHelpScreen),
                ),
                SettingsRow(
                  icon: PhosphorIconsRegular.star,
                  title: 'Rate Vinkol',
                  affordance: RowAffordance.external,
                  onTap: () {
                    final url = LinkRoutes.storeListing();
                    if (url.isNotEmpty) LaunchLink.launchURL(url);
                  },
                ),
                const _UpdateRow(),
              ],
            ),
            if (!isGuest) ...[
              Gap.h28,
              SettingsGroup(
                footnote: 'Deleting your account is handled on the Vinkol '
                    'website and opens in your browser.',
                children: [
                  SettingsRow(
                    icon: PhosphorIconsRegular.signOut,
                    title: 'Log out',
                    destructive: true,
                    affordance: RowAffordance.none,
                    onTap: () => showLogoutModal(context),
                  ),
                  SettingsRow(
                    icon: PhosphorIconsRegular.trash,
                    title: 'Delete account',
                    destructive: true,
                    affordance: RowAffordance.external,
                    onTap: () => launchUrlString(
                      LinkRoutes.deleteAccount,
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows the installed version, and checks it against the one the server
/// expects — the same comparison the splash screen makes to force an update,
/// so the two can never disagree.
class _UpdateRow extends ConsumerStatefulWidget {
  const _UpdateRow();

  @override
  ConsumerState<_UpdateRow> createState() => _UpdateRowState();
}

class _UpdateRowState extends ConsumerState<_UpdateRow> {
  String _version = '';
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = '${info.version} (${info.buildNumber})');
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final details = await ref.refresh(appDetailsProvider.future);
      final customerApp =
          details.data.getPlatformDetails(Platform.isAndroid).customerApp;
      final outdated = AppVersionChecker.isUpdateRequired(
        customerApp,
        await AppVersionChecker.getCurrentVersion(),
        await AppVersionChecker.getCurrentBuildNumber(),
      );
      if (!mounted) return;
      if (outdated) {
        final url = LinkRoutes.storeListing();
        if (url.isNotEmpty) {
          await LaunchLink.launchURL(url);
        }
      } else {
        AppStatusDialogs.showSuccess(
          context,
          'Up to date',
          'You are on the latest version of Vinkol.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppStatusDialogs.showError(
        context,
        'Could not check',
        'We could not reach Vinkol to check for a newer version. Try again '
            'when you are back online.',
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: PhosphorIconsRegular.arrowsClockwise,
      title: 'Check for updates',
      value: _checking || _version.isEmpty ? 'Checking…' : _version,
      affordance: RowAffordance.none,
      onTap: _check,
    );
  }
}

/// Name, email and the way into editing them. The whole card is the control,
/// so the chevron is telling the truth about the whole row.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final name = user.fullName.trim();
    final displayName = name.isEmpty || name == 'User' ? user.email : name;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => NavigationService.instance
              .navigateTo(NavigatorRoutes.personalInfoScreen),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _Avatar(user: user),
                Gap.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.body(
                        displayName,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        maxLines: 1,
                      ),
                      Gap.h4,
                      AppText.caption(
                        user.email,
                        fontSize: 13,
                        color: AppColors.darkgrey,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Gap.w12,
                const Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A person glyph until there is a photo.
///
/// The glyph sits behind [CircleAvatar.foregroundImage], so it is what shows
/// while a photo is still downloading and what remains if the download fails —
/// the circle is never empty.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final url = user.avatar?.imageUrl;
    final hasPhoto = url != null && url.isNotEmpty;

    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.primary,
      foregroundImage: hasPhoto ? NetworkImage(url) : null,
      child: const Icon(
        PhosphorIconsFill.user,
        size: 26,
        color: AppColors.white,
      ),
    );
  }
}

/// The identity card before the profile has arrived. Same shape and height as
/// the real thing, so the screen does not jump when the name loads.
class _IdentityPlaceholder extends StatelessWidget {
  const _IdentityPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightgrey),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(radius: 26, backgroundColor: AppColors.lightgrey),
          Gap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Bar(width: 140, height: 14),
                Gap.h8,
                const _Bar(width: 190, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightgrey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// What a guest sees instead of an identity. It states the trade and offers the
/// one action that changes it, rather than reading "Guest User / Not Logged In"
/// above rows that go nowhere useful.
class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.body(
            "You're browsing as a guest",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          Gap.h6,
          AppText.caption(
            'Log in to book deliveries, follow your orders and keep your '
            'details in one place.',
            fontSize: 13,
            color: AppColors.darkgrey,
            lineHeight: 1.45,
          ),
          Gap.h20,
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              title: 'Log in or sign up',
              onTap: () => NavigationService.instance
                  .navigateToReplaceAll(NavigatorRoutes.authChoiceScreen),
            ),
          ),
        ],
      ),
    );
  }
}
