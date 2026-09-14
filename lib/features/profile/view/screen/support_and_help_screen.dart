import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:starter_codes/core/constants/link_routes.dart';
import 'package:starter_codes/core/money/money.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/core/utils/textstyles.dart';
import 'package:starter_codes/features/profile/view/widget/settings_group.dart';
import 'package:starter_codes/provider/market_provider.dart';
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/modal/app_status_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact routes and answers.
///
/// The old screen offered six equal-weight ways to reach support, two of every
/// channel, labelled "(Primary)" and "(Secondary)" — internal language that
/// pushed the decision onto the customer. Here the market's own support line
/// leads, the duplicates fall to a second group, and every row that leaves the
/// app says so with an outbound arrow instead of a chevron that promises a
/// screen.
class SupportHelpScreen extends ConsumerStatefulWidget {
  const SupportHelpScreen({super.key, this.initialTab = 0});

  /// Which tab opens first. 0 is Contact, 1 is FAQ.
  final int initialTab;

  @override
  ConsumerState<SupportHelpScreen> createState() => _SupportHelpScreenState();
}

class _SupportHelpScreenState extends ConsumerState<SupportHelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _open(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      final launched =
          await launchUrl(url, mode: LaunchMode.externalApplication);
      if (launched || !mounted) return;
      _reportFailure();
    } catch (e) {
      debugPrint('Error launching $urlString: $e');
      if (mounted) _reportFailure();
    }
  }

  void _reportFailure() {
    AppStatusDialogs.showError(
        context, 'Could not open', 'Could not open that on this device.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniAppBar(title: 'Help & support'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SegmentedTabs(controller: _tabController),
          ),
          Gap.h24,
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ContactTab(onOpen: _open),
                const _FaqTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Two segments, flat, hairline. A pill inside a pill so the selected state
/// carries shape as well as colour.
class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightgrey),
      ),
      child: TabBar(
        controller: controller,
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        splashBorderRadius: BorderRadius.circular(8),
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.darkgrey,
        labelStyle: buttonStyle.copyWith(fontSize: 14),
        unselectedLabelStyle: buttonStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Contact'),
          Tab(text: 'FAQ'),
        ],
      ),
    );
  }
}

