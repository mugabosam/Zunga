import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';

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
    Locale('fr'),
    Locale('rw'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Zunga'**
  String get appName;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Muraho, {name}'**
  String greeting(String name);

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @payBill.
  ///
  /// In en, this message translates to:
  /// **'Pay bill'**
  String get payBill;

  /// No description provided for @electricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricity;

  /// No description provided for @airtime.
  ///
  /// In en, this message translates to:
  /// **'Airtime'**
  String get airtime;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get navPay;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @sendMoney.
  ///
  /// In en, this message translates to:
  /// **'Send money'**
  String get sendMoney;

  /// No description provided for @searchNameOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Name or phone number'**
  String get searchNameOrPhone;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter number'**
  String get enterNumber;

  /// No description provided for @allContacts.
  ///
  /// In en, this message translates to:
  /// **'All contacts'**
  String get allContacts;

  /// No description provided for @recipientNumber.
  ///
  /// In en, this message translates to:
  /// **'Recipient number'**
  String get recipientNumber;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @reviewTransfer.
  ///
  /// In en, this message translates to:
  /// **'Review transfer'**
  String get reviewTransfer;

  /// No description provided for @youAreSending.
  ///
  /// In en, this message translates to:
  /// **'You\'re sending'**
  String get youAreSending;

  /// No description provided for @registeredNameVerified.
  ///
  /// In en, this message translates to:
  /// **'Registered name verified'**
  String get registeredNameVerified;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @transferFee.
  ///
  /// In en, this message translates to:
  /// **'Transfer fee'**
  String get transferFee;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay'**
  String get totalToPay;

  /// No description provided for @enterPinToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to confirm'**
  String get enterPinToConfirm;

  /// No description provided for @moneySent.
  ///
  /// In en, this message translates to:
  /// **'Money sent'**
  String get moneySent;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share receipt'**
  String get shareReceipt;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @crossNetworkViaEkash.
  ///
  /// In en, this message translates to:
  /// **'Cross-network via eKash'**
  String get crossNetworkViaEkash;

  /// No description provided for @ekashRouteExplainer.
  ///
  /// In en, this message translates to:
  /// **'You\'re sending from {from} to {to}. Zunga will route this through eKash automatically.'**
  String ekashRouteExplainer(String from, String to);

  /// No description provided for @ekashRailNote.
  ///
  /// In en, this message translates to:
  /// **'Routed via eKash, Rwanda\'s national payment system. Any bank to any wallet, instant, no cash-out needed.'**
  String get ekashRailNote;

  /// No description provided for @payABill.
  ///
  /// In en, this message translates to:
  /// **'Pay a bill'**
  String get payABill;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// No description provided for @television.
  ///
  /// In en, this message translates to:
  /// **'Television'**
  String get television;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// No description provided for @healthEducation.
  ///
  /// In en, this message translates to:
  /// **'Health & education'**
  String get healthEducation;

  /// No description provided for @tokenPurchased.
  ///
  /// In en, this message translates to:
  /// **'Token purchased'**
  String get tokenPurchased;

  /// No description provided for @enterTokenOnMeter.
  ///
  /// In en, this message translates to:
  /// **'Enter this token on your meter'**
  String get enterTokenOnMeter;

  /// No description provided for @copyToken.
  ///
  /// In en, this message translates to:
  /// **'Copy token'**
  String get copyToken;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @vatIncl.
  ///
  /// In en, this message translates to:
  /// **'VAT incl.'**
  String get vatIncl;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @spentThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Spent this week'**
  String get spentThisWeek;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @moneyMovement.
  ///
  /// In en, this message translates to:
  /// **'Money movement'**
  String get moneyMovement;

  /// No description provided for @sendToMobile.
  ///
  /// In en, this message translates to:
  /// **'Send to mobile'**
  String get sendToMobile;

  /// No description provided for @bankTransferEkash.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer · eKash'**
  String get bankTransferEkash;

  /// No description provided for @payMerchant.
  ///
  /// In en, this message translates to:
  /// **'Pay a merchant'**
  String get payMerchant;

  /// No description provided for @withdrawCash.
  ///
  /// In en, this message translates to:
  /// **'Withdraw cash'**
  String get withdrawCash;

  /// No description provided for @billsUtilities.
  ///
  /// In en, this message translates to:
  /// **'Bills & utilities'**
  String get billsUtilities;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @splitABill.
  ///
  /// In en, this message translates to:
  /// **'Split a bill'**
  String get splitABill;

  /// No description provided for @ikimina.
  ///
  /// In en, this message translates to:
  /// **'Ikimina'**
  String get ikimina;

  /// No description provided for @scheduledPayments.
  ///
  /// In en, this message translates to:
  /// **'Scheduled payments'**
  String get scheduledPayments;

  /// No description provided for @merchantMode.
  ///
  /// In en, this message translates to:
  /// **'Merchant mode'**
  String get merchantMode;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransfer;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @ekashFee.
  ///
  /// In en, this message translates to:
  /// **'eKash fee'**
  String get ekashFee;

  /// No description provided for @arrives.
  ///
  /// In en, this message translates to:
  /// **'Arrives'**
  String get arrives;

  /// No description provided for @instantly.
  ///
  /// In en, this message translates to:
  /// **'Instantly'**
  String get instantly;

  /// No description provided for @linkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Linked accounts'**
  String get linkedAccounts;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get mobileMoney;

  /// No description provided for @banksViaEkash.
  ///
  /// In en, this message translates to:
  /// **'Banks · via eKash & USSD'**
  String get banksViaEkash;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @pinNeverLeaves.
  ///
  /// In en, this message translates to:
  /// **'Zunga runs every transaction through your carrier\'s own USSD on this phone. Your PINs are never stored or sent to our servers.'**
  String get pinNeverLeaves;

  /// No description provided for @addAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Add another account'**
  String get addAnotherAccount;

  /// No description provided for @airtimeBundles.
  ///
  /// In en, this message translates to:
  /// **'Airtime & bundles'**
  String get airtimeBundles;

  /// No description provided for @bundles.
  ///
  /// In en, this message translates to:
  /// **'Bundles'**
  String get bundles;

  /// No description provided for @autoTopUp.
  ///
  /// In en, this message translates to:
  /// **'Auto top-up'**
  String get autoTopUp;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @comingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get comingUp;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @scheduleNote.
  ///
  /// In en, this message translates to:
  /// **'Zunga reminds you and prepares each payment. You always confirm with your PIN — nothing is sent without you.'**
  String get scheduleNote;

  /// No description provided for @governmentSocial.
  ///
  /// In en, this message translates to:
  /// **'Government & social'**
  String get governmentSocial;

  /// No description provided for @healthInsurance.
  ///
  /// In en, this message translates to:
  /// **'Health insurance'**
  String get healthInsurance;

  /// No description provided for @mutuelle.
  ///
  /// In en, this message translates to:
  /// **'Mutuelle de Santé'**
  String get mutuelle;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @covered.
  ///
  /// In en, this message translates to:
  /// **'Covered'**
  String get covered;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @remindPendingMembers.
  ///
  /// In en, this message translates to:
  /// **'Remind pending members'**
  String get remindPendingMembers;

  /// No description provided for @numberReported.
  ///
  /// In en, this message translates to:
  /// **'This number has been reported'**
  String get numberReported;

  /// No description provided for @cancelThisTransfer.
  ///
  /// In en, this message translates to:
  /// **'Cancel this transfer'**
  String get cancelThisTransfer;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get continueAnyway;

  /// No description provided for @reportsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Reports this month'**
  String get reportsThisMonth;

  /// No description provided for @pattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get pattern;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language · Ururimi · Langue'**
  String get language;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @appPin.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get appPin;

  /// No description provided for @requiredForEveryPayment.
  ///
  /// In en, this message translates to:
  /// **'Required for every payment'**
  String get requiredForEveryPayment;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @unlockWithFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint'**
  String get unlockWithFingerprint;

  /// No description provided for @openWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Open the app with biometrics'**
  String get openWithBiometrics;

  /// No description provided for @scamProtection.
  ///
  /// In en, this message translates to:
  /// **'Scam protection'**
  String get scamProtection;

  /// No description provided for @warnReportedNumbers.
  ///
  /// In en, this message translates to:
  /// **'Warn me about reported numbers'**
  String get warnReportedNumbers;

  /// No description provided for @nameCheckBeforeSending.
  ///
  /// In en, this message translates to:
  /// **'Name check before sending'**
  String get nameCheckBeforeSending;

  /// No description provided for @alwaysShowRegisteredName.
  ///
  /// In en, this message translates to:
  /// **'Always show the registered name'**
  String get alwaysShowRegisteredName;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @dialMyself.
  ///
  /// In en, this message translates to:
  /// **'Dial myself'**
  String get dialMyself;

  /// No description provided for @manualFallbackHint.
  ///
  /// In en, this message translates to:
  /// **'Open the carrier USSD menu and complete this step yourself.'**
  String get manualFallbackHint;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Every payment in Rwanda. One app.'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MoMo, Airtel, banks via eKash, bills and government payments — through your own USSD, on your own SIM.'**
  String get onboardingSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verifyCode;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create your Zunga PIN'**
  String get createPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get confirmPin;

  /// No description provided for @enableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint'**
  String get enableBiometrics;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @salesToday.
  ///
  /// In en, this message translates to:
  /// **'Sales today'**
  String get salesToday;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @paymentsReceived.
  ///
  /// In en, this message translates to:
  /// **'Payments received'**
  String get paymentsReceived;

  /// No description provided for @exportStatement.
  ///
  /// In en, this message translates to:
  /// **'Export monthly statement · RRA-ready'**
  String get exportStatement;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'Zunga is locked'**
  String get appLocked;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @sessionInProgress.
  ///
  /// In en, this message translates to:
  /// **'USSD session in progress…'**
  String get sessionInProgress;

  /// No description provided for @menuChangedError.
  ///
  /// In en, this message translates to:
  /// **'The carrier changed this menu — we\'re updating it. Use manual mode meanwhile.'**
  String get menuChangedError;
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
      <String>['en', 'fr', 'rw'].contains(locale.languageCode);

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
    case 'rw':
      return AppLocalizationsRw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
