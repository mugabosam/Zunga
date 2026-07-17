import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/profile.dart';
import '../../ussd/providers.dart';

/// The whole product in one file: turn what the user typed into the
/// right USSD dial string, run the session, and let the carrier's own
/// popup ask for the PIN. Zunga never touches the money.
///
/// Codes (verified, July 2026):
///  - MTN → MTN:            *182*1*1*number*amount#  (only the PIN left)
///  - Cross-network (eKash): *182*1*2#   — works from ANY network
///  - MoMo Pay merchant:     *182*8*1*code#
///  - Airtel → Airtel:       *500#  (Airtel Money menu)
enum PayTarget { phoneNumber, merchantCode }

enum SimNetwork { mtn, airtel }

class SendFlowState {
  const SendFlowState({
    this.amount = 0,
    this.target = PayTarget.phoneNumber,
    this.simNetworks = const {SimNetwork.mtn},
    this.recipientMsisdn = '',
    this.merchantCode = '',
  });

  final int amount;
  final PayTarget target;

  /// Networks of the SIMs actually in the phone, detected via
  /// SubscriptionManager — never asked from the user. Defaults to MTN
  /// (the majority network) until detection completes or when the
  /// READ_PHONE_STATE permission is missing.
  final Set<SimNetwork> simNetworks;
  final String recipientMsisdn;
  final String merchantCode;

  String? get recipientNetwork => detectNetwork(recipientMsisdn);

  /// Cross-network when no SIM in the phone matches the recipient's
  /// network — then eKash (*182*1*2#) is the route.
  bool get isCrossNetwork {
    return switch (recipientNetwork) {
      'MTN' => !simNetworks.contains(SimNetwork.mtn),
      'Airtel' => !simNetworks.contains(SimNetwork.airtel),
      _ => false,
    };
  }

  /// The exact session string. The user never sees it — they only meet
  /// the carrier's popup asking for their PIN.
  String get dialCode {
    if (target == PayTarget.merchantCode) {
      // MoMo Pay: signage format *182*8*1*code# pre-fills the code.
      return merchantCode.isEmpty ? '*182*8*1#' : '*182*8*1*$merchantCode#';
    }
    final digits = recipientMsisdn.replaceAll(RegExp(r'\D'), '');
    if (isCrossNetwork) {
      return '*182*1*2#';
    }
    if (recipientNetwork == 'Airtel') {
      // Airtel → Airtel goes through the Airtel Money menu.
      return '*500#';
    }
    // MTN → MTN inline shortcut leaves only the PIN to type.
    if (digits.isNotEmpty && amount > 0) {
      return '*182*1*1*$digits*$amount#';
    }
    return '*182*1*1#';
  }

  String get routeLabel {
    if (target == PayTarget.merchantCode) return 'MoMo Pay';
    if (isCrossNetwork) return 'via eKash';
    return recipientNetwork == 'Airtel' ? 'Airtel → Airtel' : 'MTN → MTN';
  }

  SendFlowState copyWith({
    int? amount,
    PayTarget? target,
    Set<SimNetwork>? simNetworks,
    String? recipientMsisdn,
    String? merchantCode,
  }) {
    return SendFlowState(
      amount: amount ?? this.amount,
      target: target ?? this.target,
      simNetworks: simNetworks ?? this.simNetworks,
      recipientMsisdn: recipientMsisdn ?? this.recipientMsisdn,
      merchantCode: merchantCode ?? this.merchantCode,
    );
  }
}

class SendFlowNotifier extends Notifier<SendFlowState> {
  @override
  SendFlowState build() {
    // The registered number (first-run setup) is the source of truth for
    // where money leaves from: its prefix decides the source network.
    final myNumber = ref.watch(myNumberProvider);
    final myNetwork = myNumber == null ? null : detectNetwork(myNumber);
    if (myNetwork == null) _detectSims();
    return SendFlowState(
      simNetworks: switch (myNetwork) {
        'MTN' => const {SimNetwork.mtn},
        'Airtel' => const {SimNetwork.airtel},
        _ => const {SimNetwork.mtn},
      },
    );
  }

  /// Fallback only — used when no number is registered (should not
  /// happen behind the /register gate, but never guess silently).
  Future<void> _detectSims() async {
    final sims = await ref.read(ussdEngineProvider).getSimAccounts();
    final networks = <SimNetwork>{};
    for (final sim in sims) {
      final carrier = sim.carrier.toLowerCase();
      if (carrier.contains('mtn')) networks.add(SimNetwork.mtn);
      if (carrier.contains('airtel')) networks.add(SimNetwork.airtel);
    }
    if (networks.isNotEmpty) {
      state = state.copyWith(simNetworks: networks);
    }
  }

  void setAmount(int amount) => state = state.copyWith(amount: amount);

  void setTarget(PayTarget target) => state = state.copyWith(target: target);

  void setNumber(String msisdn) => state = state.copyWith(recipientMsisdn: msisdn);

  void setMerchantCode(String code) => state = state.copyWith(merchantCode: code);

  void reset() => state = SendFlowState(simNetworks: state.simNetworks);
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
