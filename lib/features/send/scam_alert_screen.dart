import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'send_flow_state.dart';

/// Screen 20 — Scam alert interstitial. "Cancel" is always the primary
/// action (§6.8); continuing is deliberately the quiet option.
class ScamAlertScreen extends ConsumerWidget {
  const ScamAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final flow = ref.watch(sendFlowProvider);

    return Scaffold(
      appBar: zAppBar(context, title: l.reviewTransfer),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: Column(
              children: [
                Text(l.youAreSending,
                    style: const TextStyle(fontSize: 13, color: ZTokens.ink2, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: rwf(flow.amount),
                    style: ZText.amount(40),
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
                const SizedBox(height: 6),
                Text(
                  '${l.to.toLowerCase()} ${flow.recipientMsisdn ?? ''} · ${flow.recipientNetwork == 'MTN' ? 'MTN MoMo' : 'Airtel Money'}',
                  style: const TextStyle(fontSize: 13.5, color: ZTokens.ink2),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ZTokens.ink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 22),
                ),
                Text(
                  l.numberReported,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Zunga users flagged this number for the "accidental overpayment refund" scam. The registered name also doesn\'t match any of your contacts.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 18),
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                  ),
                  child: Row(
                    children: [
                      _stat(l.reportsThisMonth, '14'),
                      const SizedBox(width: 20),
                      _stat(l.pattern, 'Refund request'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
            child: Column(
              children: [
                FilledButton(
                  onPressed: () {
                    ref.read(sendFlowProvider.notifier).reset();
                    context.go('/home');
                  },
                  child: Text(l.cancelThisTransfer),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.pushReplacement('/send/success'),
                  style: OutlinedButton.styleFrom(foregroundColor: ZTokens.ink2),
                  child: Text(l.continueAnyway),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.55))),
        Text(value,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }
}
