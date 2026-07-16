import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';
import 'send_flow_state.dart';

/// Send · step 2: phone number or MoMo Pay code, then hand off to the
/// phone dialer with the right USSD string prefilled. The user presses
/// call and types only their carrier PIN — Zunga never sees the money.
class SendTargetScreen extends ConsumerStatefulWidget {
  const SendTargetScreen({super.key});

  @override
  ConsumerState<SendTargetScreen> createState() => _SendTargetScreenState();
}

class _SendTargetScreenState extends ConsumerState<SendTargetScreen> {
  String _number = '';
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final flow = ref.watch(sendFlowProvider);
    final isCode = flow.target == PayTarget.merchantCode;
    final detected = detectNetwork(_number);
    final canPay = isCode ? _code.length >= 4 : (_number.length == 10 && detected != null);

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
                if (!isCode && detected != null) ...[
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
                        '$detected number detected',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ZTokens.ink2),
                      ),
                    ),
                  ),
                  if (flow.copyWith(recipientMsisdn: _number).isCrossNetwork)
                    AccentBanner(
                      title: l.crossNetworkViaEkash,
                      subtitle: l.ekashRouteExplainer(
                        flow.source == SourceNetwork.mtn ? 'MTN MoMo' : 'Airtel Money',
                        'a $detected number',
                      ),
                      margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                    ),
                ],
                RailNote(
                  l.manualFallbackHint,
                  icon: Icons.phone_outlined,
                  margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
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
              }
            }),
            onBackspace: () => setState(() {
              if (isCode) {
                if (_code.isNotEmpty) _code = _code.substring(0, _code.length - 1);
              } else if (_number.isNotEmpty) {
                _number = _number.substring(0, _number.length - 1);
              }
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
            child: FilledButton(
              onPressed: canPay ? () => _pay(context) : null,
              child: Text(
                canPay
                    ? '${l.pay} · ${flow.copyWith(recipientMsisdn: _number, merchantCode: _code).dialCode}'
                    : l.pay,
              ),
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
    final code = flow.dialCode;

    await ref.read(ussdEngineProvider).dialManually(code);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$code ready in your dialer — press call, then enter your PIN.'),
        duration: const Duration(seconds: 5),
      ),
    );
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
