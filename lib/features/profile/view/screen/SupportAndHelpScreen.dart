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
            title: 'Customer Service (Primary): +234 3367 0745',
            onTap: () {
              _launchUrl(context, LinkRoutes.customerServicePhone1);
            },
          ),
          _ContactOption(
            icon: Icons
                .phone_in_talk_outlined, // Changed icon for visual distinction
            title: 'Customer Service (Secondary): +234 8079 72231',
            onTap: () {
              _launchUrl(context, LinkRoutes.customerServicePhone2);
            },
          ),
          _ContactOption(
            icon: Icons.email_outlined,
            title: 'Email Us: info@vinkol.com',
            onTap: () {
              _launchUrl(context, LinkRoutes.emailSupport1);
            },
          ),
          _ContactOption(
            icon: Icons.mail_outline, // Changed icon for visual distinction
            title: 'Email Us: info@vinkolventures.onmicrosoft.com',
            onTap: () {
              _launchUrl(context, LinkRoutes.emailSupport2);
            },
          ),
          _ContactOption(
            icon: Icons.chat_bubble_outline,
            title: 'Chat on WhatsApp: +234 8012 345678',
            onTap: () {
              _launchUrl(context, LinkRoutes.whatsAppChat);
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
            title: 'Follow Us on Instagram: @vinkollogistics',
            onTap: () {
              _launchUrl(context, LinkRoutes.instagramProfile);
            },
          ),
          _ContactOption(
            icon: Icons.alternate_email,
            title: 'Follow Us on X (Twitter): @vinkolltd',
            onTap: () {
              _launchUrl(context, LinkRoutes.twitterProfile);
            },
          ),
          _ContactOption(
            icon: Icons.link,
            title: 'Connect on LinkedIn: Vinkol Logistics',
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

          // --- Getting Started / Account Management ---
          const _FAQItem(
            question: 'How do I sign up to become a rider?',
            answer:
                'You can sign up directly through the app by navigating to the "Become a Rider" section or visit our official website for registration instructions. You\'ll need to provide necessary documents and undergo a verification process.',
          ),
          const _FAQItem(
            question: 'What are the requirements to be a rider?',
            answer:
                'Typical requirements include a valid driver\'s license/rider\'s permit, a reliable vehicle (motorcycle, car, bicycle), a smartphone, and the legal right to work in the country/region. Specific age and background check requirements may apply.',
          ),
          const _FAQItem(
            question: 'How do I update my profile or vehicle information?',
            answer:
                'Go to the "document" section in your rider app. You can edit your personal details, vehicle type, license information, and bank details there. All changes may require verification.',
          ),

          // --- Accepting & Completing Orders ---
          const _FAQItem(
            question: 'How do I accept a new delivery request?',
            answer:
                'When a new order is available, you will receive a notification. Tap "Accept" within the given time limit to take the order. The app will then guide you to the pickup location.',
          ),
          const _FAQItem(
            question: 'What should I do if I can\'t find the pickup location?',
            answer:
                'Use the in-app navigation. If you\'re still having trouble, contact the merchant/customer directly through the app\'s chat or call feature. If issues persist, contact rider support.',
          ),
          const _FAQItem(
            question: 'How do I mark an order as picked up?',
            answer:
                'Once you have collected all items from the merchant, verify them against the order details in the app, and then tap the "Picked Up" or "Confirm Pickup" button.',
          ),
          const _FAQItem(
            question: 'What if a customer is not at the delivery location?',
            answer:
                'Attempt to contact the customer via the in-app call or chat. Wait for a predetermined time (e.g., 5-10 minutes). If no response, follow the app\'s instructions for undeliverable orders, which may involve returning to the merchant or contacting support.',
          ),
          const _FAQItem(
            question: 'How do I confirm a successful delivery?',
            answer:
                'After handing over the order to the customer, tap "Delivered" or "Complete Order" in the app. You may also be required to collect payment (if cash on delivery) or capture proof of delivery (e.g., signature or photo).',
          ),

          // --- Earnings & Payments ---
          const _FAQItem(
            question: 'How do I view my earnings?',
            answer:
                'Your earnings dashboard is available in the "Earnings" or "Wallet" section of the app. It provides a breakdown of your completed deliveries, tips, and total income.',
          ),
          const _FAQItem(
            question: 'When and how do I get paid?',
            answer:
                'Payments are typically processed weekly/bi-weekly directly to your linked bank account. You can set up or update your payment details in the "Payment Settings" section.',
          ),
          const _FAQItem(
            question: 'What is surge pricing/peak pay?',
            answer:
                'Surge pricing or peak pay is an additional incentive offered during high-demand periods or in specific zones, increasing your earnings per delivery. It will be indicated in the app.',
          ),
          const _FAQItem(
            question: 'How are tips handled?',
            answer:
                'All tips from customers are 100% yours. They are added to your total earnings and paid out with your regular disbursements.',
          ),

          // --- Support & Safety ---
          const _FAQItem(
            question: 'How do I contact rider support?',
            answer:
                'You can contact rider support via the "Help" or "Support" section in the app. We offer in-app chat, a dedicated phone line, and email support for urgent and non-urgent queries.',
          ),
          const _FAQItem(
            question: 'What if I have an accident during a delivery?',
            answer:
                'Prioritize your safety and call emergency services if necessary. Then, immediately contact rider support through the app to report the incident. Provide all relevant details.',
          ),
          const _FAQItem(
            question: 'What are the community guidelines for riders?',
            answer:
                'Our community guidelines emphasize professionalism, courtesy, safe driving/riding practices, and timely deliveries. Adhering to these ensures a positive experience for everyone.',
          ),

          // --- App Functionality / Technical ---
          const _FAQItem(
            question: 'My app isn\'t showing new orders. What should I do?',
            answer:
                'First, check your internet connection. Then, ensure you are "Online" or "Available" in the app. If the issue persists, try restarting the app or your device. You can also contact support.',
          ),
          const _FAQItem(
            question: 'How does the in-app navigation work?',
            answer:
                'The app uses your device\'s GPS to provide turn-by-turn directions to both pickup and delivery locations. You can often choose your preferred navigation app (e.g., Google Maps, Waze) within the settings.',
          ),
          const _FAQItem(
            question: 'How can I improve my rider rating?',
            answer:
                'Focus on providing excellent service: ensure timely deliveries, maintain good communication with customers and merchants, handle items with care, and always be polite and professional.',
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
