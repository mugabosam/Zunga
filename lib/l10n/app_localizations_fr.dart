// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Zunga';

  @override
  String greeting(String name) {
    return 'Muraho, $name';
  }

  @override
  String get totalBalance => 'Solde total';

  @override
  String get send => 'Envoyer';

  @override
  String get payBill => 'Payer facture';

  @override
  String get electricity => 'Électricité';

  @override
  String get airtime => 'Crédit';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get navHome => 'Accueil';

  @override
  String get navPay => 'Payer';

  @override
  String get navActivity => 'Activité';

  @override
  String get navProfile => 'Profil';

  @override
  String get sendMoney => 'Envoyer de l\'argent';

  @override
  String get searchNameOrPhone => 'Nom ou numéro de téléphone';

  @override
  String get contacts => 'Contacts';

  @override
  String get enterNumber => 'Saisir le numéro';

  @override
  String get allContacts => 'Tous les contacts';

  @override
  String get recipientNumber => 'Numéro du destinataire';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get reviewTransfer => 'Vérifier le transfert';

  @override
  String get youAreSending => 'Vous envoyez';

  @override
  String get registeredNameVerified => 'Nom enregistré vérifié';

  @override
  String get amount => 'Montant';

  @override
  String get transferFee => 'Frais de transfert';

  @override
  String get route => 'Itinéraire';

  @override
  String get totalToPay => 'Total à payer';

  @override
  String get enterPinToConfirm => 'Saisissez votre PIN pour confirmer';

  @override
  String get moneySent => 'Argent envoyé';

  @override
  String get reference => 'Référence';

  @override
  String get shareReceipt => 'Partager le reçu';

  @override
  String get done => 'Terminé';

  @override
  String get crossNetworkViaEkash => 'Inter-réseaux via eKash';

  @override
  String ekashRouteExplainer(String from, String to) {
    return 'Vous envoyez depuis $from vers $to. Zunga passera automatiquement par eKash.';
  }

  @override
  String get ekashRailNote =>
      'Acheminé via eKash, le système national de paiement du Rwanda. De toute banque vers tout portefeuille, instantané, sans retrait.';

  @override
  String get payABill => 'Payer une facture';

  @override
  String get utilities => 'Services publics';

  @override
  String get television => 'Télévision';

  @override
  String get government => 'Gouvernement';

  @override
  String get healthEducation => 'Santé et éducation';

  @override
  String get tokenPurchased => 'Jeton acheté';

  @override
  String get enterTokenOnMeter => 'Entrez ce jeton sur votre compteur';

  @override
  String get copyToken => 'Copier le jeton';

  @override
  String get energy => 'Énergie';

  @override
  String get vatIncl => 'TVA incl.';

  @override
  String get activity => 'Activité';

  @override
  String get spentThisWeek => 'Dépensé cette semaine';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get pay => 'Payer';

  @override
  String get moneyMovement => 'Mouvements d\'argent';

  @override
  String get sendToMobile => 'Envoyer vers mobile';

  @override
  String get bankTransferEkash => 'Virement bancaire · eKash';

  @override
  String get payMerchant => 'Payer un commerçant';

  @override
  String get withdrawCash => 'Retirer de l\'argent';

  @override
  String get billsUtilities => 'Factures et services';

  @override
  String get tools => 'Outils';

  @override
  String get splitABill => 'Partager une facture';

  @override
  String get ikimina => 'Ikimina';

  @override
  String get scheduledPayments => 'Paiements programmés';

  @override
  String get merchantMode => 'Mode commerçant';

  @override
  String get bankTransfer => 'Virement bancaire';

  @override
  String get from => 'De';

  @override
  String get to => 'Vers';

  @override
  String get ekashFee => 'Frais eKash';

  @override
  String get arrives => 'Arrive';

  @override
  String get instantly => 'Instantanément';

  @override
  String get linkedAccounts => 'Comptes liés';

  @override
  String get mobileMoney => 'Mobile money';

  @override
  String get banksViaEkash => 'Banques · via eKash et USSD';

  @override
  String get connected => 'Connecté';

  @override
  String get connect => 'Connecter';

  @override
  String get pinNeverLeaves =>
      'Zunga exécute chaque transaction via l\'USSD de votre opérateur sur ce téléphone. Vos PIN ne sont jamais stockés ni envoyés à nos serveurs.';

  @override
  String get addAnotherAccount => 'Ajouter un autre compte';

  @override
  String get airtimeBundles => 'Crédit et forfaits';

  @override
  String get bundles => 'Forfaits';

  @override
  String get autoTopUp => 'Recharge automatique';

  @override
  String get scheduled => 'Programmés';

  @override
  String get comingUp => 'À venir';

  @override
  String get reminders => 'Rappels';

  @override
  String get scheduleNote =>
      'Zunga vous rappelle et prépare chaque paiement. Vous confirmez toujours avec votre PIN — rien n\'est envoyé sans vous.';

  @override
  String get governmentSocial => 'Gouvernement et social';

  @override
  String get healthInsurance => 'Assurance maladie';

  @override
  String get mutuelle => 'Mutuelle de Santé';

  @override
  String get paid => 'Payé';

  @override
  String get pending => 'En attente';

  @override
  String get covered => 'Couvert';

  @override
  String get members => 'Membres';

  @override
  String get remindPendingMembers => 'Rappeler les membres en attente';

  @override
  String get numberReported => 'Ce numéro a été signalé';

  @override
  String get cancelThisTransfer => 'Annuler ce transfert';

  @override
  String get continueAnyway => 'Continuer quand même';

  @override
  String get reportsThisMonth => 'Signalements ce mois';

  @override
  String get pattern => 'Schéma';

  @override
  String get profile => 'Profil';

  @override
  String get language => 'Langue · Ururimi · Language';

  @override
  String get security => 'Sécurité';

  @override
  String get appPin => 'PIN de l\'application';

  @override
  String get requiredForEveryPayment => 'Requis pour chaque paiement';

  @override
  String get change => 'Modifier';

  @override
  String get unlockWithFingerprint => 'Déverrouiller par empreinte';

  @override
  String get openWithBiometrics => 'Ouvrir l\'application par biométrie';

  @override
  String get scamProtection => 'Protection anti-arnaque';

  @override
  String get warnReportedNumbers => 'M\'avertir des numéros signalés';

  @override
  String get nameCheckBeforeSending => 'Vérifier le nom avant l\'envoi';

  @override
  String get alwaysShowRegisteredName => 'Toujours afficher le nom enregistré';

  @override
  String get business => 'Entreprise';

  @override
  String get dialMyself => 'Composer moi-même';

  @override
  String get manualFallbackHint =>
      'Ouvrez le menu USSD de l\'opérateur et terminez cette étape vous-même.';

  @override
  String get onboardingTitle => 'Tous les paiements du Rwanda. Une seule app.';

  @override
  String get onboardingSubtitle =>
      'MoMo, Airtel, banques via eKash, factures et paiements publics — via votre propre USSD, sur votre propre SIM.';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get verifyCode => 'Code de vérification';

  @override
  String get createPin => 'Créez votre PIN Zunga';

  @override
  String get confirmPin => 'Confirmez votre PIN';

  @override
  String get enableBiometrics => 'Déverrouiller par empreinte';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get getStarted => 'Commencer';

  @override
  String get salesToday => 'Ventes aujourd\'hui';

  @override
  String get payments => 'Paiements';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get paymentsReceived => 'Paiements reçus';

  @override
  String get exportStatement => 'Exporter le relevé mensuel · prêt pour la RRA';

  @override
  String get appLocked => 'Zunga est verrouillée';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get sessionInProgress => 'Session USSD en cours…';

  @override
  String get menuChangedError =>
      'L\'opérateur a modifié ce menu — mise à jour en cours. Utilisez le mode manuel en attendant.';
}
