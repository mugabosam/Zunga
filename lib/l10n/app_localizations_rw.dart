// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kinyarwanda (`rw`).
class AppLocalizationsRw extends AppLocalizations {
  AppLocalizationsRw([String locale = 'rw']) : super(locale);

  @override
  String get appName => 'Zunga';

  @override
  String greeting(String name) {
    return 'Muraho, $name';
  }

  @override
  String get totalBalance => 'Amafaranga yose ufite';

  @override
  String get send => 'Ohereza';

  @override
  String get payBill => 'Ishyura fagitire';

  @override
  String get electricity => 'Amashanyarazi';

  @override
  String get airtime => 'Amayunite';

  @override
  String get recentActivity => 'Ibikorwa bya vuba';

  @override
  String get seeAll => 'Reba byose';

  @override
  String get navHome => 'Ahabanza';

  @override
  String get navPay => 'Kwishyura';

  @override
  String get navActivity => 'Ibikorwa';

  @override
  String get navProfile => 'Umwirondoro';

  @override
  String get sendMoney => 'Ohereza amafaranga';

  @override
  String get searchNameOrPhone => 'Izina cyangwa nimero ya telefoni';

  @override
  String get contacts => 'Abo muziranye';

  @override
  String get enterNumber => 'Andika nimero';

  @override
  String get allContacts => 'Abo muziranye bose';

  @override
  String get recipientNumber => 'Nimero y\'uwakira';

  @override
  String get continueLabel => 'Komeza';

  @override
  String get reviewTransfer => 'Suzuma ubwohereze';

  @override
  String get youAreSending => 'Urimo kohereza';

  @override
  String get registeredNameVerified => 'Izina ryanditse ryemejwe';

  @override
  String get amount => 'Umubare w\'amafaranga';

  @override
  String get transferFee => 'Amafaranga y\'ubwohereze';

  @override
  String get route => 'Inzira';

  @override
  String get totalToPay => 'Igiteranyo cyo kwishyura';

  @override
  String get enterPinToConfirm => 'Andika umubare w\'ibanga wemeze';

  @override
  String get moneySent => 'Amafaranga yoherejwe';

  @override
  String get reference => 'Indangamubare';

  @override
  String get shareReceipt => 'Sangiza inyemezabwishyu';

  @override
  String get done => 'Byarangiye';

  @override
  String get crossNetworkViaEkash => 'Hagati y\'imiyoboro binyuze kuri eKash';

  @override
  String ekashRouteExplainer(String from, String to) {
    return 'Urimo kohereza uvuye kuri $from ujya kuri $to. Zunga izabinyuza kuri eKash byikoresha.';
  }

  @override
  String get ekashRailNote =>
      'Binyuzwa kuri eKash, uburyo bw\'igihugu bwo kwishyurana. Banki iyo ari yo yose ku ifuka iryo ari ryo ryose, ako kanya.';

  @override
  String get payABill => 'Ishyura fagitire';

  @override
  String get utilities => 'Ibikorwa remezo';

  @override
  String get television => 'Televiziyo';

  @override
  String get government => 'Leta';

  @override
  String get healthEducation => 'Ubuzima n\'uburezi';

  @override
  String get tokenPurchased => 'Umubare w\'amashanyarazi waguzwe';

  @override
  String get enterTokenOnMeter => 'Andika uyu mubare kuri mubazi yawe';

  @override
  String get copyToken => 'Koporora umubare';

  @override
  String get energy => 'Ingufu';

  @override
  String get vatIncl => 'TVA irimo';

  @override
  String get activity => 'Ibikorwa';

  @override
  String get spentThisWeek => 'Ayakoreshejwe iki cyumweru';

  @override
  String get today => 'Uyu munsi';

  @override
  String get yesterday => 'Ejo hashize';

  @override
  String get pay => 'Kwishyura';

  @override
  String get moneyMovement => 'Kwimura amafaranga';

  @override
  String get sendToMobile => 'Ohereza kuri telefoni';

  @override
  String get bankTransferEkash => 'Kohereza kuri banki · eKash';

  @override
  String get payMerchant => 'Ishyura umucuruzi';

  @override
  String get withdrawCash => 'Bikuza amafaranga';

  @override
  String get billsUtilities => 'Fagitire n\'ibikorwa remezo';

  @override
  String get tools => 'Ibikoresho';

  @override
  String get splitABill => 'Gabana fagitire';

  @override
  String get ikimina => 'Ikimina';

  @override
  String get scheduledPayments => 'Ubwishyu bwateganyijwe';

  @override
  String get merchantMode => 'Uburyo bw\'umucuruzi';

  @override
  String get bankTransfer => 'Kohereza kuri banki';

  @override
  String get from => 'Bivuye';

  @override
  String get to => 'Bijya';

  @override
  String get ekashFee => 'Amafaranga ya eKash';

  @override
  String get arrives => 'Bigeraho';

  @override
  String get instantly => 'Ako kanya';

