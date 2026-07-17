import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';
import '../send/send_flow_state.dart';

/// Home — no balances, no fake numbers. Zunga is a shortcut layer: the
/// carriers hold the money, so home is your fastest route into their
/// menus without typing the * strings yourself.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.greeting('').replaceAll(', ', ''),
                          style: ZText.pageTitle),
                      const SizedBox(height: 2),
                      Text(
                        _dateLabel(),
                        style: const TextStyle(fontSize: 13, color: ZTokens.ink2),
                      ),
                    ],
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ZTokens.ink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Z',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            // Quick actions — each one runs the right code directly,
            // or is one tap away from it.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _quick(context, ref, Icons.arrow_forward, l.send,
                      onTap: () => context.push('/send')),
                  _quick(context, ref, Icons.qr_code, 'MoMo Pay',
                      onTap: () {
                    ref.read(sendFlowProvider.notifier).setTarget(PayTarget.merchantCode);
                    context.push('/send');
                  }),
                  _quick(context, ref, Icons.account_balance_outlined, 'eKash',
                      onTap: () => context.push('/bank-transfer')),
                  _quick(context, ref, Icons.dialpad, '*182#',
                      dial: mtnMenuRoot),
                ],
              ),
            ),
            GroupLabel('Your money menus', topPadding: 26),
            RowGroup(children: [
              BillRow(
                leading: const AvatarBox('M', size: 42),
                title: 'MTN MoMo',
                subtitle: 'Balance, send, withdraw — full menu',
                trailing: _dialPill(ref, mtnMenuRoot),
              ),
              BillRow(
                leading: const AvatarBox('A', size: 42),
                title: 'Airtel Money',
                subtitle: 'Balance, send, withdraw — full menu',
                trailing: _dialPill(ref, airtelMenuRoot),
              ),
              BillRow(
                leading: const AvatarBox('eK', size: 42),
                title: 'eKash · cross-network send',
                subtitle: 'Any network to any network',
                trailing: _dialPill(ref, '*182*1*2#'),
              ),
            ]),
            const RailNote(
              'Zunga only prepares the USSD codes you would dial yourself. '
              'Money moves inside your carrier session — your PIN is typed there, never here.',
              icon: Icons.lock_outline,
              margin: EdgeInsets.fromLTRB(24, 18, 24, 0),
            ),
            GroupLabel(l.recentActivity),
            ZCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  Icon(Icons.receipt_long_outlined, size: 28, color: ZTokens.ink3),
                  SizedBox(height: 10),
                  Text(
                    'Your payments will appear here once SMS tracking ships. '
                    'Until then, your carrier SMS is the record.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: ZTokens.ink2, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialPill(WidgetRef ref, String code) {
    return GestureDetector(
      onTap: () => ref.read(ussdEngineProvider).launchUssd(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ZTokens.accentTint,
          borderRadius: BorderRadius.circular(ZTokens.radiusPill),
        ),
        child: Text(
          code,
          style: const TextStyle(
            fontFamily: ZTokens.fontFamilyMono,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ZTokens.accent,
          ),
        ),
      ),
    );
  }

  Widget _quick(BuildContext context, WidgetRef ref, IconData icon, String label,
      {VoidCallback? onTap, String? dial}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap ?? () => ref.read(ussdEngineProvider).launchUssd(dial!),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ZTokens.surface,
                border: Border.all(color: ZTokens.line),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 22, color: ZTokens.ink),
            ),
            const SizedBox(height: 9),
            Text(label,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: ZTokens.ink2)),
          ],
        ),
      ),
    );
  }

  String _dateLabel() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}
