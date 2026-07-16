import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'send_flow_state.dart';

/// Screen 03 — Send · amount.
class SendAmountScreen extends ConsumerStatefulWidget {
  const SendAmountScreen({super.key});

  @override
  ConsumerState<SendAmountScreen> createState() => _SendAmountScreenState();
}

class _SendAmountScreenState extends ConsumerState<SendAmountScreen> {
  String _digits = '';

  int get _amount => int.tryParse(_digits) ?? 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final flow = ref.watch(sendFlowProvider);
    final momo = ref
        .watch(linkedAccountsProvider)
        .firstWhere((a) => a.provider == flow.sourceProvider);

    return Scaffold(
      appBar: zAppBar(context, title: l.sendMoney),
      body: Column(
        children: [
          // Recipient chip
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.fromLTRB(8, 7, 16, 7),
            decoration: BoxDecoration(
              color: ZTokens.surface,
              border: Border.all(color: ZTokens.line),
              borderRadius: BorderRadius.circular(ZTokens.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarBox(
                  (flow.recipientName ?? flow.recipientMsisdn ?? '?')
                      .split(RegExp(r'\s+'))
                      .take(2)
                      .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
                      .join(),
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  flow.recipientName ?? flow.recipientMsisdn ?? '',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _digits.isEmpty ? '0' : rwf(_amount),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2.56,
                    fontFeatures: ZTokens.numFeatures,
                    color: _digits.isEmpty ? ZTokens.ink3 : ZTokens.ink,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'RWF',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: ZTokens.ink3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: ZTokens.surface,
                    border: Border.all(color: ZTokens.line),
                    borderRadius: BorderRadius.circular(ZTokens.radiusPill),
                  ),
                  child: Text(
                    '${l.from} ${momo.provider} · ${rwf(momo.lastBalance ?? 0)} RWF',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ZTokens.ink2,
                      fontFeatures: ZTokens.numFeatures,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ZKeypad(
            onDigit: (d) {
              if (_digits.length < 8) setState(() => _digits += d);
            },
            onBackspace: () {
              if (_digits.isNotEmpty) {
                setState(() => _digits = _digits.substring(0, _digits.length - 1));
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
            child: FilledButton(
              onPressed: _amount > 0
                  ? () {
                      ref.read(sendFlowProvider.notifier).setAmount(_amount);
                      context.push('/send/confirm');
                    }
                  : null,
              child: Text(l.continueLabel),
            ),
          ),
        ],
      ),
    );
  }
}
