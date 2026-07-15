import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models.dart';

/// Routes a transfer can take. Same-network sends use the carrier tree;
/// anything cross-network or bank↔wallet rides eKash (*182*1*2#, the
/// national rail — verified July 2026, fee capped at 20 RWF).
enum TransferRoute { momoToMomo, airtelToAirtel, ekashCrossNetwork }

class SendFlowState {
  const SendFlowState({
    this.recipientName,
    this.recipientMsisdn,
    this.recipientNetwork,
    this.amount = 0,
    this.sourceProvider = 'MTN MoMo',
    this.scamReported = false,
  });

  final String? recipientName;
  final String? recipientMsisdn;
  final String? recipientNetwork;
  final int amount;
  final String sourceProvider;

  /// Set when the recipient number matches the scam DB (screen 20).
  final bool scamReported;

  TransferRoute get route {
    final fromMtn = sourceProvider.contains('MTN');
    final toMtn = recipientNetwork == 'MTN';
    if (fromMtn && toMtn) return TransferRoute.momoToMomo;
    if (!fromMtn && !toMtn && recipientNetwork == 'Airtel') {
      return TransferRoute.airtelToAirtel;
    }
    return TransferRoute.ekashCrossNetwork;
  }

  String get routeLabel => switch (route) {
        TransferRoute.momoToMomo => 'MoMo → MoMo',
        TransferRoute.airtelToAirtel => 'Airtel → Airtel',
        TransferRoute.ekashCrossNetwork => 'via eKash',
      };

  /// eKash interoperable fee is capped at 20 RWF (BNR Directive 45/2026);
  /// on-net carrier fees are tariff-table lookups — 100 RWF placeholder
  /// until the tariff table ships with the signed config.
  int get fee =>
      route == TransferRoute.ekashCrossNetwork ? 20 : (amount > 0 ? 100 : 0);

  SendFlowState copyWith({
    String? recipientName,
    String? recipientMsisdn,
    String? recipientNetwork,
    int? amount,
    String? sourceProvider,
    bool? scamReported,
  }) {
    return SendFlowState(
      recipientName: recipientName ?? this.recipientName,
      recipientMsisdn: recipientMsisdn ?? this.recipientMsisdn,
      recipientNetwork: recipientNetwork ?? this.recipientNetwork,
      amount: amount ?? this.amount,
      sourceProvider: sourceProvider ?? this.sourceProvider,
      scamReported: scamReported ?? this.scamReported,
    );
  }
}

class SendFlowNotifier extends Notifier<SendFlowState> {
  @override
  SendFlowState build() => const SendFlowState();

  void selectContact(Contact contact) {
    state = state.copyWith(
      recipientName: contact.name,
      recipientMsisdn: contact.msisdn,
      recipientNetwork: contact.network,
    );
  }

  void setManualNumber(String msisdn, {required String network}) {
    state = state.copyWith(
      recipientName: null,
      recipientMsisdn: msisdn,
      recipientNetwork: network,
    );
  }

  void setAmount(int amount) => state = state.copyWith(amount: amount);

  void reset() => state = const SendFlowState();
}

final sendFlowProvider =
    NotifierProvider<SendFlowNotifier, SendFlowState>(SendFlowNotifier.new);

/// Rwanda MSISDN prefix → network. 078/079 MTN, 072/073 Airtel.
String? detectNetwork(String msisdn) {
  final digits = msisdn.replaceAll(RegExp(r'\D'), '');
  final local = digits.startsWith('250') ? digits.substring(3) : digits;
  if (local.startsWith('78') || local.startsWith('79') ||
      local.startsWith('078') || local.startsWith('079')) {
    return 'MTN';
  }
  if (local.startsWith('72') || local.startsWith('73') ||
      local.startsWith('072') || local.startsWith('073')) {
    return 'Airtel';
  }
  return null;
}