  @override
  String get linkedAccounts => 'Konti zihujwe';

  @override
  String get mobileMoney => 'Mobile money';

  @override
  String get banksViaEkash => 'Amabanki · binyuze kuri eKash na USSD';

  @override
  String get connected => 'Byahujwe';

  @override
  String get connect => 'Huza';

  @override
  String get pinNeverLeaves =>
      'Zunga inyuza buri gikorwa muri USSD ya murandasi yawe kuri iyi telefoni. Imibare y\'ibanga yawe ntibikwa cyangwa ngo yoherezwe ku byuma byacu.';

  @override
  String get addAnotherAccount => 'Ongeraho indi konti';

  @override
  String get airtimeBundles => 'Amayunite n\'amapaki';

  @override
  String get bundles => 'Amapaki';

  @override
  String get autoTopUp => 'Kwiyongeza byikoresha';

  @override
  String get scheduled => 'Ibyateganyijwe';

  @override
  String get comingUp => 'Ibiri hafi';

  @override
  String get reminders => 'Urwibutso';

  @override
  String get scheduleNote =>
      'Zunga irakwibutsa ikanategura buri bwishyu. Wowe ni wowe wemeza n\'umubare w\'ibanga — nta na kimwe cyoherezwa utabyemeje.';

  @override
  String get governmentSocial => 'Leta n\'imibereho';

  @override
  String get healthInsurance => 'Ubwishingizi bw\'ubuzima';

  @override
  String get mutuelle => 'Mituweri';

  @override
  String get paid => 'Byishyuwe';

  @override
  String get pending => 'Bitegereje';

  @override
  String get covered => 'Afite ubwishingizi';

  @override
  String get members => 'Abanyamuryango';

  @override
  String get remindPendingMembers => 'Ibutsa abatarishyura';

  @override
  String get numberReported => 'Iyi nimero yatanzweho ikirego';

  @override
  String get cancelThisTransfer => 'Hagarika ubu bwohereze';

  @override
  String get continueAnyway => 'Komeza uko byagenda kose';

  @override
  String get reportsThisMonth => 'Ibirego muri uku kwezi';

  @override
  String get pattern => 'Uburyo';

  @override
  String get profile => 'Umwirondoro';

  @override
  String get language => 'Ururimi · Language · Langue';

  @override
  String get security => 'Umutekano';

  @override
  String get appPin => 'Umubare w\'ibanga wa Zunga';

  @override
  String get requiredForEveryPayment => 'Usabwa kuri buri bwishyu';

  @override
  String get change => 'Hindura';

  @override
  String get unlockWithFingerprint => 'Fungura n\'igikumwe';

  @override
  String get openWithBiometrics => 'Fungura porogaramu ukoresheje igikumwe';

  @override
  String get scamProtection => 'Kurindwa uburiganya';

  @override
  String get warnReportedNumbers => 'Mburira ku manimero yatanzweho ibirego';

  @override
  String get nameCheckBeforeSending => 'Kugenzura izina mbere yo kohereza';

  @override
  String get alwaysShowRegisteredName => 'Buri gihe erekana izina ryanditse';

  @override
  String get business => 'Ubucuruzi';

  @override
  String get dialMyself => 'Ndihamagarira ubwanjye';

  @override
  String get manualFallbackHint =>
      'Fungura USSD ya murandasi urangize iyi ntambwe ubwawe.';

  @override
  String get onboardingTitle => 'Ubwishyu bwose bw\'u Rwanda. Porogaramu imwe.';

  @override
  String get onboardingSubtitle =>
      'MoMo, Airtel, amabanki binyuze kuri eKash, fagitire n\'ubwishyu bwa Leta — binyuze muri USSD yawe, kuri SIM yawe.';

  @override
  String get phoneNumber => 'Nimero ya telefoni';

  @override
  String get verifyCode => 'Umubare wo kwemeza';

  @override
  String get createPin => 'Shyiraho umubare w\'ibanga wa Zunga';

  @override
  String get confirmPin => 'Emeza umubare w\'ibanga';

  @override
  String get enableBiometrics => 'Fungura n\'igikumwe';

  @override
  String get skipForNow => 'Bireke ubu';

  @override
  String get getStarted => 'Tangira';

  @override
  String get salesToday => 'Ibyacurujwe uyu munsi';

  @override
  String get payments => 'Ubwishyu';

  @override
  String get thisWeek => 'Iki cyumweru';

  @override
  String get paymentsReceived => 'Ubwishyu bwakiriwe';

  @override
  String get exportStatement => 'Sohora raporo y\'ukwezi · yiteguriwe RRA';

  @override
  String get appLocked => 'Zunga irafunze';

  @override
  String get unlock => 'Fungura';

  @override
  String get sessionInProgress => 'Igikorwa cya USSD kirimo gukorwa…';

  @override
  String get menuChangedError =>
      'Murandasi yahinduye iyi menyu — turimo kuyivugurura. Koresha uburyo bwo kwikorera hagati aho.';
}
