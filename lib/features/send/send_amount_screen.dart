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

}
