import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/profile.dart';
import '../../core/data/sample_data.dart';
import '../../core/data/transactions.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';

/// Activity — the relocated wallet overview plus the honest ledger:
/// confirmed transactions feed the totals; sends still awaiting their
/// USSD success string or carrier SMS wear a grey "unconfirmed" badge.
/// Nothing phantom, nothing fake (§2.1).
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final wallet = ref.watch(activeWalletProvider);
    final myNumber = ref.watch(myNumberProvider);
    final confirmed = ref.watch(confirmedTxProvider);
    final pending = ref.watch(awaitingResolutionProvider);
    final stats = ref.watch(lifetimeStatsProvider);

    return Scaffold(
      appBar: zAppBar(context, title: l.activity),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            // Relocated wallet overview: no invented balances — balance
            // is an on-demand USSD check, straight from the carrier.
            ZCard(
              radius: ZTokens.radiusCard,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MY WALLETS',
                      style: ZText.groupLabel.copyWith(letterSpacing: 0.72)),
                  const SizedBox(height: 14),
                  _walletRow(
                    ref,
                    initials: 'M',
                    name: 'MTN MoMo',
                    active: wallet == 'MTN',
                    number: wallet == 'MTN' ? myNumber : null,
                    code: mtnBalanceCode,
                  ),
                  const Divider(height: 22),
                  _walletRow(
                    ref,
                    initials: 'A',
                    name: 'Airtel Money',
                    active: wallet == 'Airtel',
                    number: wallet == 'Airtel' ? myNumber : null,
                    code: airtelBalanceCode,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 18),
                    padding: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: ZTokens.lineSoft)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _stat('Sent (confirmed)',
                              '${rwf(stats.sent)} RWF'),
                        ),
                        Expanded(
                          child: _stat('Transactions', '${stats.count}×'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (pending.isNotEmpty) ...[
              GroupLabel('Awaiting confirmation'),
              RowGroup(children: [
                for (final t in pending) _pendingRow(context, ref, t),
              ]),
            ],
            GroupLabel('Confirmed'),
            if (confirmed.isEmpty)
              ZCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: const [
                    Icon(Icons.receipt_long_outlined,
                        size: 28, color: ZTokens.ink3),
                    SizedBox(height: 10),
                    Text(
                      'No confirmed payments yet',
                      style: TextStyle(fontSize: 13, color: ZTokens.ink2),
                    ),
                  ],
                ),
              )
            else
              RowGroup(children: [
                for (final t in confirmed)
                  TxRow(
                    initials: _initials(t),
                    title: t.counterpartyName ?? _masked(t.msisdn),
                    subtitle: '${t.network} · ${_when(t.createdAt)}',
                    amountRwf: rwf(t.amount),
                  ),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _walletRow(
    WidgetRef ref, {
    required String initials,
    required String name,
    required bool active,
    required String? number,
    required String code,
  }) {
    return Row(
      children: [
        AvatarBox(initials, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w600)),
                  if (active) ...[
                    const SizedBox(width: 8),
                    const StatusPill('Active'),
                  ],
                ],
              ),
              if (number != null)
                Text('··${number.substring(number.length - 3)}',
                    style: ZText.rowSub),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => ref.read(ussdEngineProvider).launchUssd(code),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ZTokens.accentTint,
              borderRadius: BorderRadius.circular(ZTokens.radiusPill),
            ),
            child: const Text(
              'Balance',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ZTokens.accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pendingRow(BuildContext context, WidgetRef ref, TxRecord t) {
    return BillRow(
      leading: AvatarBox(_initials(t), size: 42),
      title: t.counterpartyName ?? _masked(t.msisdn),
      subtitle: '${rwf(t.amount)} RWF · ${_when(t.createdAt)}',
      showChevron: false,
      trailing: const StatusPill('Unconfirmed', kind: PillKind.wait),
      onTap: () => _resolveSheet(context, ref, t),
    );
  }

  Future<void> _resolveSheet(
      BuildContext context, WidgetRef ref, TxRecord t) async {
    final action = await showModalBottomSheet<TxStatus>(
      context: context,
      backgroundColor: ZTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                '${rwf(t.amount)} RWF to ${t.counterpartyName ?? _masked(t.msisdn)}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Did your network confirm this payment? Check the popup '
                'result or the confirmation SMS.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: ZTokens.ink2, height: 1.5),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.pop(sheet, TxStatus.confirmed),
                child: const Text('Yes — I got the confirmation'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(sheet, TxStatus.failed),
                child: const Text('No — it failed or I cancelled'),
              ),
            ],
          ),
        ),
      ),
    );
    if (action != null) {
      await ref.read(transactionsProvider.notifier).setStatus(t.id, action);
    }
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: ZTokens.ink3)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFeatures: ZTokens.numFeatures)),
      ],
    );
  }

  String _initials(TxRecord t) {
    final n = t.counterpartyName;
    if (n == null || n.trim().isEmpty) return '··';
    return n
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  String _masked(String msisdn) {
    if (msisdn.length < 6) return msisdn;
    return '${msisdn.substring(0, 4)} ··· ${msisdn.substring(msisdn.length - 3)}';
  }

  String _when(DateTime dt) {
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (sameDay) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
