import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../l10n/app_localizations.dart';
import 'send_flow_state.dart';

/// Screen 08 — Payment success.
class SendSuccessScreen extends ConsumerWidget {
  const SendSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final flow = ref.watch(sendFlowProvider);
    final ref_ = _reference();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    margin: const EdgeInsets.only(bottom: 26),
                    decoration: const BoxDecoration(
                      color: ZTokens.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 38, color: Colors.white),
                  ),
                  Text(l.moneySent,
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text: rwf(flow.amount),
                      style: ZText.amount(44),
                      children: const [
                        TextSpan(
                          text: ' RWF',
                          style: TextStyle(
                            fontSize: 16,
                            color: ZTokens.ink3,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text: '${l.to.toLowerCase()} ',
                      style: const TextStyle(fontSize: 14.5, color: ZTokens.ink2),
                      children: [
                        TextSpan(
                          text: flow.recipientName ?? flow.recipientMsisdn ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: ZTokens.ink),
                        ),
                        TextSpan(
                          text: flow.route == TransferRoute.ekashCrossNetwork
                              ? ' · via eKash'
                              : ' · ${flow.recipientNetwork == 'MTN' ? 'MTN MoMo' : 'Airtel Money'}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      text: '${l.reference} · ',
                      style: const TextStyle(fontSize: 12.5, color: ZTokens.ink3),
                      children: [TextSpan(text: ref_, style: ZText.mono)],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
              child: Column(
                children: [
                  OutlinedButton(onPressed: () {}, child: Text(l.shareReceipt)),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () {
                      ref.read(sendFlowProvider.notifier).reset();
                      context.go('/home');
                    },
                    child: Text(l.done),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _reference() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
    final rnd = Random();
    final tail = List.generate(5, (_) => chars[rnd.nextInt(chars.length)]).join();
    final now = DateTime.now();
    final ymd =
        '${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return 'ZG-$ymd-$tail';
  }
}
