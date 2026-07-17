import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';
import 'send_flow_state.dart';

/// Send · step 2: phone number or MoMo Pay code. The network is
/// detected from the number, the contact name appears for a last check,
/// and Pay runs the USSD session directly — the carrier's own popup
/// asks for the PIN. No codes shown, no dialer detour.
class SendTargetScreen extends ConsumerStatefulWidget {
  const SendTargetScreen({super.key});

  @override
  ConsumerState<SendTargetScreen> createState() => _SendTargetScreenState();
}

class _SendTargetScreenState extends ConsumerState<SendTargetScreen> {
  String _number = '';
  String _code = '';
  String? _contactName;
  Timer? _lookupDebounce;

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    super.dispose();
  }

  void _onNumberChanged() {
    _lookupDebounce?.cancel();
    if (_number.length < 10) {
      setState(() => _contactName = null);
      return;
    }
    _lookupDebounce = Timer(const Duration(milliseconds: 250), () async {
      final name =
          await ref.read(ussdEngineProvider).lookupContactName(_number);
      if (mounted) setState(() => _contactName = name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final flow = ref.watch(sendFlowProvider);
    final isCode = flow.target == PayTarget.merchantCode;
    final detected = detectNetwork(_number);
    final canPay =
        isCode ? _code.length >= 4 : (_number.length == 10 && detected != null);
    final preview = flow.copyWith(recipientMsisdn: _number, merchantCode: _code);

    return Scaffold(
      appBar: zAppBar(context, title: '${l.pay} · ${rwf(flow.amount)} RWF'),
      body: Column(
        children: [
          SegControl(
            options: [l.phoneNumber, 'MoMo Pay code'],
            selected: isCode ? 1 : 0,
            onChanged: (i) => ref
                .read(sendFlowProvider.notifier)
                .setTarget(i == 0 ? PayTarget.phoneNumber : PayTarget.merchantCode),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 8),
                  child: Column(
                    children: [
                      Text(
                        (isCode ? 'MoMo Pay code' : l.recipientNumber).toUpperCase(),
                        style: ZText.groupLabel,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isCode
                            ? (_code.isEmpty ? '· · · · · ·' : _code)
                            : (_number.isEmpty ? '07•• ••• •••' : _formatNumber(_number)),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          fontFeatures: ZTokens.numFeatures,
                          color: (isCode ? _code : _number).isEmpty
                              ? ZTokens.ink3
                              : ZTokens.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCode && detected != null)
                  Center(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ZTokens.surface,
                        border: Border.all(color: ZTokens.line),
                        borderRadius: BorderRadius.circular(ZTokens.radiusPill),
                      ),
                      child: Text(
                        preview.isCrossNetwork
                            ? '$detected number · sent via eKash'
                            : '$detected number',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ZTokens.ink2),
                      ),
                    ),
                  ),
                // Who you are about to pay — change the number if this
                // isn't the person you meant.
                if (!isCode && _contactName != null)
                  AccentBanner(
                    hint: 'In your contacts',
                    title: _contactName!,
                    subtitle: _formatNumber(_number),
                    margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  ),
                if (!isCode && canPay && _contactName == null)
                  const RailNote(
                    'Not in your contacts. Double-check the number — the network will also show the registered name before you confirm with your PIN.',
                    icon: Icons.info_outline,
                    margin: EdgeInsets.fromLTRB(24, 18, 24, 0),
                  ),
              ],
            ),
          ),
          ZKeypad(
            onDigit: (d) => setState(() {
              if (isCode) {
                if (_code.length < 8) _code += d;
              } else if (_number.length < 10) {
                _number += d;
                _onNumberChanged();
              }
            }),
            onBackspace: () => setState(() {
              if (isCode) {
                if (_code.isNotEmpty) _code = _code.substring(0, _code.length - 1);
              } else if (_number.isNotEmpty) {
                _number = _number.substring(0, _number.length - 1);
                _onNumberChanged();
              }
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
            child: FilledButton(
              onPressed: canPay ? () => _pay(context) : null,
              child: Text('${l.pay} ${rwf(flow.amount)} RWF'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pay(BuildContext context) async {
    final notifier = ref.read(sendFlowProvider.notifier);
    notifier.setNumber(_number);
    notifier.setMerchantCode(_code);
    final flow = ref.read(sendFlowProvider);

    // Runs the session in place — the carrier popup takes over and asks
    // for the PIN. Falls back to the prefilled dialer only if the call
    // permission was just requested.
    await ref.read(ussdEngineProvider).launchUssd(flow.dialCode);

    if (!context.mounted) return;
    notifier.reset();
    context.go('/home');
  }

  String _formatNumber(String raw) {
    final b = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i == 4 || i == 7) b.write(' ');
      b.write(raw[i]);
    }
    return b.toString();
  }
}
