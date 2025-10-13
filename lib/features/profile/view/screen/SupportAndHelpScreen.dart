import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/constants/link_routes.dart'; // Ensure this file exists and is correctly structured
import 'package:starter_codes/core/utils/colors.dart'; // Ensure this file exists
import 'package:starter_codes/core/utils/text.dart'; // Ensure this file exists (likely contains AppText widget)
import 'package:starter_codes/core/utils/textstyles.dart'; // Ensure this file exists (for bodyStyle)
import 'package:starter_codes/widgets/app_bar/mini_app_bar.dart'; // Ensure this file exists
import 'package:starter_codes/widgets/gap.dart'; // Ensure this file exists
import 'package:url_launcher/url_launcher.dart'; // Use url_launcher directly

class SupportHelpScreen extends StatefulWidget {
  const SupportHelpScreen({super.key});

  @override
  State<SupportHelpScreen> createState() => _SupportHelpScreenState();
}

class _SupportHelpScreenState extends State<SupportHelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Helper function to launch URLs safely and show SnackBars.
  /// It attempts to launch the URL and shows a SnackBar if it fails.
  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while trying to open the link: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error launching $urlString: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MiniAppBar(
        icon: Icons.arrow_back_ios,
        color: AppColors.black,
        title: 'Support And Help',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h24,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.black,
                labelStyle: bodyStyle,
                unselectedLabelStyle: bodyStyle,
                tabs: const [
                  Tab(text: 'Contact Us'),
                  Tab(text: 'FAQ'),
                ],
              ),
            ),
          ),
          Gap.h20,
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContactUsTab(context), // Pass context to the builder
                _buildFAQTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the 'Contact Us' tab content.
  Widget _buildContactUsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Added for consistent alignment
        children: [
          Gap.h32,
          _ContactOption(
            icon: Icons.phone_outlined,
            title: 'Customer Service (Primary)',
            onTap: () {
              _launchUrl(context, LinkRoutes.customerServicePhone1);
            },
          ),
          _ContactOption(
            icon: Icons
                .phone_in_talk_outlined, // Changed icon for visual distinction
            title: 'Customer Service (Secondary)',
            onTap: () {
              _launchUrl(context, LinkRoutes.customerServicePhone2);
            },
          ),
          _ContactOption(
            icon: Icons.email_outlined,
            title: 'Email Us: Vinkollogistics@gmail.com',
            onTap: () {
              _launchUrl(context, LinkRoutes.emailSupport1);
            },
          ),
          _ContactOption(
            icon: Icons.mail_outline, // Changed icon for visual distinction
            title: 'Email Us: vinkolltd@gmail.com',
            onTap: () {
              _launchUrl(context, LinkRoutes.emailSupport2);
            },
          ),
          _ContactOption(
            icon: Icons.chat_bubble_outline,
            title: 'Chat on WhatsApp 1',
            onTap: () {
              _launchUrl(context, LinkRoutes.whatsAppChat);
            },
          ),
          _ContactOption(
            icon: Icons.chat_bubble_outline,
            title: 'Chat on WhatsApp 2',
            onTap: () {
              _launchUrl(context, LinkRoutes.whatsAppChat2);
            },
          ),
          Gap.h32,
          AppText.body(
            'About',
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            textAlign: TextAlign.start,
          ),
          _ContactOption(
            icon: Icons.web,
            title: 'Official Website',
            onTap: () => _launchUrl(context, LinkRoutes.officialWebsite),
          ),
          _ContactOption(
            icon: Icons.info_outline, // Changed icon
            title: 'About Us',
            onTap: () => _launchUrl(context, LinkRoutes.about),
          ),
          _ContactOption(
            icon: Icons.privacy_tip_outlined, // Changed icon
            title: 'Privacy Policy',
            onTap: () => _launchUrl(context, LinkRoutes.privacyPolicy),
          ),
          _ContactOption(
            icon: Icons.description_outlined, // Changed icon
            title: 'Terms and Condition',
            onTap: () => _launchUrl(context, LinkRoutes.termsAndCondition),
          ),
          Gap.h32,
          AppText.body(
            'Find us on Social Media',
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            textAlign: TextAlign.start,
          ),
          _ContactOption(
            icon: Icons.camera_alt_outlined,
            title: 'Follow Us on Instagram',
            onTap: () {
              _launchUrl(context, LinkRoutes.instagramProfile);
            },
          ),
          _ContactOption(
            icon: Icons.alternate_email,
            title: 'Follow Us on X (Twitter)',
            onTap: () {
              _launchUrl(context, LinkRoutes.twitterProfile);
            },
          ),
          _ContactOption(
            icon: Icons.link,
            title: 'Connect on LinkedIn',
            onTap: () {
              _launchUrl(context, LinkRoutes.linkedInProfile);
            },
          ),
          Gap.h32,
        ],
      ),
    );
  }

  /// Builds the 'FAQ' tab content.
  Widget _buildFAQTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Gap.h32, // Top padding

          // --- About Vinkol ---
          const _FAQItem(
            question: 'What is Vinkol Logistics?',
            answer:
                'Vinkol Logistics is a digital platform that connects customers with professional delivery partners for fast, secure, and reliable logistics services across Nigeria.',
          ),
          const _FAQItem(
            question: 'How does Vinkol work?',
            answer:
                'Simply log into the Vinkol Customer App, book your delivery, provide pickup and drop-off details, and track your parcel in real time until it reaches the destination.',
          ),

          // --- Safety & Insurance ---
          const _FAQItem(
            question: 'Is my parcel insured during delivery?',
            answer:
                'Yes. Vinkol provides a retention coverage policy of up to ₦50,000 for theft or damage to goods during delivery, provided the loss is verified and occurred without negligence by the rider or logistics company.',
          ),
          const _FAQItem(
            question: 'Who is responsible if my parcel gets damaged or lost?',
            answer:
                'While Vinkol facilitates the booking and communication process, each delivery partner is directly responsible for the execution of deliveries. Claims should be directed to the delivery partner involved. Vinkol will assist with dispute mediation where necessary.',
          ),
          const _FAQItem(
            question: 'How can I ensure my item is safe for delivery?',
            answer:
                'Please ensure that your item is properly packaged to prevent damage. Fragile or high-value items should be wrapped and labeled clearly before pickup.',
          ),

          // --- Tracking & Delivery ---
          const _FAQItem(
            question: 'How do I track my delivery?',
            answer:
                'You can track your delivery in real time using the tracking feature in the Vinkol Customer App. The data shown is for informational purposes only and should not be relied upon for legal or financial claims.',
          ),
          const _FAQItem(
            question: 'What should I do if there is an issue with my delivery?',
            answer:
                'If you experience a problem, please report it through the app or contact Vinkol Customer Support within 48 hours of the delivery attempt. Vinkol will review and mediate your case where applicable.',
          ),
          const _FAQItem(
            question: 'Can I cancel or edit my delivery request?',
            answer:
                'Yes, you may cancel or modify a delivery request before it is accepted by a rider. Once a delivery is in progress, cancellation policies may apply based on the stage of the delivery.',
          ),

          // --- Communication ---
          const _FAQItem(
            question: 'Can I contact the rider directly?',
            answer:
                'Yes, the Vinkol app allows direct communication with your assigned rider for clarification on delivery details or to confirm pickup/drop-off locations.',
          ),
          const _FAQItem(
            question: 'How will I be notified about my delivery updates?',
            answer:
                'You will receive instant notifications through the app and your registered email regarding delivery status, rider updates, and successful completion of your order.',
          ),

          // --- Privacy & Terms ---
          const _FAQItem(
            question: 'Does Vinkol store my personal data?',
            answer:
                'Vinkol only collects essential information required to complete your delivery and ensure customer satisfaction. All data is handled in compliance with data protection laws and our internal privacy policy.',
          ),
          const _FAQItem(
            question: 'How often are Vinkol\'s terms updated?',
            answer:
                'Vinkol reserves the right to update its terms and conditions periodically. Continued use of the platform after updates means you accept the new terms.',
          ),

          // --- Support ---
          const _FAQItem(
            question: 'How do I contact Vinkol support?',
            answer:
                'You can reach our customer support team through the \'Help\' section in the app or via email at Vinkollogistics@gmail.com. We\'re available to assist with inquiries, disputes, or feedback.',
          ),

          Gap.h32, // Bottom padding
        ],
      ),
    );
  }
}

/// A StatelessWidget to display a contact option with an icon, title, and a single onTap callback.
class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            EdgeInsets.symmetric(vertical: 16.h), // Consistent vertical padding
        child: Row(
          children: [
            Icon(icon, color: AppColors.black, size: 24.w),
            Gap.w16,
            Expanded(
              child: AppText.body(title,
                  color: AppColors.black), // Display title as content
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18.w),
          ],
        ),
      ),
    );
  }
}

/// A StatefulWidget to display a collapsible FAQ item (question and answer).
class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(color: Colors.grey.shade200, width: 1.w),
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText.body(
                      widget.question,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h), // Adjusted horizontal padding
              child: AppText.body(
                widget.answer,
                color: Colors.grey.shade700,
              ),
            ),
        ],
      ),
    );
  }
}
