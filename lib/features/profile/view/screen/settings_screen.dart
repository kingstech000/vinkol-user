import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/constants/link_routes.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market.dart';
import 'package:starter_codes/core/router/routing_constants.dart';
import 'package:starter_codes/core/services/navigation_service.dart';
import 'package:starter_codes/features/profile/view/widget/profile_widgets.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// **Settings** — preferences, legal, and the one destructive action.
///
/// Country is the important row and it is new. Choosing a market sets the currency and its
/// decimal count, whether a tax line is displayed and what it is called, the word for an
/// administrative region, the address fields and their order, the dial code and the support
/// contacts (D-09). It opens the same picker onboarding uses, so there is one place that
/// knowledge lives.
///
/// Language offers only what the active market ships: English in Nigeria, English and
/// Français in Canada. Offering French where there is no French copy is precisely the Quebec
/// compliance failure the market layer exists to prevent.
///
/// Dark mode is not here. The theme follows the device, as Midnight intends — an in-app
/// override is a preference the app would have to store and nothing asked for it.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final Market market = ref.watch(currentMarketProvider);
    final Region region = ref.watch(currentRegionProvider);
    final String languageCode = ref.watch(appLocaleProvider).languageCode;
    final MarketLanguage active = market.languages.firstWhere(
      (MarketLanguage l) => l.code == languageCode,
      orElse: () => market.languages.first,
    );

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: MiniAppBar(title: l10n.profileSettings),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          VinkolSpace.pageMargin,
          VinkolSpace.xs,
          VinkolSpace.pageMargin,
          VinkolSpace.xxl,
        ),
        children: <Widget>[
          VinkolSectionHeader(label: l10n.profilePreferences),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.notifications_none,
                title: l10n.profileNotifications,
                meta: l10n.profileNotificationsMeta,
                onTap: () => NavigationService.instance
                    .navigateTo(NavigatorRoutes.notificationSettingsScreen),
              ),
              VinkolRow(
                icon: Icons.translate,
                title: l10n.profileLanguage,
                meta: l10n.profileLanguageMeta(
                  market.languages.length,
                  active.nativeName,
                ),
                onTap: () => _pickLanguage(context, ref, market, active),
              ),
              VinkolRow(
                icon: Icons.public,
                title: l10n.profileCountry,
                meta: l10n.profileCountryMeta(
                  market.displayName,
                  region.name,
                  market.currency.code,
                ),
                metaMaxLines: 2,
                onTap: () => NavigationService.instance.navigateTo(
                  NavigatorRoutes.marketSelectScreen,
                  argument: <String, dynamic>{'fromSettings': true},
                ),
              ),
            ],
          ),
          VinkolSectionHeader(label: l10n.profileLegal),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.description_outlined,
                title: l10n.profileTerms,
                onTap: () =>
                    profileLaunch(context, LinkRoutes.termsAndCondition),
              ),
              VinkolRow(
                icon: Icons.privacy_tip_outlined,
                title: l10n.profilePrivacy,
                onTap: () => profileLaunch(context, LinkRoutes.privacyPolicy),
              ),
            ],
          ),
          VinkolSectionHeader(label: l10n.profileDangerZone),
          ProfileGroup(
            children: <Widget>[
              ProfileDangerRow(
                icon: Icons.person_remove_outlined,
                title: l10n.profileDeleteAccount,
                meta: l10n.profileDeleteAccountMeta,
                // Deletion is a web form, not an endpoint the app can call. The dialog says
                // where the tap leads and what it costs, because leaving the app for a
                // browser with no warning is how a user loses an account by accident.
                onTap: () => AppStatusDialogs.showConfirmation(
                  context,
                  title: l10n.profileDeleteTitle,
                  message: l10n.profileDeleteBody,
                  confirmText: l10n.profileDeleteContinue,
                  cancelText: l10n.commonCancel,
                  onConfirm: () =>
                      profileLaunch(context, LinkRoutes.deleteAccount),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    Market market,
    MarketLanguage active,
  ) {
    final v = context.vinkol;
    final l10n = context.l10n;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => Container(
        padding: const EdgeInsetsDirectional.fromSTEB(
          VinkolSpace.xl,
          VinkolSpace.md,
          VinkolSpace.xl,
          VinkolSpace.xl,
        ),
        decoration: BoxDecoration(
          color: v.surface,
          borderRadius: VinkolRadius.brSheet,
          border: BorderDirectional(top: BorderSide(color: v.borderSubtle)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: v.borderStrong,
                    borderRadius: VinkolRadius.brFull,
                  ),
                ),
              ),
              const SizedBox(height: VinkolSpace.xl),
              Text(
                l10n.profileChooseLanguage,
                style: VinkolType.h3.copyWith(color: v.textPrimary),
              ),
              const SizedBox(height: VinkolSpace.xs),
              Text(
                l10n.profileLanguageNote(market.displayName),
                style: VinkolType.bodyS.copyWith(color: v.textTertiary),
              ),
              const SizedBox(height: VinkolSpace.lg),
              VinkolRowGroup(
                children: <VinkolRow>[
                  for (final MarketLanguage language in market.languages)
                    VinkolRow(
                      title: language.nativeName,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        ref
                            .read(localeNotifierProvider.notifier)
                            .select(language.code);
                      },
                      trailing: language.code == active.code
                          ? Icon(Icons.check, size: 18, color: v.brand)
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
