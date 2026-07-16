import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'send_flow_state.dart';

/// Send · step 1: how much, and from which SIM.
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

    return Scaffold(
      appBar: zAppBar(context, title: l.sendMoney),
      body: Column(
        children: [
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
                const SizedBox(height: 18),
                // Sending from which SIM — decides *182*1*1# vs eKash.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _sourceChip(l, SourceNetwork.mtn, 'MTN MoMo', flow.source),
                    const SizedBox(width: 8),
                    _sourceChip(l, SourceNetwork.airtel, 'Airtel Money', flow.source),
                  ],
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
                      context.push('/send/target');
                    }
                  : null,
              child: Text(l.pay),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sourceChip(
      AppLocalizations l, SourceNetwork network, String label, SourceNetwork current) {
    final on = network == current;
    return GestureDetector(
      onTap: () => ref.read(sendFlowProvider.notifier).setSource(network),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: on ? ZTokens.ink : ZTokens.surface,
          border: Border.all(color: on ? ZTokens.ink : ZTokens.line),
          borderRadius: BorderRadius.circular(ZTokens.radiusPill),
        ),
        child: Text(
          '${l.from} $label',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: on ? Colors.white : ZTokens.ink2,
          ),
        ),
      ),
    );
  }
}
