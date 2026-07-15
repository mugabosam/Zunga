// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Zunga';

  @override
  String greeting(String name) {
    return 'Muraho, $name';
  }

  @override
  String get totalBalance => 'Total balance';

  @override
  String get send => 'Send';

  @override
  String get payBill => 'Pay bill';

  @override
  String get electricity => 'Electricity';

  @override
  String get airtime => 'Airtime';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get seeAll => 'See all';

  @override
  String get navHome => 'Home';

  @override
  String get navPay => 'Pay';

  @override
  String get navActivity => 'Activity';

  @override
  String get navProfile => 'Profile';

  @override
  String get sendMoney => 'Send money';

  @override
  String get searchNameOrPhone => 'Name or phone number';

  @override
  String get contacts => 'Contacts';

  @override
  String get enterNumber => 'Enter number';

  @override
  String get allContacts => 'All contacts';

  @override
  String get recipientNumber => 'Recipient number';

  @override
  String get continueLabel => 'Continue';

  @override
  String get reviewTransfer => 'Review transfer';

  @override
  String get youAreSending => 'You\'re sending';

  @override
  String get registeredNameVerified => 'Registered name verified';

  @override
  String get amount => 'Amount';

  @override
  String get transferFee => 'Transfer fee';

  @override
  String get route => 'Route';

  @override
  String get totalToPay => 'Total to pay';

  @override
  String get enterPinToConfirm => 'Enter your PIN to confirm';

  @override
  String get moneySent => 'Money sent';

  @override
  String get reference => 'Reference';

  @override
  String get shareReceipt => 'Share receipt';

  @override
  String get done => 'Done';

  @override
  String get crossNetworkViaEkash => 'Cross-network via eKash';

  @override
  String ekashRouteExplainer(String from, String to) {
    return 'You\'re sending from $from to $to. Zunga will route this through eKash automatically.';
  }

  @override
  String get ekashRailNote =>
      'Routed via eKash, Rwanda\'s national payment system. Any bank to any wallet, instant, no cash-out needed.';

  @override
  String get payABill => 'Pay a bill';

  @override
  String get utilities => 'Utilities';

  @override
  String get television => 'Television';

  @override
  String get government => 'Government';

  @override
  String get healthEducation => 'Health & education';

  @override
  String get tokenPurchased => 'Token purchased';

  @override
  String get enterTokenOnMeter => 'Enter this token on your meter';

  @override
  String get copyToken => 'Copy token';

  @override
  String get energy => 'Energy';

  @override
  String get vatIncl => 'VAT incl.';

  @override
  String get activity => 'Activity';

  @override
  String get spentThisWeek => 'Spent this week';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get pay => 'Pay';

  @override
  String get moneyMovement => 'Money movement';

  @override
  String get sendToMobile => 'Send to mobile';

  @override
  String get bankTransferEkash => 'Bank transfer · eKash';

  @override
  String get payMerchant => 'Pay a merchant';

  @override
  String get withdrawCash => 'Withdraw cash';

  @override
  String get billsUtilities => 'Bills & utilities';

  @override
  String get tools => 'Tools';

  @override
  String get splitABill => 'Split a bill';

  @override
  String get ikimina => 'Ikimina';

  @override
  String get scheduledPayments => 'Scheduled payments';

  @override
  String get merchantMode => 'Merchant mode';

  @override
  String get bankTransfer => 'Bank transfer';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get ekashFee => 'eKash fee';

  @override
  String get arrives => 'Arrives';

  @override
  String get instantly => 'Instantly';

  @override
  String get linkedAccounts => 'Linked accounts';

  @override
  String get mobileMoney => 'Mobile money';

  @override
  String get banksViaEkash => 'Banks · via eKash & USSD';

  @override
  String get connected => 'Connected';

  @override
  String get connect => 'Connect';

  @override
  String get pinNeverLeaves =>
      'Zunga runs every transaction through your carrier\'s own USSD on this phone. Your PINs are never stored or sent to our servers.';

  @override
  String get addAnotherAccount => 'Add another account';

  @override
  String get airtimeBundles => 'Airtime & bundles';

  @override
  String get bundles => 'Bundles';

  @override
  String get autoTopUp => 'Auto top-up';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get comingUp => 'Coming up';

  @override
  String get reminders => 'Reminders';

  @override
  String get scheduleNote =>
      'Zunga reminds you and prepares each payment. You always confirm with your PIN — nothing is sent without you.';

  @override
  String get governmentSocial => 'Government & social';

  @override
  String get healthInsurance => 'Health insurance';

  @override
  String get mutuelle => 'Mutuelle de Santé';

  @override
  String get paid => 'Paid';

  @override
  String get pending => 'Pending';

  @override
  String get covered => 'Covered';

  @override
  String get members => 'Members';

  @override
  String get remindPendingMembers => 'Remind pending members';

  @override
  String get numberReported => 'This number has been reported';

  @override
  String get cancelThisTransfer => 'Cancel this transfer';

  @override
  String get continueAnyway => 'Continue anyway';

  @override
  String get reportsThisMonth => 'Reports this month';

  @override
  String get pattern => 'Pattern';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language · Ururimi · Langue';

  @override
  String get security => 'Security';

  @override
  String get appPin => 'App PIN';

  @override
  String get requiredForEveryPayment => 'Required for every payment';

  @override
  String get change => 'Change';

  @override
  String get unlockWithFingerprint => 'Unlock with fingerprint';

  @override
  String get openWithBiometrics => 'Open the app with biometrics';

  @override
  String get scamProtection => 'Scam protection';

  @override
  String get warnReportedNumbers => 'Warn me about reported numbers';

  @override
  String get nameCheckBeforeSending => 'Name check before sending';

  @override
  String get alwaysShowRegisteredName => 'Always show the registered name';

  @override
  String get business => 'Business';

  @override
  String get dialMyself => 'Dial myself';

  @override
  String get manualFallbackHint =>
      'Open the carrier USSD menu and complete this step yourself.';

  @override
  String get onboardingTitle => 'Every payment in Rwanda. One app.';

  @override
  String get onboardingSubtitle =>
      'MoMo, Airtel, banks via eKash, bills and government payments — through your own USSD, on your own SIM.';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get verifyCode => 'Verification code';

  @override
  String get createPin => 'Create your Zunga PIN';

  @override
  String get confirmPin => 'Confirm your PIN';

  @override
  String get enableBiometrics => 'Unlock with fingerprint';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get getStarted => 'Get started';

  @override
  String get salesToday => 'Sales today';

  @override
  String get payments => 'Payments';

  @override
  String get thisWeek => 'This week';

  @override
  String get paymentsReceived => 'Payments received';

  @override
  String get exportStatement => 'Export monthly statement · RRA-ready';

  @override
  String get appLocked => 'Zunga is locked';

  @override
  String get unlock => 'Unlock';

  @override
  String get sessionInProgress => 'USSD session in progress…';

  @override
  String get menuChangedError =>
      'The carrier changed this menu — we\'re updating it. Use manual mode meanwhile.';
}