class _ContactTab extends ConsumerWidget {
  const _ContactTab({required this.onOpen});

  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final market = ref.watch(marketProvider);
    final profile = ref.watch(marketProfileProvider);
    final supportTel = 'tel:${profile.supportPhone.replaceAll(' ', '')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsGroup(
            label: 'Talk to us',
            children: [
              SettingsRow(
                icon: PhosphorIconsRegular.phone,
                title: 'Call support',
                subtitle: '${profile.supportPhone} · ${profile.supportHours}',
                affordance: RowAffordance.external,
                onTap: () => onOpen(supportTel),
              ),
              SettingsRow(
                icon: PhosphorIconsRegular.whatsappLogo,
                title: 'Chat on WhatsApp',
                subtitle: LinkRoutes.whatsAppNumber,
                affordance: RowAffordance.external,
                onTap: () => onOpen(LinkRoutes.whatsAppChat),
              ),
              SettingsRow(
                icon: PhosphorIconsRegular.envelopeSimple,
                title: 'Email support',
                subtitle: 'Vinkollogistics@gmail.com',
                affordance: RowAffordance.external,
                onTap: () => onOpen(LinkRoutes.emailSupport1),
              ),
            ],
          ),
          if (market == Country.ng) ...[
            Gap.h28,
            SettingsGroup(
              label: 'Other lines',
              footnote: 'Use these if the main line is busy.',
              children: [
                SettingsRow(
                  icon: PhosphorIconsRegular.phone,
                  title: '+234 807 972 2331',
                  affordance: RowAffordance.external,
                  onTap: () => onOpen(LinkRoutes.customerServicePhone1),
                ),
                SettingsRow(
                  icon: PhosphorIconsRegular.phone,
                  title: '+234 701 848 8479',
                  affordance: RowAffordance.external,
                  onTap: () => onOpen(LinkRoutes.customerServicePhone2),
                ),
                SettingsRow(
                  icon: PhosphorIconsRegular.whatsappLogo,
                  title: 'Alternate WhatsApp',
                  affordance: RowAffordance.external,
                  onTap: () => onOpen(LinkRoutes.whatsAppChat2),
                ),
                SettingsRow(
                  icon: PhosphorIconsRegular.envelopeSimple,
                  title: 'vinkolltd@gmail.com',
                  affordance: RowAffordance.external,
                  onTap: () => onOpen(LinkRoutes.emailSupport2),
                ),
              ],
            ),
          ],
          Gap.h28,
          SettingsGroup(
            label: 'About Vinkol',
            children: [
              SettingsRow(
                icon: PhosphorIconsRegular.globe,
                title: 'Website',
                affordance: RowAffordance.external,
                onTap: () => onOpen(LinkRoutes.officialWebsite),
              ),
              SettingsRow(
                icon: PhosphorIconsRegular.info,
                title: 'About us',
                affordance: RowAffordance.external,
                onTap: () => onOpen(LinkRoutes.about),
              ),
              SettingsRow(
                icon: PhosphorIconsRegular.shieldCheck,
                title: 'Privacy policy',
                affordance: RowAffordance.external,
                onTap: () => onOpen(LinkRoutes.privacyPolicy),
              ),
              SettingsRow(
                icon: PhosphorIconsRegular.fileText,
                title: 'Terms and conditions',
                affordance: RowAffordance.external,
                onTap: () => onOpen(LinkRoutes.termsAndCondition),
              ),
            ],
          ),
          Gap.h28,
          SettingsGroup(
            label: 'Follow us',
            children: [
              SettingsRow(
                icon: PhosphorIconsRegular.instagramLogo,
                title: 'Instagram',
                affordance: RowAffordance.external,
                onTap: () => onOpen(LinkRoutes.instagramProfile),
              ),
              SettingsRow(
                icon: PhosphorIconsRegular.xLogo,
                title: 'X',
                affordance: RowAffordance.external,
                onTap: () => onOpen(LinkRoutes.twitterProfile),
              ),
              SettingsRow(
                icon: PhosphorIconsRegular.linkedinLogo,
                title: 'LinkedIn',
                affordance: RowAffordance.external,
                onTap: () => onOpen(LinkRoutes.linkedInProfile),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One question and its answer.
class _Faq {
  const _Faq(this.question, this.answer);

  final String question;
  final String answer;
}

/// The answers are market-aware because the policies are.
///
/// The retention cover is a Nigerian figure and is written through the money
/// layer rather than typed with a symbol, so it can never be shown to a
/// Canadian customer with the wrong sign in front of it.
List<_Faq> _faqsFor(Country market) {
  return [
    const _Faq(
      'What is Vinkol Logistics?',
      'Vinkol Logistics is a digital platform that connects customers with '
          'professional delivery partners for fast, secure and reliable '
          'logistics services.',
    ),
    const _Faq(
      'How does Vinkol work?',
      'Book a delivery in the app, give the pickup and drop-off details, pay '
          'for the quote, and follow the order status until it is delivered.',
    ),
    if (market == Country.ng)
      _Faq(
        'Is my parcel insured during delivery?',
        'Vinkol provides a retention coverage policy of up to '
            '${const Money(50000, Currency.ngn).format()} for theft or damage '
            'to goods during delivery, provided the loss is verified and '
            'occurred without negligence by the rider or logistics company.',
      ),
    const _Faq(
      'Who is responsible if my parcel is damaged or lost?',
      'While Vinkol handles booking and communication, each delivery partner '
          'is directly responsible for carrying out the delivery. Claims '
          'should be directed to the delivery partner involved, and Vinkol '
          'will assist with dispute mediation where necessary.',
    ),
    const _Faq(
      'How do I make sure my item is safe for delivery?',
      'Package the item so it cannot be damaged in transit. Fragile or '
          'high-value items should be wrapped and labelled clearly before '
          'pickup.',
    ),
    const _Faq(
      'How do I follow my delivery?',
      'Open the delivery in the app to see its current status — pending, with '
          'a rider or shopper, or delivered. Status is for information and '
          'should not be relied on for legal or financial claims.',
    ),
    const _Faq(
      'What if something goes wrong with my delivery?',
      'Report it through the app or contact Vinkol support within 48 hours of '
          'the delivery attempt. Vinkol will review and mediate your case '
          'where applicable.',
    ),
    const _Faq(
      'Can I cancel or change a delivery request?',
      'You can cancel or change a request before a rider accepts it. Once a '
          'delivery is in progress, cancellation policies may apply depending '
          'on the stage it has reached.',
    ),
    const _Faq(
      'How will I hear about delivery updates?',
      'Updates arrive as notifications in the app and by email at the address '
          'on your account.',
    ),
    const _Faq(
      'Does Vinkol store my personal data?',
      'Vinkol collects only what is needed to complete your delivery. All '
          'data is handled in line with data protection law and our privacy '
          'policy.',
    ),
    const _Faq(
      'How often do the terms change?',
      'Vinkol may update its terms and conditions from time to time. '
          'Continuing to use the platform after an update means you accept the '
          'new terms.',
    ),
  ];
}

class _FaqTab extends ConsumerWidget {
  const _FaqTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqs = _faqsFor(ref.watch(marketProvider));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: faqs.length,
      separatorBuilder: (_, __) => Gap.h12,
      itemBuilder: (context, index) => _FaqTile(faq: faqs[index]),
    );
  }
}

/// A question that opens in place. Flat card, hairline border, caret rotates so
/// the state is legible without reading the body.
class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.faq});

  final _Faq faq;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightgrey),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedSize(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText.body(
                          widget.faq.question,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          lineHeight: 1.35,
                        ),
                      ),
                      Gap.w12,
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        child: const Icon(
                          PhosphorIconsRegular.caretDown,
                          size: 16,
                          color: AppColors.darkgrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_expanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: AppText.body(
                      widget.faq.answer,
                      fontSize: 14,
                      color: AppColors.darkgrey,
                      lineHeight: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
