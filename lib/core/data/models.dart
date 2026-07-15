/// Domain models (§4). Persisted in AES-encrypted Hive boxes; the sample
/// repositories in sample_data.dart stand in until Stage 2 wiring.
library;

enum WalletType { momo, airtel, bank }

class LinkedAccount {
  const LinkedAccount({
    required this.id,
    required this.type,
    required this.provider,
    required this.maskedIdentifier,
    this.simSlot,
    this.lastBalance,
    this.connected = true,
  });

  final String id;
  final WalletType type;
  final String provider;
  final String maskedIdentifier;
  final int? simSlot;
  final int? lastBalance;
  final bool connected;
}

enum TxDirection { sent, received }

class Transaction {
  const Transaction({
    required this.id,
    required this.direction,
    required this.amount,
    required this.counterpartyName,
    required this.category,
    required this.timeLabel,
    this.initials,
    this.fee = 0,
  });

  final String id;
  final TxDirection direction;
  final int amount;
  final int fee;
  final String counterpartyName;
  final String category;
  final String timeLabel;
  final String? initials;

  String get avatarInitials =>
      initials ??
      counterpartyName
          .split(RegExp(r'\s+'))
          .take(2)
          .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
          .join();
}

class Contact {
  const Contact({
    required this.name,
    required this.msisdn,
    required this.network,
  });

  final String name;
  final String msisdn;
  final String network;

  String get initials => name
      .split(RegExp(r'\s+'))
      .take(2)
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
      .join();

  String get firstName => name.split(RegExp(r'\s+')).first;
}

class IkiminaMember {
  const IkiminaMember({required this.name, required this.statusLabel, required this.paid});

  final String name;
  final String statusLabel;
  final bool paid;
}

class SplitParticipant {
  const SplitParticipant({
    required this.name,
    required this.sub,
    required this.share,
    this.covered = false,
  });

  final String name;
  final String sub;
  final int share;
  final bool covered;
}

class HouseholdMember {
  const HouseholdMember({required this.name, required this.statusLabel, required this.covered});

  final String name;
  final String statusLabel;
  final bool covered;
}
