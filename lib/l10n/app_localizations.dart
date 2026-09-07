import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// A list of this localizations delegate along with the default localizations delegates.  Returns a list of localizations delegates containing this delegate along with GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, and GlobalWidgetsLocalizations.delegate.  Additional delegates can be added by appending to this list in MaterialApp. This list does not have to be used at all if a custom list of delegates is preferred or required. static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[ delegate, GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate, ];  A list of this localizations delegate's supported locales. static const List<Locale> supportedLocales = <Locale>[ Locale('en'), Locale('fr') ];  No description provided for @commonWelcomeToVinkol.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vinkol'**
  String get commonWelcomeToVinkol;

  /// No description provided for @onboardingYourTrustedDeliveryPartnerFor.
  ///
  /// In en, this message translates to:
  /// **'Your trusted delivery partner for all your needs'**
  String get onboardingYourTrustedDeliveryPartnerFor;

  /// No description provided for @onboardingFastReliable.
  ///
  /// In en, this message translates to:
  /// **'Fast & Reliable'**
  String get onboardingFastReliable;

  /// No description provided for @onboardingGetYourItemsDeliveredQuickly.
  ///
  /// In en, this message translates to:
  /// **'Get your items delivered quickly and safely'**
  String get onboardingGetYourItemsDeliveredQuickly;

  /// No description provided for @onboardingTrackYourOrders.
  ///
  /// In en, this message translates to:
  /// **'Track Your Orders'**
  String get onboardingTrackYourOrders;

  /// No description provided for @onboardingRealTimeTrackingForAll.
  ///
  /// In en, this message translates to:
  /// **'Real-time tracking for all your deliveries'**
  String get onboardingRealTimeTrackingForAll;

  /// Verb. Skips the onboarding carousel.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @authEnterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP code'**
  String get authEnterOtpCode;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get authResendCode;

  /// Verb/adverb. Advances to the next step of a form.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get authNext;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login '**
  String get authLoginTitle;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailAddress;

  /// Placeholder shown in the email field. Not user-visible copy to translate.
  ///
  /// In en, this message translates to:
  /// **'sample@gmail.com'**
  String get authEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginAction;

  /// No description provided for @authCanTRememberYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Can\'t remember your password? '**
  String get authCanTRememberYourPassword;

  /// No description provided for @authResetIt.
  ///
  /// In en, this message translates to:
  /// **'Reset it. '**
  String get authResetIt;

  /// No description provided for @authPasswordResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password Reset Successfully'**
  String get authPasswordResetSuccessfully;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authBackToLogin;

  /// No description provided for @authCompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get authCompleteProfile;

  /// No description provided for @authCompleteDetailsToCompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete details to complete profile'**
  String get authCompleteDetailsToCompleteProfile;

  /// No description provided for @authFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get authFirstName;

  /// Placeholder shown in the first-name field. A sample given name; substitute one common in the target locale.
  ///
  /// In en, this message translates to:
  /// **'Sarah'**
  String get authFirstNameHint;

  /// No description provided for @authLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get authLastName;

  /// Placeholder shown in the last-name field. A sample family name; substitute one common in the target locale.
  ///
  /// In en, this message translates to:
  /// **'Osato'**
  String get authLastNameHint;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhoneNumber;

  /// Verb. Submits the profile form.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get authSubmit;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// No description provided for @authLetSResetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Let\'s reset your password quickly'**
  String get authLetSResetYourPassword;

  /// No description provided for @authEMailAddress.
  ///
  /// In en, this message translates to:
  /// **'E-mail Address'**
  String get authEMailAddress;

  /// Verb. Sends a password-reset email.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get authSend;

  /// No description provided for @authSetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get authSetNewPassword;

  /// No description provided for @authCreateNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get authCreateNewPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// Verb. Confirms a new password.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get authReset;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authCreateAnAccountWithFew.
  ///
  /// In en, this message translates to:
  /// **'Create an account with few steps'**
  String get authCreateAnAccountWithFew;

  /// No description provided for @authIAgreeToTheTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms & conditions'**
  String get authIAgreeToTheTerms;

  /// No description provided for @authHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? '**
  String get authHaveAnAccount;

  /// No description provided for @authChooseHowYouDLike.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to get started'**
  String get authChooseHowYouDLike;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get authContinueAsGuest;

  /// Separator between two sign-in options.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authByContinuingYouAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy'**
  String get authByContinuingYouAgreeTo;

  /// No description provided for @authVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get authVerifyEmail;

  /// Verb. Dismisses an error.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get authDismiss;

  /// Dismisses a dialog.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get authOk;

  /// Verb phrase. Retries a failed action.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// Dismisses a dialog.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get authOkay;

  /// Verb. Restarts the OTP flow.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get authRestart;

  /// Noun. The collection point of a delivery.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get bookingPickup;

  /// No description provided for @bookingNoBulkQuoteAvailable.
  ///
  /// In en, this message translates to:
  /// **'No bulk quote available.'**
  String get bookingNoBulkQuoteAvailable;

  /// No description provided for @bookingRouteDetails.
  ///
  /// In en, this message translates to:
  /// **'Route Details'**
  String get bookingRouteDetails;

  /// No description provided for @commonPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get commonPaymentMethod;

  /// No description provided for @commonSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get commonSelectPaymentMethod;

  /// No description provided for @bookingConfirmBulkBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Bulk Booking'**
  String get bookingConfirmBulkBooking;

  /// No description provided for @bookingSearchForAnAddress.
  ///
  /// In en, this message translates to:
  /// **'Search for an address'**
  String get bookingSearchForAnAddress;

  /// No description provided for @bookingSearchingLocations.
  ///
  /// In en, this message translates to:
  /// **'Searching locations...'**
  String get bookingSearchingLocations;

  /// No description provided for @bookingNoResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get bookingNoResultsFound;

  /// No description provided for @bookingTrySearchingWithADifferent.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different keyword or address'**
  String get bookingTrySearchingWithADifferent;

  /// No description provided for @bookingStartSearching.
  ///
  /// In en, this message translates to:
  /// **'Start searching'**
  String get bookingStartSearching;

  /// No description provided for @bookingTypeAnAddressOrLocation.
  ///
  /// In en, this message translates to:
  /// **'Type an address or location name to find places'**
  String get bookingTypeAnAddressOrLocation;

  /// No description provided for @bookingGoToCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Go to current location'**
  String get bookingGoToCurrentLocation;

  /// No description provided for @bookingSelectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get bookingSelectedLocation;

  /// No description provided for @bookingGettingAddress.
  ///
  /// In en, this message translates to:
  /// **'Getting address...'**
  String get bookingGettingAddress;

  /// No description provided for @bookingConfirmThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm This Location'**
  String get bookingConfirmThisLocation;

  /// No description provided for @bookingNoDeliveryOptionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No delivery options available.'**
  String get bookingNoDeliveryOptionsAvailable;

  /// No description provided for @bookingSelectDeliveryRequest.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Request'**
  String get bookingSelectDeliveryRequest;

  /// No description provided for @bookingPackageType.
  ///
  /// In en, this message translates to:
  /// **'Package Type'**
  String get bookingPackageType;

  /// No description provided for @bookingSelectItemType.
  ///
  /// In en, this message translates to:
  /// **'Select Item Type'**
  String get bookingSelectItemType;

  /// No description provided for @bookingAddRecipientDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Recipient Details'**
  String get bookingAddRecipientDetails;

  /// No description provided for @bookingRecipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient Name'**
  String get bookingRecipientName;

  /// No description provided for @bookingRecipientPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Recipient Phone Number'**
  String get bookingRecipientPhoneNumber;

  /// No description provided for @bookingPaymentSource.
  ///
  /// In en, this message translates to:
  /// **'Payment Source'**
  String get bookingPaymentSource;

  /// No description provided for @bookingPaySecurelyWithCard.
  ///
  /// In en, this message translates to:
  /// **'Pay securely with card'**
  String get bookingPaySecurelyWithCard;

  /// No description provided for @bookingConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get bookingConfirmBooking;

  /// No description provided for @bookingTwentyPercentOff.
  ///
  /// In en, this message translates to:
  /// **'20% off'**
  String get bookingTwentyPercentOff;

  /// No description provided for @bookingNoMultiOrderQuoteAvailable.
  ///
  /// In en, this message translates to:
  /// **'No multi-order quote available.'**
  String get bookingNoMultiOrderQuoteAvailable;

  /// No description provided for @bookingOrdersBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Orders Breakdown'**
  String get bookingOrdersBreakdown;

  /// Noun. The destination of a delivery.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get bookingDropOff;

  /// No description provided for @bookingConfirmMultiOrderBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Multi-Order Booking'**
  String get bookingConfirmMultiOrderBooking;

  /// Noun. The person sending a package.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get bookingSender;

  /// No description provided for @bookingPackageInfo.
  ///
  /// In en, this message translates to:
  /// **'Package Info'**
  String get bookingPackageInfo;

  /// No description provided for @bookingGeneralInformation.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get bookingGeneralInformation;

  /// No description provided for @bookingPickupDate.
  ///
  /// In en, this message translates to:
  /// **'Pickup Date'**
  String get bookingPickupDate;

  /// No description provided for @bookingPickupTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup Time'**
  String get bookingPickupTime;

  /// No description provided for @bookingEnterPackageName.
  ///
  /// In en, this message translates to:
  /// **'Enter package name'**
  String get bookingEnterPackageName;

  /// Noun. A person’s name field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get bookingName;

  /// Noun. A phone number field label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get commonPhone;

  /// No description provided for @bookingAddAnySpecialInstructionsOr.
  ///
  /// In en, this message translates to:
  /// **'Add any special instructions or notes...'**
  String get bookingAddAnySpecialInstructionsOr;

  /// No description provided for @bookingPackageDetails.
  ///
  /// In en, this message translates to:
  /// **'Package Details'**
  String get bookingPackageDetails;

  /// No description provided for @bookingTellUsAboutYourPackage.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your package'**
  String get bookingTellUsAboutYourPackage;

  /// No description provided for @bookingGetQuote.
  ///
  /// In en, this message translates to:
  /// **'Get Quote'**
  String get bookingGetQuote;

  /// No description provided for @bookingLastDelivery.
  ///
  /// In en, this message translates to:
  /// **'Last Delivery'**
  String get bookingLastDelivery;

  /// No description provided for @bookingSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get bookingSeeAll;

  /// No description provided for @bookingDropOffLocation.
  ///
  /// In en, this message translates to:
  /// **'Drop off location'**
  String get bookingDropOffLocation;

  /// Verb. Adds another drop-off stop.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get bookingAdd;

  /// No description provided for @bookingMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get bookingMyLocation;

  /// No description provided for @bookingDefaultLocation.
  ///
  /// In en, this message translates to:
  /// **'Default Location'**
  String get bookingDefaultLocation;

  /// No description provided for @bookingRetryLocation.
  ///
  /// In en, this message translates to:
  /// **'Retry Location'**
  String get bookingRetryLocation;

  /// The rewards screen title, and the section heading on home.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardTitle;

  /// Trailing action on the home section heading. Opens the rewards screen.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get rewardDetails;

  /// No description provided for @rewardYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get rewardYourProgress;

  /// No description provided for @rewardHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get rewardHowItWorks;

  /// Running count beside a section heading: "2 of 3".
  ///
  /// In en, this message translates to:
  /// **'{done} of {target}'**
  String rewardCountOfTarget(int done, int target);

  /// Eyebrow on the reward card while the reward is still being earned. Uppercased by the widget.
  ///
  /// In en, this message translates to:
  /// **'Your next reward'**
  String get rewardNextReward;

  /// Eyebrow on the reward card once the discount is unlocked. Uppercased by the widget.
  ///
  /// In en, this message translates to:
  /// **'Reward earned'**
  String get rewardEarnedEyebrow;

  /// Pill on the earned reward card. Must stay short enough for a pill.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get rewardReady;

  /// The prize, as a pill. Keep it short; French uses the discount form -20 %.
  ///
  /// In en, this message translates to:
  /// **'{percent}% off'**
  String rewardPercentOffShort(int percent);

  /// The prize as a large figure. French puts a space before the percent sign.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String rewardPercentNumber(int percent);

  /// The unit beside the large percentage figure: "20% off".
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get rewardOff;

  /// Status chip on the reward card while the reward is still being earned. Must stay short enough for a pill.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get rewardEarning;

  /// Eyebrow over the delivery count at the start of the reward rail. One or two words.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get rewardStopsLabel;

  /// Eyebrow over the prize at the end of the reward rail. One or two words.
  ///
  /// In en, this message translates to:
  /// **'Your reward'**
  String get rewardGoalLabel;

  /// Eyebrow on the compact reward card while the reward is being earned. One short word — it shares a line with the count.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get rewardShortLabel;

  /// Label under a completed stop on the reward route.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rewardStopDone;

  /// Label under the stop the user is on.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get rewardStopNext;

  /// Label under the destination while it is still locked.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get rewardStopGoal;

  /// Label under the destination once the reward is earned.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get rewardStopYours;

  /// Headline on the in-progress reward card. The zero case covers a counted delivery whose reward the server has not granted yet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Your reward is on its way} =1{One more delivery unlocks it} other{{count} more deliveries unlock it}}'**
  String rewardRemaining(int count);

  /// No description provided for @rewardStoreOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'Store orders count too.'**
  String get rewardStoreOrdersCount;

  /// No description provided for @rewardAppliedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Applied to your next booking automatically.'**
  String get rewardAppliedAutomatically;

  /// No description provided for @rewardReadyHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your {percent}% off is ready'**
  String rewardReadyHeadline(int percent);

  /// No description provided for @rewardUseOnBooking.
  ///
  /// In en, this message translates to:
  /// **'Use it on a booking'**
  String get rewardUseOnBooking;

  /// Label under a stop not reached yet.
  ///
  /// In en, this message translates to:
  /// **'To go'**
  String get rewardStopToGo;

  /// Screen-reader label for the whole reward route. The route is drawn, so this is the only way it is announced.
  ///
  /// In en, this message translates to:
  /// **'{done} of {target} deliveries done'**
  String rewardProgressSemantics(int done, int target);

  /// Screen-reader label for the reward route once it is complete.
  ///
  /// In en, this message translates to:
  /// **'All deliveries done. Your reward is ready.'**
  String get rewardEarnedSemantics;

  /// No description provided for @rewardHowDeliveriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} deliveries'**
  String rewardHowDeliveriesTitle(int count);

  /// No description provided for @rewardHowDeliveriesBody.
  ///
  /// In en, this message translates to:
  /// **'Courier bookings and store orders both count.'**
  String get rewardHowDeliveriesBody;

  /// No description provided for @rewardHowUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock {percent}% off'**
  String rewardHowUnlockTitle(int percent);

  /// No description provided for @rewardHowUnlockBody.
  ///
  /// In en, this message translates to:
  /// **'It applies to your next booking automatically.'**
  String get rewardHowUnlockBody;

  /// No description provided for @rewardHowAgainTitle.
  ///
  /// In en, this message translates to:
  /// **'Then it starts again'**
  String get rewardHowAgainTitle;

  /// No description provided for @rewardHowAgainBody.
  ///
  /// In en, this message translates to:
  /// **'The count restarts once your reward is used.'**
  String get rewardHowAgainBody;

  /// No description provided for @rewardSignedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Rewards need an account'**
  String get rewardSignedOutTitle;

  /// No description provided for @rewardSignedOutBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to count your deliveries toward {percent}% off.'**
  String rewardSignedOutBody(int percent);

  /// No description provided for @bookingBookYourRide.
  ///
  /// In en, this message translates to:
  /// **'Book Your Ride'**
  String get bookingBookYourRide;

  /// No description provided for @bookingSetYourStopsBelow.
  ///
  /// In en, this message translates to:
  /// **'Set your stops below'**
  String get bookingSetYourStopsBelow;

  /// No description provided for @bookingPleaseSelectAllStopLocations.
  ///
  /// In en, this message translates to:
  /// **'Please select all stop locations.'**
  String get bookingPleaseSelectAllStopLocations;

  /// No description provided for @bookingFindRider.
  ///
  /// In en, this message translates to:
  /// **'Find Rider'**
  String get bookingFindRider;

  /// No description provided for @bookingSearchForAPlace.
  ///
  /// In en, this message translates to:
  /// **'Search for a place'**
  String get bookingSearchForAPlace;

  /// No description provided for @bookingTypeAnAddressOrLandmark.
  ///
  /// In en, this message translates to:
  /// **'Type an address or landmark'**
  String get bookingTypeAnAddressOrLandmark;

  /// No description provided for @bookingPickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get bookingPickOnMap;

  /// No description provided for @bookingDropAPinAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Drop a pin anywhere'**
  String get bookingDropAPinAnywhere;

  /// No description provided for @storeShoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get storeShoppingCart;

  /// Verb. Button that empties the shopping cart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get storeClearCart;

  /// No description provided for @storeAreYouSureYouWant.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items?'**
  String get storeAreYouSureYouWant;

  /// Verb. Dismisses a confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get storeCancel;

  /// Verb. Confirms emptying the shopping cart.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get storeClear;

  /// No description provided for @storeYourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get storeYourCartIsEmpty;

  /// No description provided for @storeAddItemsToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add items to get started'**
  String get storeAddItemsToGetStarted;

  /// No description provided for @storeDeliveryOptions.
  ///
  /// In en, this message translates to:
  /// **'Delivery Options'**
  String get storeDeliveryOptions;

  /// No description provided for @storeNoDeliveryOptionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No delivery options available'**
  String get storeNoDeliveryOptionsAvailable;

  /// No description provided for @storeDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get storeDeliveryFee;

  /// Noun. The order total on the cart summary.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get storeTotal;

  /// No description provided for @storeProceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get storeProceedToCheckout;

  /// Adjective, describing a product that cannot be ordered.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get storeUnavailable;

  /// Noun. Section heading for a product description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get storeDescription;

  /// No description provided for @storeStoreInformation.
  ///
  /// In en, this message translates to:
  /// **'Store Information'**
  String get storeStoreInformation;

  /// Noun. A postal address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get storeAddress;

  /// The administrative region of a store address. Note: this label should come from the market layer (Market.regionLabel) — "State" in Nigeria, "Province" in Canada.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get storeState;

  /// No description provided for @storeAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add To Cart'**
  String get storeAddToCart;

  /// No description provided for @storeNoStoreSelected.
  ///
  /// In en, this message translates to:
  /// **'No Store Selected'**
  String get storeNoStoreSelected;

  /// No description provided for @storePleaseSelectAStoreTo.
  ///
  /// In en, this message translates to:
  /// **'Please select a store to view\navailable products'**
  String get storePleaseSelectAStoreTo;

  /// No description provided for @storeGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get storeGoBack;

  /// No description provided for @storeSearchForProducts.
  ///
  /// In en, this message translates to:
  /// **'Search for products...'**
  String get storeSearchForProducts;

  /// No description provided for @storeNoProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No Products Found'**
  String get storeNoProductsFound;

  /// No description provided for @storeNoProductsMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match '**
  String get storeNoProductsMatch;

  /// No description provided for @storeTryADifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'\nTry a different search term'**
  String get storeTryADifferentSearchTerm;

  /// Verb. Clears the product search box.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get storeClearSearch;

  /// No description provided for @storeAvailableProducts.
  ///
  /// In en, this message translates to:
  /// **'Available Products'**
  String get storeAvailableProducts;

  /// No description provided for @storeLoadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Loading products...'**
  String get storeLoadingProducts;

  /// No description provided for @storePleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get storePleaseWait;

  /// No description provided for @storeNoProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Products Available'**
  String get storeNoProductsAvailable;

  /// No description provided for @storeThisStoreDoesnTHave.
  ///
  /// In en, this message translates to:
  /// **'This store doesn\'t have any products\navailable at the moment'**
  String get storeThisStoreDoesnTHave;

  /// Verb. Reloads the product list.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get storeRefresh;

  /// No description provided for @storeFailedToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Products'**
  String get storeFailedToLoadProducts;

  /// No description provided for @storeUnableToFetchProductsFrom.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch products from the store.\nPlease check your connection and try again.'**
  String get storeUnableToFetchProductsFrom;

  /// No description provided for @storeLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get storeLoadingMore;

  /// No description provided for @storeViewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get storeViewCart;

  /// No description provided for @storeStoresAroundYou.
  ///
  /// In en, this message translates to:
  /// **'Stores Around You'**
  String get storeStoresAroundYou;

  /// No description provided for @storeFindNearbyStoresAndShops.
  ///
  /// In en, this message translates to:
  /// **'Find nearby stores and shops'**
  String get storeFindNearbyStoresAndShops;

  /// No description provided for @storeSearchForStoresShopsMarkets.
  ///
  /// In en, this message translates to:
  /// **'Search for stores, shops, markets...'**
  String get storeSearchForStoresShopsMarkets;

  /// No description provided for @storeFindingStoresNearYou.
  ///
  /// In en, this message translates to:
  /// **'Finding stores near you...'**
  String get storeFindingStoresNearYou;

  /// No description provided for @storeNoStoresFound.
  ///
  /// In en, this message translates to:
  /// **'No stores found'**
  String get storeNoStoresFound;

  /// No description provided for @storeTryAdjustingYourSearchOr.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or check back later'**
  String get storeTryAdjustingYourSearchOr;

  /// No description provided for @storeConnectionProblem.
  ///
  /// In en, this message translates to:
  /// **'Connection Problem'**
  String get storeConnectionProblem;

  /// No description provided for @storeUnableToLoadStoresPlease.
  ///
  /// In en, this message translates to:
  /// **'Unable to load stores. Please check your\ninternet connection and try again.'**
  String get storeUnableToLoadStoresPlease;

  /// No description provided for @storeShopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by Category'**
  String get storeShopByCategory;

  /// No description provided for @storeBrowseStoresByCategory.
  ///
  /// In en, this message translates to:
  /// **'Browse stores by category'**
  String get storeBrowseStoresByCategory;

  /// No description provided for @storeFailedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories'**
  String get storeFailedToLoadCategories;

  /// Verb. Retries a failed request.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get storeRetry;

  /// No description provided for @onboardingSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send anything,\nanywhere.'**
  String get onboardingSendTitle;

  /// No description provided for @onboardingSendBody.
  ///
  /// In en, this message translates to:
  /// **'Book a rider in under a minute. Bike, car or van — priced before you commit.'**
  String get onboardingSendBody;

  /// No description provided for @onboardingTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Know where\nit stands.'**
  String get onboardingTrackTitle;

  /// No description provided for @onboardingTrackBody.
  ///
  /// In en, this message translates to:
  /// **'A named rider you can call, a tracking ID, and every status change as it happens.'**
  String get onboardingTrackBody;

  /// No description provided for @onboardingTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'Covered if\nit goes wrong.'**
  String get onboardingTrustTitle;

  /// No description provided for @onboardingTrustBodyCovered.
  ///
  /// In en, this message translates to:
  /// **'Vinkol carries retention coverage of up to {amount} on a verified loss, and support mediates every claim.'**
  String onboardingTrustBodyCovered(String amount);

  /// No description provided for @onboardingTrustBodyPlain.
  ///
  /// In en, this message translates to:
  /// **'If a delivery goes wrong, support mediates the claim with the delivery partner on your behalf.'**
  String get onboardingTrustBodyPlain;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStepOf(int step, int total);

  /// No description provided for @authChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vinkol'**
  String get authChoiceTitle;

  /// No description provided for @authChoiceBody.
  ///
  /// In en, this message translates to:
  /// **'Join Vinkol today and be able to send package anyday anytime also shop from closest store and get it delivered to your door steps'**
  String get authChoiceBody;

  /// No description provided for @authChoiceHaveOne.
  ///
  /// In en, this message translates to:
  /// **'I already have one'**
  String get authChoiceHaveOne;

  /// No description provided for @authLoginHeading.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginHeading;

  /// No description provided for @authLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Use the email address on your account.'**
  String get authLoginBody;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Login checkbox. Saves the email address on this device so the field comes back filled next time.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// No description provided for @authNewHere.
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get authNewHere;

  /// No description provided for @authSignupHeading.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authSignupHeading;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Emeka Obi'**
  String get authFullNameHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordHint;

  /// No description provided for @authPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'Use 8 or more characters with a number.'**
  String get authPasswordHelper;

  /// No description provided for @authAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy.'**
  String get authAcceptTerms;

  /// No description provided for @authContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinueAction;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authOtpTitle;

  /// No description provided for @authOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}.'**
  String authOtpSentTo(String email);

  /// No description provided for @authOtpDidntGet.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? '**
  String get authOtpDidntGet;

  /// No description provided for @authOtpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authOtpResend;

  /// No description provided for @authOtpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authOtpResendIn(int seconds);

  /// No description provided for @authOtpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authOtpVerify;

  /// No description provided for @authOtpIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter all 6 digits to continue.'**
  String get authOtpIncomplete;

  /// No description provided for @authResetRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetRequestTitle;

  /// No description provided for @authResetRequestBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us the email on your account and we\'ll send a code to reset it.'**
  String get authResetRequestBody;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPasswordTitle;

  /// No description provided for @authNewPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Choose something you haven\'t used here before.'**
  String get authNewPasswordBody;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat it'**
  String get authConfirmPasswordHint;

  /// No description provided for @authSavePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get authSavePassword;

  /// No description provided for @authPasswordSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Password saved'**
  String get authPasswordSavedTitle;

  /// No description provided for @authPasswordSavedBody.
  ///
  /// In en, this message translates to:
  /// **'You can log in with your new password now.'**
  String get authPasswordSavedBody;

  /// No description provided for @marketSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get marketSelectTitle;

  /// No description provided for @marketSelectBody.
  ///
  /// In en, this message translates to:
  /// **'Select the country you are sending from. You can change it later in Settings.'**
  String get marketSelectBody;

  /// No description provided for @marketAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available markets'**
  String get marketAvailable;

  /// No description provided for @marketNoSeparateTax.
  ///
  /// In en, this message translates to:
  /// **'no separate tax'**
  String get marketNoSeparateTax;

  /// No description provided for @marketTaxShown.
  ///
  /// In en, this message translates to:
  /// **'{label} shown'**
  String marketTaxShown(String label);

  /// No description provided for @marketSameRateNationwide.
  ///
  /// In en, this message translates to:
  /// **'same rate nationwide'**
  String get marketSameRateNationwide;

  /// No description provided for @marketSetsYourTaxRate.
  ///
  /// In en, this message translates to:
  /// **'sets your tax rate'**
  String get marketSetsYourTaxRate;

  /// No description provided for @marketWhatChanges.
  ///
  /// In en, this message translates to:
  /// **'What changes'**
  String get marketWhatChanges;

  /// No description provided for @marketCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get marketCurrency;

  /// No description provided for @marketDecimals.
  ///
  /// In en, this message translates to:
  /// **'Decimals'**
  String get marketDecimals;

  /// No description provided for @marketTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get marketTax;

  /// No description provided for @marketNotShownSeparately.
  ///
  /// In en, this message translates to:
  /// **'Not shown separately'**
  String get marketNotShownSeparately;

  /// No description provided for @marketPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get marketPhone;

  /// No description provided for @marketLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get marketLanguages;

  /// No description provided for @marketPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get marketPayment;

  /// No description provided for @marketSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get marketSupport;

  /// No description provided for @marketAddressFieldsInOrder.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS FIELDS, IN ORDER'**
  String get marketAddressFieldsInOrder;

  /// No description provided for @marketMoreFollow.
  ///
  /// In en, this message translates to:
  /// **'More markets follow the same layer — a new country is configuration, not a new build.'**
  String get marketMoreFollow;

  /// No description provided for @marketContinueIn.
  ///
  /// In en, this message translates to:
  /// **'Continue in {country}'**
  String marketContinueIn(String country);

  /// No description provided for @marketTaxExplainer.
  ///
  /// In en, this message translates to:
  /// **'{region} charges {label} at {rate}. Rates differ by {regionLabel}, so tax cannot be one number per country.'**
  String marketTaxExplainer(
      String region, String label, String rate, String regionLabel);

  /// No description provided for @marketCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get marketCountry;

  /// No description provided for @bookingWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance {amount}'**
  String bookingWalletBalance(String amount);

  /// No description provided for @bookingWalletNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough in your wallet'**
  String get bookingWalletNotEnough;

  /// No description provided for @bookingCouldNotBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking failed'**
  String get bookingCouldNotBookTitle;

  /// No description provided for @bookingBatchBookedTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch booked'**
  String get bookingBatchBookedTitle;

  /// No description provided for @bookingBatchBookedBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One delivery is booked and matched to a rider.} other{{count} deliveries are booked, each matched to its own rider.}}'**
  String bookingBatchBookedBody(int count);

  /// No description provided for @bookingMissingRideDetails.
  ///
  /// In en, this message translates to:
  /// **'Some of the trip details are missing. Go back and check your stops.'**
  String get bookingMissingRideDetails;

  /// No description provided for @bookingNoDeliveryOptionsBody.
  ///
  /// In en, this message translates to:
  /// **'No rider can serve this route right now. Changing a stop usually fixes it.'**
  String get bookingNoDeliveryOptionsBody;

  /// No description provided for @bookingChangeTheStops.
  ///
  /// In en, this message translates to:
  /// **'Change the stops'**
  String get bookingChangeTheStops;

  /// No description provided for @bookingStopNumber.
  ///
  /// In en, this message translates to:
  /// **'Stop {number}'**
  String bookingStopNumber(int number);

  /// No description provided for @bookingDeliveryPickup.
  ///
  /// In en, this message translates to:
  /// **'Delivery {number} · pickup'**
  String bookingDeliveryPickup(int number);

  /// No description provided for @bookingDeliveryDropOff.
  ///
  /// In en, this message translates to:
  /// **'Delivery {number} · drop-off'**
  String bookingDeliveryDropOff(int number);

  /// No description provided for @bookingMultiDrop.
  ///
  /// In en, this message translates to:
  /// **'Multi-drop'**
  String get bookingMultiDrop;

  /// No description provided for @bookingBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get bookingBatch;

  /// No description provided for @bookingMultiDropHeadline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pickup · 1 drop-off} other{1 pickup · {count} drop-offs}}'**
  String bookingMultiDropHeadline(int count);

  /// No description provided for @bookingMultiDropBody.
  ///
  /// In en, this message translates to:
  /// **'One rider, one route. Stops run in the order below, and that order sets the price.'**
  String get bookingMultiDropBody;

  /// No description provided for @bookingBatchHeadline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 delivery} other{{count} separate deliveries}}'**
  String bookingBatchHeadline(int count);

  /// No description provided for @bookingBatchBody.
  ///
  /// In en, this message translates to:
  /// **'Each one gets its own rider and its own price. One failing does not affect the others.'**
  String get bookingBatchBody;

  /// No description provided for @bookingDropOffs.
  ///
  /// In en, this message translates to:
  /// **'Drop-offs'**
  String get bookingDropOffs;

  /// No description provided for @bookingDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get bookingDeliveries;

  /// No description provided for @bookingOr.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get bookingOr;

  /// No description provided for @bookingAddADropOff.
  ///
  /// In en, this message translates to:
  /// **'Add a drop-off'**
  String get bookingAddADropOff;

  /// No description provided for @bookingAddADelivery.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery'**
  String get bookingAddADelivery;

  /// No description provided for @bookingSwitchToBatchTitle.
  ///
  /// In en, this message translates to:
  /// **'These come from different places'**
  String get bookingSwitchToBatchTitle;

  /// No description provided for @bookingSwitchToBatchMeta.
  ///
  /// In en, this message translates to:
  /// **'Switch to Batch — separate pickups, separate riders'**
  String get bookingSwitchToBatchMeta;

  /// No description provided for @bookingSwitchToMultiDropTitle.
  ///
  /// In en, this message translates to:
  /// **'These all leave from one place'**
  String get bookingSwitchToMultiDropTitle;

  /// No description provided for @bookingSwitchToMultiDropMeta.
  ///
  /// In en, this message translates to:
  /// **'Switch to Multi-drop — one rider, cheaper per stop'**
  String get bookingSwitchToMultiDropMeta;

  /// No description provided for @bookingGetQuotes.
  ///
  /// In en, this message translates to:
  /// **'Get quotes'**
  String get bookingGetQuotes;

  /// No description provided for @bookingDropOffCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drop-off} other{{count} drop-offs}}'**
  String bookingDropOffCount(int count);

  /// No description provided for @bookingDeliveryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 delivery} other{{count} deliveries}}'**
  String bookingDeliveryCount(int count);

  /// No description provided for @bookingStopsStillNeedDetails.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop still needs details} other{{count} stops still need details}}'**
  String bookingStopsStillNeedDetails(int count);

  /// No description provided for @bookingDeliveriesStillNeedDetails.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 delivery is incomplete} other{{count} deliveries are incomplete}}'**
  String bookingDeliveriesStillNeedDetails(int count);

  /// No description provided for @bookingDeliveryNumber.
  ///
  /// In en, this message translates to:
  /// **'Delivery {number}'**
  String bookingDeliveryNumber(int number);

  /// No description provided for @bookingWhereAreWeCollectingFrom.
  ///
  /// In en, this message translates to:
  /// **'Where are we collecting from?'**
  String get bookingWhereAreWeCollectingFrom;

  /// No description provided for @bookingWhereIsItGoing.
  ///
  /// In en, this message translates to:
  /// **'Where is it going?'**
  String get bookingWhereIsItGoing;

  /// No description provided for @bookingCollectEverythingHere.
  ///
  /// In en, this message translates to:
  /// **'Collect everything here'**
  String get bookingCollectEverythingHere;

  /// No description provided for @bookingAddRecipientAndPackage.
  ///
  /// In en, this message translates to:
  /// **'Add a recipient and a package'**
  String get bookingAddRecipientAndPackage;

  /// No description provided for @bookingRemoveStop.
  ///
  /// In en, this message translates to:
  /// **'Remove this stop'**
  String get bookingRemoveStop;

  /// No description provided for @bookingRemoveDelivery.
  ///
  /// In en, this message translates to:
  /// **'Remove this delivery'**
  String get bookingRemoveDelivery;

  /// No description provided for @bookingReorderStops.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get bookingReorderStops;

  /// No description provided for @bookingWhatIsInThePackage.
  ///
  /// In en, this message translates to:
  /// **'What is in the package?'**
  String get bookingWhatIsInThePackage;

  /// No description provided for @bookingNoteForTheRider.
  ///
  /// In en, this message translates to:
  /// **'Note for the rider'**
  String get bookingNoteForTheRider;

  /// No description provided for @bookingNoteForTheRiderHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional. A gate code, a floor, a landmark.'**
  String get bookingNoteForTheRiderHelper;

  /// No description provided for @bookingSaveStop.
  ///
  /// In en, this message translates to:
  /// **'Save this stop'**
  String get bookingSaveStop;

  /// No description provided for @bookingRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get bookingRoute;

  /// No description provided for @bookingInThisOrder.
  ///
  /// In en, this message translates to:
  /// **'In this order'**
  String get bookingInThisOrder;

  /// No description provided for @bookingPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get bookingPrice;

  /// No description provided for @bookingStops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get bookingStops;

  /// No description provided for @bookingDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get bookingDistance;

  /// No description provided for @bookingRiders.
  ///
  /// In en, this message translates to:
  /// **'Riders'**
  String get bookingRiders;

  /// No description provided for @bookingRider.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get bookingRider;

  /// No description provided for @bookingTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bookingTotal;

  /// No description provided for @bookingSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get bookingSubtotal;

  /// No description provided for @bookingCollectAll.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Pickup · collect 1 parcel} other{Pickup · collect all {count}}}'**
  String bookingCollectAll(int count);

  /// No description provided for @bookingQuotedAsOneRoute.
  ///
  /// In en, this message translates to:
  /// **'Quoted as one route. Reordering the stops changes this price.'**
  String get bookingQuotedAsOneRoute;

  /// No description provided for @bookingPricedSeparately.
  ///
  /// In en, this message translates to:
  /// **'Priced separately'**
  String get bookingPricedSeparately;

  /// No description provided for @bookingEachTrackedSeparately.
  ///
  /// In en, this message translates to:
  /// **'Each delivery is matched to its own rider and tracked separately.'**
  String get bookingEachTrackedSeparately;

  /// No description provided for @bookingReviewAndPay.
  ///
  /// In en, this message translates to:
  /// **'Review and pay'**
  String get bookingReviewAndPay;

  /// No description provided for @bookingOneDropOff.
  ///
  /// In en, this message translates to:
  /// **'One drop-off'**
  String get bookingOneDropOff;

  /// No description provided for @storeShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get storeShop;

  /// No description provided for @storeStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get storeStores;

  /// No description provided for @storeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get storeAll;

  /// No description provided for @storeOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get storeOpenNow;

  /// No description provided for @storeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get storeOpen;

  /// No description provided for @storeClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get storeClosed;

  /// No description provided for @storeItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get storeItems;

  /// No description provided for @storeMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get storeMenu;

  /// No description provided for @storeQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get storeQuantity;

  /// No description provided for @storePayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get storePayment;

  /// No description provided for @storeSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get storeSubtotal;

  /// No description provided for @storeChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get storeChange;

  /// No description provided for @storeDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get storeDirections;

  /// No description provided for @storeSoldBy.
  ///
  /// In en, this message translates to:
  /// **'Sold by'**
  String get storeSoldBy;

  /// No description provided for @storeDeliveringTo.
  ///
  /// In en, this message translates to:
  /// **'Delivering to'**
  String get storeDeliveringTo;

  /// No description provided for @storePlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get storePlaceOrder;

  /// No description provided for @storeBrowseStores.
  ///
  /// In en, this message translates to:
  /// **'Browse stores'**
  String get storeBrowseStores;

  /// No description provided for @storeShowAllStores.
  ///
  /// In en, this message translates to:
  /// **'Show all stores'**
  String get storeShowAllStores;

  /// No description provided for @storeClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear the filters'**
  String get storeClearFilters;

  /// No description provided for @storeThisStore.
  ///
  /// In en, this message translates to:
  /// **'This store'**
  String get storeThisStore;

  /// No description provided for @storeOneStorePerOrder.
  ///
  /// In en, this message translates to:
  /// **'One store per order. Items from another store start a new cart.'**
  String get storeOneStorePerOrder;

  /// No description provided for @storeCollectedFromHere.
  ///
  /// In en, this message translates to:
  /// **'Collected from here'**
  String get storeCollectedFromHere;

  /// No description provided for @storeVinkolRider.
  ///
  /// In en, this message translates to:
  /// **'Vinkol rider'**
  String get storeVinkolRider;

  /// No description provided for @storePartnerCourier.
  ///
  /// In en, this message translates to:
  /// **'Partner courier'**
  String get storePartnerCourier;

  /// No description provided for @storeCarriedByVinkol.
  ///
  /// In en, this message translates to:
  /// **'Carried by a Vinkol rider'**
  String get storeCarriedByVinkol;

  /// No description provided for @storeCarriedByPartner.
  ///
  /// In en, this message translates to:
  /// **'Carried by a partner courier'**
  String get storeCarriedByPartner;

  /// No description provided for @storeNotQuotedYet.
  ///
  /// In en, this message translates to:
  /// **'Not quoted yet'**
  String get storeNotQuotedYet;

  /// No description provided for @storeAddDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery address'**
  String get storeAddDeliveryAddress;

  /// No description provided for @storeNeededToQuoteDelivery.
  ///
  /// In en, this message translates to:
  /// **'Needed before we can quote delivery'**
  String get storeNeededToQuoteDelivery;

  /// No description provided for @storeSetOnThisOrder.
  ///
  /// In en, this message translates to:
  /// **'Set on this order'**
  String get storeSetOnThisOrder;

  /// No description provided for @storeAddAnAddressToContinue.
  ///
  /// In en, this message translates to:
  /// **'Add an address to continue'**
  String get storeAddAnAddressToContinue;

  /// No description provided for @storeChooseADeliveryOption.
  ///
  /// In en, this message translates to:
  /// **'Choose a delivery option'**
  String get storeChooseADeliveryOption;

  /// No description provided for @storeAddAnAddressToSeeOptions.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery address and we will quote the options.'**
  String get storeAddAnAddressToSeeOptions;

  /// No description provided for @storeCouldNotGetDeliveryOptions.
  ///
  /// In en, this message translates to:
  /// **'We could not get delivery options for this address.'**
  String get storeCouldNotGetDeliveryOptions;

  /// No description provided for @storeCouldNotPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'The order could not be placed. Nothing has been charged.'**
  String get storeCouldNotPlaceOrder;

  /// No description provided for @storeCannotDetermineStore.
  ///
  /// In en, this message translates to:
  /// **'We could not tell which store this cart belongs to.'**
  String get storeCannotDetermineStore;

  /// No description provided for @storeCouldNotLoadStores.
  ///
  /// In en, this message translates to:
  /// **'Stores did not load'**
  String get storeCouldNotLoadStores;

  /// No description provided for @storeCouldNotLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'This menu did not load'**
  String get storeCouldNotLoadProducts;

  /// No description provided for @storeSearchStores.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get storeSearchStores;

  /// No description provided for @storeSearchStoresHint.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeSearchStoresHint;

  /// No description provided for @storeSearchThisStore.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get storeSearchThisStore;

  /// No description provided for @storeSearchThisStoreHint.
  ///
  /// In en, this message translates to:
  /// **'Search this menu'**
  String get storeSearchThisStoreHint;

  /// No description provided for @storeNoStoresHere.
  ///
  /// In en, this message translates to:
  /// **'No stores here yet'**
  String get storeNoStoresHere;

  /// No description provided for @storeNoStoresHereBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is listed in this category for your area. Another category may have what you want.'**
  String get storeNoStoresHereBody;

  /// No description provided for @storeNothingOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Nothing open right now'**
  String get storeNothingOpenNow;

  /// No description provided for @storeNothingOpenNowBody.
  ///
  /// In en, this message translates to:
  /// **'Every store in this category is closed. You can still browse a closed store\'s menu.'**
  String get storeNothingOpenNowBody;

  /// No description provided for @storeNoCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get storeNoCategoriesYet;

  /// No description provided for @storeNoCategoriesYetBody.
  ///
  /// In en, this message translates to:
  /// **'Shopping is not set up for your area yet.'**
  String get storeNoCategoriesYetBody;

  /// No description provided for @storeNoMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get storeNoMatches;

  /// No description provided for @storeNoMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'No item on this menu matches what you typed.'**
  String get storeNoMatchesBody;

  /// No description provided for @storeNothingForSale.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the menu'**
  String get storeNothingForSale;

  /// No description provided for @storeNothingForSaleBody.
  ///
  /// In en, this message translates to:
  /// **'This store has not listed anything yet.'**
  String get storeNothingForSaleBody;

  /// No description provided for @storeNoStoreSelectedBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a store first and its menu will open here.'**
  String get storeNoStoreSelectedBody;

  /// No description provided for @storeHowMany.
  ///
  /// In en, this message translates to:
  /// **'How many?'**
  String get storeHowMany;

  /// No description provided for @storeInYourCart.
  ///
  /// In en, this message translates to:
  /// **'In your cart'**
  String get storeInYourCart;

  /// No description provided for @storeFewer.
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get storeFewer;

  /// No description provided for @storeMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get storeMore;

  /// No description provided for @storeRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove this item'**
  String get storeRemoveItem;

  /// No description provided for @storeEachPrice.
  ///
  /// In en, this message translates to:
  /// **'{amount} each'**
  String storeEachPrice(String amount);

  /// No description provided for @storeInCart.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Cart is empty} =1{1 item in cart} other{{count} items in cart}}'**
  String storeInCart(int count);

  /// No description provided for @storeStoreCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 store} other{{count} stores}}'**
  String storeStoreCount(int count);

  /// No description provided for @storeTimesPrice.
  ///
  /// In en, this message translates to:
  /// **'{quantity} × {amount}'**
  String storeTimesPrice(int quantity, String amount);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusWithRider.
  ///
  /// In en, this message translates to:
  /// **'With rider'**
  String get statusWithRider;

  /// No description provided for @statusWithShopper.
  ///
  /// In en, this message translates to:
  /// **'With shopper'**
  String get statusWithShopper;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusUnattended.
  ///
  /// In en, this message translates to:
  /// **'Unattended'**
  String get statusUnattended;

  /// No description provided for @deliveryRecords.
  ///
  /// In en, this message translates to:
  /// **'Delivery records'**
  String get deliveryRecords;

  /// No description provided for @deliveryDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveryDeliveries;

  /// No description provided for @deliveryStoreOrders.
  ///
  /// In en, this message translates to:
  /// **'Store orders'**
  String get deliveryStoreOrders;

  /// No description provided for @deliveryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get deliveryAll;

  /// No description provided for @deliveryEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get deliveryEarlier;

  /// No description provided for @deliveryAllOrders.
  ///
  /// In en, this message translates to:
  /// **'All orders'**
  String get deliveryAllOrders;

  /// No description provided for @deliveryDownloadReport.
  ///
  /// In en, this message translates to:
  /// **'Download a report'**
  String get deliveryDownloadReport;

  /// No description provided for @deliveryShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get deliveryShowAll;

  /// No description provided for @deliveryOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get deliveryOrder;

  /// No description provided for @deliveryTrackingId.
  ///
  /// In en, this message translates to:
  /// **'Tracking ID'**
  String get deliveryTrackingId;

  /// No description provided for @deliveryCopyTrackingId.
  ///
  /// In en, this message translates to:
  /// **'Copy the tracking ID'**
  String get deliveryCopyTrackingId;

  /// No description provided for @deliveryInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get deliveryInProgress;

  /// No description provided for @deliveryFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get deliveryFrom;

  /// No description provided for @deliveryFromStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get deliveryFromStore;

  /// No description provided for @deliveryTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get deliveryTo;

  /// No description provided for @deliveryPackageDetail.
  ///
  /// In en, this message translates to:
  /// **'Package detail'**
  String get deliveryPackageDetail;

  /// No description provided for @deliveryStoreOrder.
  ///
  /// In en, this message translates to:
  /// **'Store order'**
  String get deliveryStoreOrder;

  /// No description provided for @deliveryService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get deliveryService;

  /// No description provided for @deliveryVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get deliveryVehicle;

  /// No description provided for @deliveryContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get deliveryContents;

  /// No description provided for @deliveryPlaced.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get deliveryPlaced;

  /// No description provided for @deliveryStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get deliveryStore;

  /// No description provided for @deliveryPickupFrom.
  ///
  /// In en, this message translates to:
  /// **'Pickup from'**
  String get deliveryPickupFrom;

  /// No description provided for @deliveryDeliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliveryDeliverTo;

  /// No description provided for @deliveryRider.
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get deliveryRider;

  /// No description provided for @deliveryShopper.
  ///
  /// In en, this message translates to:
  /// **'Shopper'**
  String get deliveryShopper;

  /// No description provided for @deliveryYourRider.
  ///
  /// In en, this message translates to:
  /// **'Your rider'**
  String get deliveryYourRider;

  /// No description provided for @deliveryCallRider.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get deliveryCallRider;

  /// No description provided for @deliveryNotAssignedYet.
  ///
  /// In en, this message translates to:
  /// **'Not assigned yet'**
  String get deliveryNotAssignedYet;

  /// No description provided for @deliveryStatusHistory.
  ///
  /// In en, this message translates to:
  /// **'Status history'**
  String get deliveryStatusHistory;

  /// No description provided for @deliveryOrderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order created'**
  String get deliveryOrderCreated;

  /// No description provided for @deliveryNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get deliveryNotYet;

  /// No description provided for @deliveryPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get deliveryPayment;

  /// No description provided for @deliveryDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryDeliveryFee;

  /// No description provided for @deliveryPaidWith.
  ///
  /// In en, this message translates to:
  /// **'Paid with'**
  String get deliveryPaidWith;

  /// No description provided for @deliveryDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get deliveryDirections;

  /// No description provided for @deliveryGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get deliveryGetHelp;

  /// No description provided for @deliveryCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order'**
  String get deliveryCancelOrder;

  /// No description provided for @deliveryCancelOrderBody.
  ///
  /// In en, this message translates to:
  /// **'The amount will be returned to your wallet. This cannot be undone.'**
  String get deliveryCancelOrderBody;

  /// No description provided for @deliveryCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel it'**
  String get deliveryCancelConfirm;

  /// No description provided for @deliveryCancelKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get deliveryCancelKeep;

  /// No description provided for @deliveryCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get deliveryCancelledTitle;

  /// No description provided for @deliveryCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'The amount has been returned to your wallet.'**
  String get deliveryCancelledBody;

  /// No description provided for @deliveryCancelFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel'**
  String get deliveryCancelFailedTitle;

  /// No description provided for @deliveryCancelFailedBody.
  ///
  /// In en, this message translates to:
  /// **'The order could not be cancelled. Nothing has changed.'**
  String get deliveryCancelFailedBody;

  /// No description provided for @deliveryCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Your orders did not load'**
  String get deliveryCouldNotLoad;

  /// No description provided for @deliveryCouldNotLoadBody.
  ///
  /// In en, this message translates to:
  /// **'The server did not respond. Your orders are safe — this screen just could not reach them.'**
  String get deliveryCouldNotLoadBody;

  /// No description provided for @deliveryCouldNotLoadOrder.
  ///
  /// In en, this message translates to:
  /// **'This order did not load'**
  String get deliveryCouldNotLoadOrder;

  /// No description provided for @deliveryOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get deliveryOrderNotFound;

  /// No description provided for @deliveryOrderNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This order is no longer available. It may have been removed.'**
  String get deliveryOrderNotFoundBody;

  /// No description provided for @deliveryBackToRecords.
  ///
  /// In en, this message translates to:
  /// **'Back to records'**
  String get deliveryBackToRecords;

  /// No description provided for @deliveryNoDeliveriesYet.
  ///
  /// In en, this message translates to:
  /// **'No deliveries yet'**
  String get deliveryNoDeliveriesYet;

  /// No description provided for @deliveryNoDeliveriesYetBody.
  ///
  /// In en, this message translates to:
  /// **'Packages you send will show up here, with their status and tracking ID.'**
  String get deliveryNoDeliveriesYetBody;

  /// No description provided for @deliveryNoStoreOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No store orders yet'**
  String get deliveryNoStoreOrdersYet;

  /// No description provided for @deliveryNoStoreOrdersYetBody.
  ///
  /// In en, this message translates to:
  /// **'Orders you place from a store will show up here once they are on their way.'**
  String get deliveryNoStoreOrdersYetBody;

  /// No description provided for @deliveryNoneWithThatStatus.
  ///
  /// In en, this message translates to:
  /// **'Nothing with that status'**
  String get deliveryNoneWithThatStatus;

  /// No description provided for @deliveryNoneWithThatStatusBody.
  ///
  /// In en, this message translates to:
  /// **'No order here is in that state right now.'**
  String get deliveryNoneWithThatStatusBody;

  /// No description provided for @deliverySendAPackage.
  ///
  /// In en, this message translates to:
  /// **'Send a package'**
  String get deliverySendAPackage;

  /// No description provided for @deliveryItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String deliveryItemCount(int count);

  /// No description provided for @deliveryRatingSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No ratings yet} =1{{rating} ★ · 1 rating} other{{rating} ★ · {count} ratings}}'**
  String deliveryRatingSummary(String rating, int count);

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get walletAvailableBalance;

  /// Verb. Puts money into the Vinkol wallet.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get walletAddMoney;

  /// Verb. Moves money out to a bank account.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get walletWithdraw;

  /// No description provided for @walletHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get walletHistory;

  /// No description provided for @walletTabPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get walletTabPayments;

  /// No description provided for @walletTabWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get walletTabWithdrawals;

  /// No description provided for @walletBalanceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Balance unavailable'**
  String get walletBalanceUnavailable;

  /// No description provided for @walletBalanceUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try again.'**
  String get walletBalanceUnavailableBody;

  /// No description provided for @walletNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get walletNoPayments;

  /// No description provided for @walletNoPaymentsBody.
  ///
  /// In en, this message translates to:
  /// **'Money you add to your wallet, and every delivery it pays for, is listed here.'**
  String get walletNoPaymentsBody;

  /// No description provided for @walletNoWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'No withdrawals yet'**
  String get walletNoWithdrawals;

  /// No description provided for @walletNoWithdrawalsBody.
  ///
  /// In en, this message translates to:
  /// **'Money you move from your wallet to your bank account shows up here.'**
  String get walletNoWithdrawalsBody;

  /// No description provided for @walletCouldNotLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Could not load your payments'**
  String get walletCouldNotLoadPayments;

  /// No description provided for @walletCouldNotLoadWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Could not load your withdrawals'**
  String get walletCouldNotLoadWithdrawals;

  /// Title of a credit row: money added to the wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet top-up'**
  String get walletTopUp;

  /// Title of a debit row with no narration from the server.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get walletPayment;

  /// No description provided for @walletWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get walletWithdrawal;

  /// No description provided for @walletBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get walletBankTransfer;

  /// No description provided for @walletAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get walletAmount;

  /// No description provided for @walletBalanceAfterTopUp.
  ///
  /// In en, this message translates to:
  /// **'Balance after top-up: {amount}'**
  String walletBalanceAfterTopUp(String amount);

  /// No description provided for @walletPayWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get walletPayWith;

  /// Dock caption on Add money: what the amount below is for.
  ///
  /// In en, this message translates to:
  /// **'Adding'**
  String get walletAdding;

  /// No description provided for @walletEnterAnAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get walletEnterAnAmount;

  /// No description provided for @walletMinimumTopUp.
  ///
  /// In en, this message translates to:
  /// **'The smallest top-up is {amount}'**
  String walletMinimumTopUp(String amount);

  /// No description provided for @walletCouldNotStartPayment.
  ///
  /// In en, this message translates to:
  /// **'We could not start that payment. Try again in a moment.'**
  String get walletCouldNotStartPayment;

  /// No description provided for @walletAvailableAmount.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount}'**
  String walletAvailableAmount(String amount);

  /// No description provided for @walletToAccount.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get walletToAccount;

  /// Verb. Opens the bank account picker.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get walletChange;

  /// No description provided for @walletWithdrawalsAreFinal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals are final'**
  String get walletWithdrawalsAreFinal;

  /// No description provided for @walletWithdrawalsAreFinalBody.
  ///
  /// In en, this message translates to:
  /// **'Once it is sent we cannot reverse it. Check the account number before you confirm.'**
  String get walletWithdrawalsAreFinalBody;

  /// Dock caption on Withdraw: what the amount below is for.
  ///
  /// In en, this message translates to:
  /// **'Withdrawing'**
  String get walletWithdrawing;

  /// No description provided for @walletConfirmWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Confirm withdrawal'**
  String get walletConfirmWithdrawal;

  /// No description provided for @walletMinimumWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'The smallest withdrawal is {amount}'**
  String walletMinimumWithdrawal(String amount);

  /// No description provided for @walletNotEnoughBalance.
  ///
  /// In en, this message translates to:
  /// **'That is more than your balance of {amount}'**
  String walletNotEnoughBalance(String amount);

  /// No description provided for @walletNoBankAccount.
  ///
  /// In en, this message translates to:
  /// **'No bank account yet'**
  String get walletNoBankAccount;

  /// No description provided for @walletNoBankAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Add the account your withdrawals should land in. You only do this once.'**
  String get walletNoBankAccountBody;

  /// No description provided for @walletAddBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Add bank account'**
  String get walletAddBankAccount;

  /// No description provided for @walletCouldNotLoadAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not load your bank account'**
  String get walletCouldNotLoadAccount;

  /// No description provided for @walletWithdrawalRequested.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal requested'**
  String get walletWithdrawalRequested;

  /// No description provided for @walletWithdrawalRequestedBody.
  ///
  /// In en, this message translates to:
  /// **'We will move it to your bank account shortly.'**
  String get walletWithdrawalRequestedBody;

  /// No description provided for @walletCouldNotWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Could not request that withdrawal'**
  String get walletCouldNotWithdraw;

  /// No description provided for @walletNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get walletNoteOptional;

  /// No description provided for @walletNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What is this withdrawal for?'**
  String get walletNoteHint;

  /// No description provided for @walletReviewWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Review this withdrawal'**
  String get walletReviewWithdrawal;

  /// No description provided for @walletTransaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get walletTransaction;

  /// The payment's identifier, quoted to support.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get walletReference;

  /// No description provided for @walletDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get walletDate;

  /// How the money moved: the wallet, a card.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get walletMethod;

  /// Debit or credit.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get walletType;

  /// No description provided for @walletVinkolWallet.
  ///
  /// In en, this message translates to:
  /// **'Vinkol wallet'**
  String get walletVinkolWallet;

  /// No description provided for @walletDebit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get walletDebit;

  /// No description provided for @walletCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get walletCredit;

  /// No description provided for @walletCopyReference.
  ///
  /// In en, this message translates to:
  /// **'Copy reference'**
  String get walletCopyReference;

  /// No description provided for @walletReferenceCopied.
  ///
  /// In en, this message translates to:
  /// **'Reference copied'**
  String get walletReferenceCopied;

  /// No description provided for @walletViewDelivery.
  ///
  /// In en, this message translates to:
  /// **'View delivery'**
  String get walletViewDelivery;

  /// Payment status. The money moved.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get walletStatusSuccessful;

  /// Payment status. Not settled yet.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get walletStatusPending;

  /// Payment status. The money did not move.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get walletStatusFailed;

  /// Withdrawal status. Sent to the bank.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get walletStatusApproved;

  /// Withdrawal status. Refused, money stays in the wallet.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get walletStatusRejected;

  /// No description provided for @walletBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get walletBankAccount;

  /// No description provided for @walletBankAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals land in this account.'**
  String get walletBankAccountBody;

  /// No description provided for @walletSelectBank.
  ///
  /// In en, this message translates to:
  /// **'Select bank'**
  String get walletSelectBank;

  /// No description provided for @walletBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get walletBank;

  /// No description provided for @walletAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get walletAccountNumber;

  /// No description provided for @walletAccountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'{digits} digits'**
  String walletAccountNumberHint(int digits);

  /// No description provided for @walletAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get walletAccountName;

  /// No description provided for @walletCheckingAccount.
  ///
  /// In en, this message translates to:
  /// **'Checking the account…'**
  String get walletCheckingAccount;

  /// No description provided for @walletAccountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account verified'**
  String get walletAccountVerified;

  /// No description provided for @walletAccountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'We could not verify that account'**
  String get walletAccountNotVerified;

  /// No description provided for @walletAccountNotVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Check the number and the bank, then try again.'**
  String get walletAccountNotVerifiedBody;

  /// No description provided for @walletSelectBankFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a bank first'**
  String get walletSelectBankFirst;

  /// No description provided for @walletSaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Save account'**
  String get walletSaveAccount;

  /// No description provided for @walletUpdateAccount.
  ///
  /// In en, this message translates to:
  /// **'Update account'**
  String get walletUpdateAccount;

  /// No description provided for @walletSearchBanks.
  ///
  /// In en, this message translates to:
  /// **'Search banks'**
  String get walletSearchBanks;

  /// No description provided for @walletNoBanksFound.
  ///
  /// In en, this message translates to:
  /// **'No banks match that'**
  String get walletNoBanksFound;

  /// No description provided for @walletNoBanksFoundBody.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling, or clear the search to see the whole list.'**
  String get walletNoBanksFoundBody;

  /// No description provided for @walletCouldNotLoadBanks.
  ///
  /// In en, this message translates to:
  /// **'Could not load the bank list'**
  String get walletCouldNotLoadBanks;

  /// No description provided for @walletPrimaryAccount.
  ///
  /// In en, this message translates to:
  /// **'Primary account'**
  String get walletPrimaryAccount;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileGuestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuestName;

  /// No description provided for @profileGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to book deliveries, use your wallet and keep your order history.'**
  String get profileGuestBody;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileSignIn;

  /// No description provided for @profileSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get profileSignInRequired;

  /// No description provided for @profileSignInRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account to use this.'**
  String get profileSignInRequiredBody;

  /// No description provided for @profileAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountSection;

  /// No description provided for @profileAppSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get profileAppSection;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get profilePersonalInfo;

  /// No description provided for @profilePersonalInfoMeta.
  ///
  /// In en, this message translates to:
  /// **'Name, phone and location'**
  String get profilePersonalInfoMeta;

  /// No description provided for @profileSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurity;

  /// No description provided for @profileSecurityMeta.
  ///
  /// In en, this message translates to:
  /// **'Password and transaction PIN'**
  String get profileSecurityMeta;

  /// No description provided for @profileBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get profileBankAccount;

  /// No description provided for @profileBankAccountMeta.
  ///
  /// In en, this message translates to:
  /// **'Where wallet withdrawals are paid'**
  String get profileBankAccountMeta;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileSettingsMeta.
  ///
  /// In en, this message translates to:
  /// **'Country, language and notifications'**
  String get profileSettingsMeta;

  /// No description provided for @profileDownloadReport.
  ///
  /// In en, this message translates to:
  /// **'Download report'**
  String get profileDownloadReport;

  /// No description provided for @profileDownloadReportMeta.
  ///
  /// In en, this message translates to:
  /// **'Your order history as a file'**
  String get profileDownloadReportMeta;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & help'**
  String get profileSupport;

  /// No description provided for @profileSupportMeta.
  ///
  /// In en, this message translates to:
  /// **'Call, email, or read the FAQ'**
  String get profileSupportMeta;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogOut;

  /// App version line at the foot of the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Vinkol {version}'**
  String profileVersion(String version);

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profileTakePhoto;

  /// No description provided for @profileChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileChooseFromGallery;

  /// No description provided for @profilePhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open that image.'**
  String get profilePhotoFailed;

  /// No description provided for @profileEmailHelper.
  ///
  /// In en, this message translates to:
  /// **'Your email is your sign-in and cannot be changed here.'**
  String get profileEmailHelper;

  /// Sample national phone number for the active market.
  ///
  /// In en, this message translates to:
  /// **'Example: {example}'**
  String profilePhoneHelper(String example);

  /// No description provided for @profileRegionHelper.
  ///
  /// In en, this message translates to:
  /// **'Used to price deliveries and match riders near you.'**
  String get profileRegionHelper;

  /// Picker title. {region} is the market's word for its administrative region, e.g. State or Province.
  ///
  /// In en, this message translates to:
  /// **'Select {region}'**
  String profileSelectRegion(String region);

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your first and last name.'**
  String get profileNameRequired;

  /// No description provided for @profilePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number with {digits} digits.'**
  String profilePhoneRequired(int digits);

  /// No description provided for @profileRegionRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose where you are.'**
  String get profileRegionRequired;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileSaved;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile'**
  String get profileSaveFailed;

  /// No description provided for @profileSignInGroup.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileSignInGroup;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileChangePasswordMeta.
  ///
  /// In en, this message translates to:
  /// **'Sends a reset code to your email'**
  String get profileChangePasswordMeta;

  /// No description provided for @profileTransactionsGroup.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get profileTransactionsGroup;

  /// No description provided for @profileTransactionPin.
  ///
  /// In en, this message translates to:
  /// **'Transaction PIN'**
  String get profileTransactionPin;

  /// No description provided for @profileTransactionPinMeta.
  ///
  /// In en, this message translates to:
  /// **'Not available yet — a delivery is confirmed with the code shown on the order'**
  String get profileTransactionPinMeta;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileNotificationsMeta.
  ///
  /// In en, this message translates to:
  /// **'Delivery updates'**
  String get profileNotificationsMeta;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// Language row summary. One language means the market ships nothing else.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{language} only} other{{language} · {count} available}}'**
  String profileLanguageMeta(int count, String language);

  /// No description provided for @profileChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get profileChooseLanguage;

  /// No description provided for @profileLanguageNote.
  ///
  /// In en, this message translates to:
  /// **'These are the languages Vinkol ships in {market}.'**
  String profileLanguageNote(String market);

  /// No description provided for @profileCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get profileCountry;

  /// No description provided for @profileCountryMeta.
  ///
  /// In en, this message translates to:
  /// **'{market} · {region} · {currency}'**
  String profileCountryMeta(String market, String region, String currency);

  /// No description provided for @profileLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get profileLegal;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get profileTerms;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacy;

  /// No description provided for @profileDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get profileDangerZone;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountMeta.
  ///
  /// In en, this message translates to:
  /// **'Permanently removes your data'**
  String get profileDeleteAccountMeta;

  /// No description provided for @profileDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get profileDeleteTitle;

  /// No description provided for @profileDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This opens the deletion form on vinkol.ng. Once it is processed, your orders, wallet balance and saved details are removed and cannot be restored.'**
  String get profileDeleteBody;

  /// No description provided for @profileDeleteContinue.
  ///
  /// In en, this message translates to:
  /// **'Open the form'**
  String get profileDeleteContinue;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @profilePush.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get profilePush;

  /// No description provided for @profilePushMeta.
  ///
  /// In en, this message translates to:
  /// **'Order updates sent to this device'**
  String get profilePushMeta;

  /// No description provided for @profileNotificationsNote.
  ///
  /// In en, this message translates to:
  /// **'Vinkol sends a push notification when an order changes status. Nothing is stored, so there is no inbox to come back to — switching this off unregisters this device rather than muting a list.'**
  String get profileNotificationsNote;

  /// No description provided for @supportContactGroup.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get supportContactGroup;

  /// No description provided for @supportCall.
  ///
  /// In en, this message translates to:
  /// **'Call support'**
  String get supportCall;

  /// No description provided for @supportCallAlt.
  ///
  /// In en, this message translates to:
  /// **'Second line'**
  String get supportCallAlt;

  /// No description provided for @supportEmailAction.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get supportEmailAction;

  /// No description provided for @supportWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get supportWhatsapp;

  /// No description provided for @supportHeadline.
  ///
  /// In en, this message translates to:
  /// **'{market} support'**
  String supportHeadline(String market);

  /// No description provided for @supportHoursNote.
  ///
  /// In en, this message translates to:
  /// **'Phone and email are answered {hours}. There is no in-app chat.'**
  String supportHoursNote(String hours);

  /// No description provided for @supportLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open that link.'**
  String get supportLinkFailed;

  /// No description provided for @supportFaqGroup.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get supportFaqGroup;

  /// No description provided for @supportAboutGroup.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get supportAboutGroup;

  /// No description provided for @supportWebsite.
  ///
  /// In en, this message translates to:
  /// **'Official website'**
  String get supportWebsite;

  /// No description provided for @supportAboutVinkol.
  ///
  /// In en, this message translates to:
  /// **'About Vinkol'**
  String get supportAboutVinkol;

  /// No description provided for @supportFollowGroup.
  ///
  /// In en, this message translates to:
  /// **'Follow Vinkol'**
  String get supportFollowGroup;

  /// No description provided for @supportInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get supportInstagram;

  /// No description provided for @supportX.
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get supportX;

  /// No description provided for @supportLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get supportLinkedIn;

  /// No description provided for @supportFaqQ1.
  ///
  /// In en, this message translates to:
  /// **'What is Vinkol?'**
  String get supportFaqQ1;

  /// No description provided for @supportFaqA1.
  ///
  /// In en, this message translates to:
  /// **'Vinkol is a digital platform that connects customers with professional delivery partners for fast, secure and reliable logistics.'**
  String get supportFaqA1;

  /// No description provided for @supportFaqQ2.
  ///
  /// In en, this message translates to:
  /// **'How does Vinkol work?'**
  String get supportFaqQ2;

  /// No description provided for @supportFaqA2.
  ///
  /// In en, this message translates to:
  /// **'Book a delivery in the app, give the pickup and drop-off details, pay, and follow the order\'s status until it is delivered.'**
  String get supportFaqA2;

  /// No description provided for @supportFaqQ3.
  ///
  /// In en, this message translates to:
  /// **'Is my parcel insured during delivery?'**
  String get supportFaqQ3;

  /// Coverage figure comes from the market; the amount is already formatted in the market's currency.
  ///
  /// In en, this message translates to:
  /// **'Vinkol provides retention coverage of up to {amount} for theft or damage to goods during delivery, provided the loss is verified and happened without negligence by the rider or logistics company.'**
  String supportFaqA3Covered(String amount);

  /// No description provided for @supportFaqA3Uncovered.
  ///
  /// In en, this message translates to:
  /// **'Coverage for theft or damage during delivery depends on the delivery partner. Contact Vinkol support to open a claim and we will mediate where applicable.'**
  String get supportFaqA3Uncovered;

  /// No description provided for @supportFaqQ4.
  ///
  /// In en, this message translates to:
  /// **'Who is responsible if my parcel is damaged or lost?'**
  String get supportFaqQ4;

  /// No description provided for @supportFaqA4.
  ///
  /// In en, this message translates to:
  /// **'Vinkol facilitates the booking, and each delivery partner is directly responsible for carrying out the delivery. Claims should be directed to the partner involved; Vinkol will help mediate the dispute where necessary.'**
  String get supportFaqA4;

  /// No description provided for @supportFaqQ5.
  ///
  /// In en, this message translates to:
  /// **'How do I make sure my item is safe to send?'**
  String get supportFaqQ5;

  /// No description provided for @supportFaqA5.
  ///
  /// In en, this message translates to:
  /// **'Package it so it cannot be damaged in transit. Fragile or high-value items should be wrapped and labelled clearly before pickup.'**
  String get supportFaqA5;

  /// No description provided for @supportFaqQ6.
  ///
  /// In en, this message translates to:
  /// **'How do I follow my delivery?'**
  String get supportFaqQ6;

  /// No description provided for @supportFaqA6.
  ///
  /// In en, this message translates to:
  /// **'Open the order under Records. Its status moves from pending, to with a rider or shopper, to delivered. Statuses are for information and are not a legal or financial record.'**
  String get supportFaqA6;

  /// No description provided for @supportFaqQ7.
  ///
  /// In en, this message translates to:
  /// **'What should I do if something goes wrong with a delivery?'**
  String get supportFaqQ7;

  /// No description provided for @supportFaqA7.
  ///
  /// In en, this message translates to:
  /// **'Report it through the app or contact support within 48 hours of the delivery attempt. Vinkol will review and mediate your case where applicable.'**
  String get supportFaqA7;

  /// No description provided for @supportFaqQ8.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel or change a delivery request?'**
  String get supportFaqQ8;

  /// No description provided for @supportFaqA8.
  ///
  /// In en, this message translates to:
  /// **'You can cancel or change a request before a rider accepts it. Once a delivery is under way, cancellation terms depend on the stage it has reached.'**
  String get supportFaqA8;

  /// No description provided for @supportFaqQ9.
  ///
  /// In en, this message translates to:
  /// **'Can I contact the rider?'**
  String get supportFaqQ9;

  /// No description provided for @supportFaqA9.
  ///
  /// In en, this message translates to:
  /// **'Yes. Once a rider is assigned, the order shows their number and you can call them. There is no in-app chat.'**
  String get supportFaqA9;

  /// No description provided for @supportFaqQ10.
  ///
  /// In en, this message translates to:
  /// **'How will I hear about delivery updates?'**
  String get supportFaqQ10;

  /// No description provided for @supportFaqA10.
  ///
  /// In en, this message translates to:
  /// **'Vinkol sends a push notification when your order changes status. Notifications are not stored, so there is no inbox to go back to.'**
  String get supportFaqA10;

  /// No description provided for @supportFaqQ11.
  ///
  /// In en, this message translates to:
  /// **'Does Vinkol store my personal data?'**
  String get supportFaqQ11;

  /// No description provided for @supportFaqA11.
  ///
  /// In en, this message translates to:
  /// **'Vinkol collects only what it needs to complete your delivery, and handles it in line with data-protection law and our privacy policy.'**
  String get supportFaqA11;

  /// No description provided for @supportFaqQ12.
  ///
  /// In en, this message translates to:
  /// **'How often do the terms change?'**
  String get supportFaqQ12;

  /// No description provided for @supportFaqA12.
  ///
  /// In en, this message translates to:
  /// **'Vinkol may update its terms and conditions from time to time. Continuing to use the platform after an update means you accept the new terms.'**
  String get supportFaqA12;

  /// No description provided for @supportFaqQ13.
  ///
  /// In en, this message translates to:
  /// **'How do I contact support?'**
  String get supportFaqQ13;

  /// No description provided for @supportFaqA13.
  ///
  /// In en, this message translates to:
  /// **'Use the contact options at the top of this screen. Phone and email are answered {hours}.'**
  String supportFaqA13(String hours);

  /// No description provided for @bookingServiceSingleDrop.
  ///
  /// In en, this message translates to:
  /// **'Single Drop'**
  String get bookingServiceSingleDrop;

  /// No description provided for @bookingServiceSingleDropMeta.
  ///
  /// In en, this message translates to:
  /// **'1 pickup · 1 drop-off'**
  String get bookingServiceSingleDropMeta;

  /// No description provided for @bookingServiceMultiDrop.
  ///
  /// In en, this message translates to:
  /// **'Multi-Drop'**
  String get bookingServiceMultiDrop;

  /// No description provided for @bookingServiceMultiDropMeta.
  ///
  /// In en, this message translates to:
  /// **'1 pickup · several drop-offs'**
  String get bookingServiceMultiDropMeta;

  /// No description provided for @bookingServiceBatchRun.
  ///
  /// In en, this message translates to:
  /// **'Batch Run'**
  String get bookingServiceBatchRun;

  /// No description provided for @bookingServiceBatchRunMeta.
  ///
  /// In en, this message translates to:
  /// **'Several deliveries · a rider each'**
  String get bookingServiceBatchRunMeta;

  /// No description provided for @bookingChooseService.
  ///
  /// In en, this message translates to:
  /// **'Choose your service'**
  String get bookingChooseService;

  /// No description provided for @bookingServiceSingleDropBadge.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get bookingServiceSingleDropBadge;

  /// No description provided for @bookingServiceMultiDropBadge.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 stops'**
  String get bookingServiceMultiDropBadge;

  /// No description provided for @bookingServiceBatchRunBadge.
  ///
  /// In en, this message translates to:
  /// **'Volume discount'**
  String get bookingServiceBatchRunBadge;

  /// No description provided for @bookingBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookingBookNow;

  /// No description provided for @bookingWhenShouldWeCollect.
  ///
  /// In en, this message translates to:
  /// **'When should we collect it?'**
  String get bookingWhenShouldWeCollect;

  /// No description provided for @bookingPickupNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get bookingPickupNow;

  /// No description provided for @bookingPickupNowMeta.
  ///
  /// In en, this message translates to:
  /// **'We start looking for a rider straight away'**
  String get bookingPickupNowMeta;

  /// No description provided for @bookingScheduleForLater.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get bookingScheduleForLater;

  /// No description provided for @bookingScheduleForLaterMeta.
  ///
  /// In en, this message translates to:
  /// **'Pick the day and the time'**
  String get bookingScheduleForLaterMeta;

  /// No description provided for @bookingPickupToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String bookingPickupToday(String time);

  /// No description provided for @bookingPickupOnDate.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String bookingPickupOnDate(String date, String time);

  /// No description provided for @bookingSetYourStops.
  ///
  /// In en, this message translates to:
  /// **'Set your stops'**
  String get bookingSetYourStops;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
