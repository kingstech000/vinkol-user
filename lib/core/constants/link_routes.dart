// lib/core/router/link_routes.dart

import 'dart:io';

class LinkRoutes {
  // Customer Service & Support
  /// Nigerian support. For market-scoped contacts prefer
  /// `MarketProfile.supportPhone`; these remain for the existing NG links.
  static const String customerServicePhone1 = 'tel:+2348079722331';
  static const String customerServicePhone2 = 'tel:+2347018488479';
  static const String emailSupport1 = 'mailto:Vinkollogistics@gmail.com';
  static const String emailSupport2 = 'mailto:vinkolltd@gmail.com';

  /// WhatsApp support. One line serves every market.
  static const String whatsAppNumber = '+234 807 972 2331';
  static const String whatsAppChat = 'https://wa.me/2348079722331';
  static const String whatsAppChat2 = 'https://wa.link/hf794t';

  // Official Website

  static const String officialWebsite = 'https://www.vinkol.ng';
  static const String contactUrl = 'https://www.vinkol.ng/contact';
  static const String privacyPolicy = 'https://www.vinkol.ng/privacy-policy';
  static const String termsAndCondition =
      'https://www.vinkol.ng/terms-and-conditions-customer';
  static const String about = 'https://www.vinkol.ng/about';

  static const String deleteAccount = 'https://www.vinkol.ng/delete-account';
  static const String productSupport = 'https://www.vinkol.ng/product-support';

  /// This app's page on the store it was installed from.
  ///
  /// Used both to force an update and to ask for a review, so the two can
  /// never drift apart. Empty on any other platform, which callers must treat
  /// as "there is nowhere to send them".
  static String storeListing() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=app.vinkol.user';
    }
    if (Platform.isIOS) {
      return 'https://apps.apple.com/ng/app/vinkol/id6751447117';
    }
    return '';
  }

  // Social Media
  static const String facebookPage =
      'https://www.facebook.com/YourFacebookPage';
  static const String instagramProfile =
      'https://www.instagram.com/vinkollogistics/?igsh=cHFveTlnY2Fuc3Mw&utm_source=qr#';
  static const String twitterProfile =
      'https://x.com/vinkolltd?s=21&t=fwDDLMrWPBCeOetcu1W7Gw';
  static const String linkedInProfile =
      'https://www.linkedin.com/in/vinkol-group-inc-8224441b6';
  // Add other social media links as needed, e.g., TikTok, YouTube, etc.
}
