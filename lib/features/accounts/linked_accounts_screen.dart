import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models.dart';
import '../../core/data/sample_data.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 13 — Linked accounts & banks.
class LinkedAccountsScreen extends ConsumerWidget {
  const LinkedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final accounts = ref.watch(linkedAccountsProvider);
    final wallets = accounts.where((a) => a.type != WalletType.bank).toList();
    final banks = accounts.where((a) => a.type == WalletType.bank).toList();

    return Scaffold(
      appBar: zAppBar(context, title: l.linkedAccounts),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                GroupLabel(l.mobileMoney, topPadding: 8),
                RowGroup(children: [
                  for (final a in wallets) _accountRow(l, a),
                ]),
                GroupLabel(l.banksViaEkash),
                RowGroup(children: [
                  for (final a in banks) _accountRow(l, a),
                ]),
                RailNote(
                  l.pinNeverLeaves,
                  icon: Icons.lock_outline,
                  margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
            child: OutlinedButton(
              onPressed: () {},
              child: Text(l.addAnotherAccount),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountRow(AppLocalizations l, LinkedAccount a) {
    final initials = switch (a.provider) {
      'MTN MoMo' => 'M',
      'Airtel Money' => 'A',
      'Bank of Kigali' => 'BK',
      'Equity Bank' => 'EQ',
      'I&M Bank' => 'IM',
      _ => 'EC',
    };
    return BillRow(
      leading: AvatarBox(initials, size: 42),
      title: a.provider,
      subtitle: a.maskedIdentifier,
      trailing: StatusPill(
        a.connected ? l.connected : l.connect,
        kind: a.connected ? PillKind.ok : PillKind.connect,
      ),
    );
  }
}
