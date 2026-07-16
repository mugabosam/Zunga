import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The whole product in one file: turn what the user typed into the
/// right USSD dial string, then hand off to the phone dialer where the
/// carrier session asks for their PIN. Zunga never touches the money.
///
/// Codes (verified, July 2026):
///  - MTN → MTN:            *182*1*1#   (inline: *182*1*1*number*amount#)
///  - Cross-network (eKash): *182*1*2#   — works from ANY network
///  - MoMo Pay merchant:     *182*8*1#   (inline: *182*8*1*code#)
///  - Airtel Money menu:     *500#
enum PayTarget { phoneNumber, merchantCode }

enum SourceNetwork { mtn, airtel }

class SendFlowState {
  const SendFlowState({
    this.amount = 0,
    this.target = PayTarget.phoneNumber,
    this.source = SourceNetwork.mtn,
    this.recipientMsisdn = '',
    this.merchantCode = '',
  });

  final int amount;
  final PayTarget target;
  final SourceNetwork source;
  final String recipientMsisdn;
  final String merchantCode;

  String? get recipientNetwork => detectNetwork(recipientMsisdn);

  bool get isCrossNetwork {
    final to = recipientNetwork;
    if (to == null) return false;
    return (source == SourceNetwork.mtn) != (to == 'MTN');
  }

  /// The exact string handed to the dialer. Shown to the user verbatim
  /// before they press call.
  String get dialCode {
    if (target == PayTarget.merchantCode) {
      // MoMo Pay: signage format *182*8*1*code# pre-fills the code.
      return merchantCode.isEmpty ? '*182*8*1#' : '*182*8*1*$merchantCode#';
    }
    final digits = recipientMsisdn.replaceAll(RegExp(r'\D'), '');
    if (isCrossNetwork) {
      // eKash cross-network send — dialable from any network. The eKash
      // session asks for recipient and amount itself.
      return '*182*1*2#';
    }
    if (source == SourceNetwork.airtel) {
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
    return source == SourceNetwork.mtn ? 'MTN → MTN' : 'Airtel → Airtel';
  }

  SendFlowState copyWith({
    int? amount,
    PayTarget? target,
    SourceNetwork? source,
    String? recipientMsisdn,
    String? merchantCode,
  }) {
    return SendFlowState(
      amount: amount ?? this.amount,
      target: target ?? this.target,
      source: source ?? this.source,
      recipientMsisdn: recipientMsisdn ?? this.recipientMsisdn,
      merchantCode: merchantCode ?? this.merchantCode,
    );
  }
}

class SendFlowNotifier extends Notifier<SendFlowState> {
  @override
  SendFlowState build() => const SendFlowState();

  void setAmount(int amount) => state = state.copyWith(amount: amount);

  void setTarget(PayTarget target) => state = state.copyWith(target: target);

  void setSource(SourceNetwork source) => state = state.copyWith(source: source);

  void setNumber(String msisdn) => state = state.copyWith(recipientMsisdn: msisdn);

  void setMerchantCode(String code) => state = state.copyWith(merchantCode: code);

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
