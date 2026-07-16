import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/models.dart';
import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../l10n/app_localizations.dart';

/// Screen 01 — Home dashboard.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final accounts = ref
        .watch(linkedAccountsProvider)
        .where((a) => a.connected && a.lastBalance != null)
        .toList();
    final txs = ref.watch(recentTransactionsProvider);
    final total = accounts.fold<int>(0, (sum, a) => sum + (a.lastBalance ?? 0));
    final name = ref.watch(userNameProvider).split(' ').first;

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
                      Text(l.greeting(name), style: ZText.pageTitle),
                      const SizedBox(height: 2),
                      Text(
                        _dateLabel(),
                        style: const TextStyle(fontSize: 13, color: ZTokens.ink2),
                      ),
                    ],
                  ),
                  const AvatarBox('SM', dark: true),
                ],
              ),
            ),
            // Balance card
            ZCard(
              radius: ZTokens.radiusCard,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.totalBalance.toUpperCase(),
                      style: ZText.groupLabel.copyWith(letterSpacing: 0.72)),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      text: rwf(total),
                      style: ZText.amount(40),
                      children: const [
                        TextSpan(
                          text: ' RWF',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: ZTokens.ink3,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.only(top: 18),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: ZTokens.lineSoft)),
                    ),
                    child: Row(
                      children: [
                        for (final a in accounts)
                          Expanded(child: _wallet(a)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Quick actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Row(
                children: [
                  _quick(context, Icons.arrow_forward, l.send, '/send'),
                  _quick(context, Icons.receipt_long_outlined, l.payBill, '/bills'),
                  _quick(context, Icons.bolt_outlined, l.electricity, '/bills'),
                  _quick(context, Icons.smartphone_outlined, l.airtime, '/airtime'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.recentActivity,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => context.go('/activity'),
                    child: Text(
                      l.seeAll,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ZTokens.accent),
                    ),
                  ),
                ],
              ),
            ),
            RowGroup(
              children: [
                for (final t in txs)
                  TxRow(
                    initials: t.avatarInitials,
                    title: t.counterpartyName,
                    subtitle: '${t.category} · ${t.timeLabel}',
                    amountRwf: rwf(t.amount),
                    incoming: t.direction == TxDirection.received,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _wallet(LinkedAccount a) {
    final dot = switch (a.provider) {
      'MTN MoMo' => 'M',
      'Airtel Money' => 'A',
      _ => 'BK',
    };
    final label = switch (a.provider) {
      'MTN MoMo' => 'MTN MoMo',
      'Airtel Money' => 'Airtel',
      _ => 'Bank ··8901',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: ZTokens.line),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(dot,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: ZTokens.ink2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(rwf(a.lastBalance ?? 0),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFeatures: ZTokens.numFeatures)),
      ],
    );
  }

  Widget _quick(BuildContext context, IconData icon, String label, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
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
