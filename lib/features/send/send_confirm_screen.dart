import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../security/app_lock.dart';
import 'send_flow_state.dart';

/// Screen 04 — Review transfer: verified registered name, fee breakdown,
/// PIN sheet. The Zunga app PIN gates the action locally; the carrier
/// PIN is typed by the user into the carrier's own USSD dialog later.
class SendConfirmScreen extends ConsumerStatefulWidget {
  const SendConfirmScreen({super.key});

  @override
  ConsumerState<SendConfirmScreen> createState() => _SendConfirmScreenState();
}

class _SendConfirmScreenState extends ConsumerState<SendConfirmScreen> {
  String _pin = '';
  bool _checking = false;
  String? _error;

  Future<void> _onDigit(String d) async {
    if (_checking || _pin.length >= 4) return;
    setState(() => _pin += d);
    if (_pin.length == 4) {
      setState(() => _checking = true);
      final pinService = ref.read(pinServiceProvider);
      final hasPin = await pinService.hasPin();
      // First-run (no PIN yet) accepts any 4 digits in the Stage-1 demo
      // build; once onboarding stores a PIN, verification is enforced.
      final ok = !hasPin || await pinService.verifyPin(_pin);
      if (!mounted) return;
      if (ok) {
        final flow = ref.read(sendFlowProvider);
        context.pushReplacement(flow.scamReported ? '/send/scam-alert' : '/send/success');
      } else {
        setState(() {
          _pin = '';
          _checking = false;
          _error = 'Wrong PIN — try again';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final flow = ref.watch(sendFlowProvider);

    return Scaffold(
      appBar: zAppBar(context, title: l.reviewTransfer),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 6),
            child: Column(
              children: [
                Text(l.youAreSending,
                    style: const TextStyle(fontSize: 13, color: ZTokens.ink2, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: rwf(flow.amount),
                    style: ZText.amount(46),
                    children: const [
                      TextSpan(
                        text: ' RWF',
                        style: TextStyle(
                            fontSize: 16,
                            color: ZTokens.ink3,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AccentBanner(
            hint: l.registeredNameVerified,
            title: flow.recipientName ?? flow.recipientMsisdn ?? '',
            subtitle:
                '${flow.recipientMsisdn ?? ''} · ${flow.recipientNetwork == 'MTN' ? 'MTN MoMo' : 'Airtel Money'}',
            margin: const EdgeInsets.fromLTRB(24, 22, 24, 0),
          ),
          ZCard(
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                _row(l.amount, '${rwf(flow.amount)} RWF'),
                const Divider(),
                _row(l.transferFee, '${flow.fee} RWF'),
                const Divider(),
                _row(l.route, flow.routeLabel),
                const Divider(),
                _row(l.totalToPay, '${rwf(flow.amount + flow.fee)} RWF', bold: true),
              ],
            ),
          ),
          const Spacer(),
          // PIN sheet
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
            decoration: const BoxDecoration(
              color: ZTokens.surface,
              border: Border(top: BorderSide(color: ZTokens.line)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: ZTokens.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  _error ?? l.enterPinToConfirm,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _error != null
                        ? Theme.of(context).colorScheme.error
                        : ZTokens.ink,
                  ),
                ),
                const SizedBox(height: 20),
                PinDots(filled: _pin.length),
                const SizedBox(height: 4),
                ZKeypad(
                  onDigit: _onDigit,
                  onBackspace: () {
                    if (_pin.isNotEmpty) {
                      setState(() => _pin = _pin.substring(0, _pin.length - 1));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: ZTokens.ink2)),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15 : 14,
              fontWeight: FontWeight.w600,
              fontFeatures: ZTokens.numFeatures,
            ),
          ),
        ],
      ),
    );
  }
}
