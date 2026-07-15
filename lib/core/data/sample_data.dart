import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';

/// Stage-1 sample repositories, mirroring the zunga-ui.html mocks.
/// Replaced by encrypted-Hive-backed repositories in Stages 2-5.

final userNameProvider = Provider((ref) => 'Sam MUGABO');

final linkedAccountsProvider = Provider<List<LinkedAccount>>((ref) => const [
      LinkedAccount(
        id: 'momo',
        type: WalletType.momo,
        provider: 'MTN MoMo',
        maskedIdentifier: '+250 788 ··· 903 · *182#',
        simSlot: 0,
        lastBalance: 145200,
      ),
      LinkedAccount(
        id: 'airtel',
        type: WalletType.airtel,
        provider: 'Airtel Money',
        maskedIdentifier: '+250 733 ··· 517 · *500#',
        simSlot: 1,
        lastBalance: 62300,
      ),
      LinkedAccount(
        id: 'bk',
        type: WalletType.bank,
        provider: 'Bank of Kigali',
        maskedIdentifier: 'Account ··8901',
        lastBalance: 40000,
      ),
      LinkedAccount(
        id: 'equity',
        type: WalletType.bank,
        provider: 'Equity Bank',
        maskedIdentifier: 'Balance, transfers, airtime',
        connected: false,
      ),
      LinkedAccount(
        id: 'imbank',
        type: WalletType.bank,
        provider: 'I&M Bank',
        maskedIdentifier: 'Balance, transfers, airtime',
        connected: false,
      ),
      LinkedAccount(
        id: 'ecobank',
        type: WalletType.bank,
        provider: 'Ecobank',
        maskedIdentifier: 'Balance, transfers, airtime',
        connected: false,
      ),
    ]);

final recentTransactionsProvider = Provider<List<Transaction>>((ref) => const [
      Transaction(
        id: 't1',
        direction: TxDirection.sent,
        amount: 3500,
        counterpartyName: 'Kigali Coffee Roasters',
        category: 'MoMo Pay',
        timeLabel: '11:24',
        initials: 'KC',
      ),
      Transaction(
        id: 't2',
        direction: TxDirection.sent,
        amount: 10000,
        counterpartyName: 'EUCL electricity token',
        category: 'Meter ··4123',
        timeLabel: '09:02',
        initials: 'EU',
      ),
      Transaction(
        id: 't3',
        direction: TxDirection.received,
        amount: 25000,
        counterpartyName: 'Alexis K.',
        category: 'Received',
        timeLabel: 'Yesterday',
        initials: 'AK',
      ),
      Transaction(
        id: 't4',
        direction: TxDirection.sent,
        amount: 15000,
        counterpartyName: 'Canal+ renewal',
        category: 'Subscription',
        timeLabel: 'Yesterday',
        initials: 'C+',
      ),
    ]);

final contactsProvider = Provider<List<Contact>>((ref) => const [
      Contact(name: 'UWASE Marie Claire', msisdn: '+250 788 412 903', network: 'MTN'),
      Contact(name: 'Alexis KAYIRANGA', msisdn: '+250 733 208 517', network: 'Airtel'),
      Contact(name: 'Diane NIYONIZEYE', msisdn: '+250 786 554 120', network: 'MTN'),
      Contact(name: 'Eric KWIZERA', msisdn: '+250 791 337 264', network: 'MTN'),
      Contact(name: 'Jean Bosco M.', msisdn: '+250 728 990 431', network: 'Airtel'),
    ]);

final ikiminaMembersProvider = Provider<List<IkiminaMember>>((ref) => const [
      IkiminaMember(name: 'You', statusLabel: 'Paid 2 July', paid: true),
      IkiminaMember(name: 'Alexis K.', statusLabel: 'Paid 1 July', paid: true),
      IkiminaMember(name: 'Jean Bosco M.', statusLabel: 'Reminder sent yesterday', paid: false),
      IkiminaMember(name: 'Claudine U.', statusLabel: 'Reminder sent yesterday', paid: false),
    ]);

final splitParticipantsProvider = Provider<List<SplitParticipant>>((ref) => const [
      SplitParticipant(name: 'You', sub: 'Paid the bill', share: 0, covered: true),
      SplitParticipant(name: 'Alexis K.', sub: 'Airtel · request via app', share: 6000),
      SplitParticipant(name: 'Diane N.', sub: 'MTN · request via app', share: 6000),
      SplitParticipant(name: 'Eric K.', sub: 'MTN · request via SMS', share: 6000),
    ]);

final householdProvider = Provider<List<HouseholdMember>>((ref) => const [
      HouseholdMember(name: 'Sam M.', statusLabel: 'Paid 14 Jan · receipt saved', covered: true),
      HouseholdMember(name: 'Josiane U.', statusLabel: 'Paid 14 Jan · receipt saved', covered: true),
      HouseholdMember(name: 'Thierry M.', statusLabel: 'Paid 2 Feb · receipt saved', covered: true),
      HouseholdMember(name: 'Aline N.', statusLabel: 'Not yet paid for 2026', covered: false),
    ]);

/// Weekly spend bars for the activity chart (fractions of max).
final weeklySpendProvider = Provider<List<(String, double)>>((ref) => const [
      ('Mon', .34),
      ('Tue', .58),
      ('Wed', .22),
      ('Thu', .70),
      ('Fri', .44),
      ('Sat', .88),
      ('Sun', .52),
    ]);
