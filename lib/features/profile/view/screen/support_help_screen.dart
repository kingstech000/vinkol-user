import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_codes/core/constants/link_routes.dart';
import 'package:starter_codes/core/design/design.dart';
import 'package:starter_codes/core/market/market.dart';
import 'package:starter_codes/features/profile/view/widget/profile_widgets.dart';
import 'package:starter_codes/l10n/l10n.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/vinkol/vinkol_components.dart';

/// **Support & help** — how to reach a person, then the questions that save the call.
///
/// The contacts come from the market, not from `LinkRoutes`: a Canadian user must never be
/// given a Nigerian number, and a screen that branches on country to avoid that is the bug
/// the market layer exists to remove (D-09). Whatever channels the market defines are the
/// channels rendered; a market with no second line or no messaging channel simply has fewer
/// rows.
///
/// The two tabs are gone. A tab bar for two lists, one of which is read once, cost a control
/// and hid the FAQ behind it; both are sections of one scroll now.
///
/// The FAQ answers were corrected where they described features that do not exist: live
/// parcel tracking (there is order status, not a live map) and in-app rider chat (there is a
/// phone number on the order). The coverage answer takes its figure from the market and
/// falls back to claim-free wording where a market has set none — a Nigerian retention policy
/// is not a Canadian one converted.
class SupportHelpScreen extends ConsumerWidget {
  const SupportHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = context.vinkol;
    final l10n = context.l10n;
    final Market market = ref.watch(currentMarketProvider);
    final MarketSupport support = market.support;

    return Scaffold(
      backgroundColor: v.canvas,
      appBar: MiniAppBar(title: l10n.profileSupport),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          VinkolSpace.pageMargin,
          VinkolSpace.xs,
          VinkolSpace.pageMargin,
          VinkolSpace.xxl,
        ),
        children: <Widget>[
          VinkolSectionHeader(label: l10n.supportContactGroup),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.call_outlined,
                accentIcon: true,
                title: l10n.supportCall,
                meta: '${support.phone} · ${support.hours}',
                metaMaxLines: 2,
                onTap: () => profileLaunch(context, support.phoneUri),
              ),
              if (support.phoneAltUri != null)
                VinkolRow(
                  icon: Icons.phone_forwarded_outlined,
                  title: l10n.supportCallAlt,
                  meta: support.phoneAlt,
                  onTap: () => profileLaunch(context, support.phoneAltUri!),
                ),
              VinkolRow(
                icon: Icons.mail_outline,
                title: l10n.supportEmailAction,
                meta: support.email,
                onTap: () => profileLaunch(context, support.emailUri),
              ),
              if (support.whatsapp != null)
                VinkolRow(
                  icon: Icons.chat_outlined,
                  title: l10n.supportWhatsapp,
                  onTap: () => profileLaunch(context, support.whatsapp!),
                ),
            ],
          ),
          const SizedBox(height: VinkolSpace.lg),
          VinkolNotice(
            headline: l10n.supportHeadline(market.displayName),
            body: l10n.supportHoursNote(support.hours),
            icon: Icons.support_agent_outlined,
          ),
          VinkolSectionHeader(label: l10n.supportFaqGroup),
          ProfileGroup(children: _faq(context, market)),
          VinkolSectionHeader(label: l10n.supportAboutGroup),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.language_outlined,
                title: l10n.supportWebsite,
                onTap: () => profileLaunch(context, LinkRoutes.officialWebsite),
              ),
              VinkolRow(
                icon: Icons.info_outline,
                title: l10n.supportAboutVinkol,
                onTap: () => profileLaunch(context, LinkRoutes.about),
              ),
            ],
          ),
          VinkolSectionHeader(label: l10n.supportFollowGroup),
          VinkolRowGroup(
            children: <VinkolRow>[
              VinkolRow(
                icon: Icons.camera_alt_outlined,
                title: l10n.supportInstagram,
                onTap: () =>
                    profileLaunch(context, LinkRoutes.instagramProfile),
              ),
              VinkolRow(
                icon: Icons.alternate_email,
                title: l10n.supportX,
                onTap: () => profileLaunch(context, LinkRoutes.twitterProfile),
              ),
              VinkolRow(
                icon: Icons.work_outline,
                title: l10n.supportLinkedIn,
                onTap: () => profileLaunch(context, LinkRoutes.linkedInProfile),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _faq(BuildContext context, Market market) {
    final l10n = context.l10n;
    final num? coverage = market.liabilityCoverage;

    return <Widget>[
      ProfileFaqItem(question: l10n.supportFaqQ1, answer: l10n.supportFaqA1),
      ProfileFaqItem(question: l10n.supportFaqQ2, answer: l10n.supportFaqA2),
      ProfileFaqItem(
        question: l10n.supportFaqQ3,
        answer: coverage == null
            ? l10n.supportFaqA3Uncovered
            : l10n.supportFaqA3Covered(MarketFormat.money(coverage)),
      ),
      ProfileFaqItem(question: l10n.supportFaqQ4, answer: l10n.supportFaqA4),
      ProfileFaqItem(question: l10n.supportFaqQ5, answer: l10n.supportFaqA5),
      ProfileFaqItem(question: l10n.supportFaqQ6, answer: l10n.supportFaqA6),
      ProfileFaqItem(question: l10n.supportFaqQ7, answer: l10n.supportFaqA7),
      ProfileFaqItem(question: l10n.supportFaqQ8, answer: l10n.supportFaqA8),
      ProfileFaqItem(question: l10n.supportFaqQ9, answer: l10n.supportFaqA9),
      ProfileFaqItem(question: l10n.supportFaqQ10, answer: l10n.supportFaqA10),
      ProfileFaqItem(question: l10n.supportFaqQ11, answer: l10n.supportFaqA11),
      ProfileFaqItem(question: l10n.supportFaqQ12, answer: l10n.supportFaqA12),
      ProfileFaqItem(
        question: l10n.supportFaqQ13,
        answer: l10n.supportFaqA13(market.support.hours),
      ),
    ];
  }
}
