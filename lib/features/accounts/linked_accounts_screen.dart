import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';

/// The full eKash access-code directory — every bank and wallet on the
/// national rail, one tap from its own USSD entry point.
class LinkedAccountsScreen extends ConsumerWidget {
  const LinkedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final institutions = ref.watch(institutionsProvider);
    final wallets = institutions.where((i) => i.isWallet).toList();
    final banks = institutions.where((i) => !i.isWallet).toList();

    return Scaffold(
      appBar: zAppBar(context, title: 'eKash access codes'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          GroupLabel(l.mobileMoney, topPadding: 8),
          RowGroup(children: [
            for (final i in wallets) _row(ref, i),
          ]),
          GroupLabel(l.banksViaEkash),
          RowGroup(children: [
            for (final i in banks) _row(ref, i),
          ]),
          RailNote(
            l.pinNeverLeaves,
            icon: Icons.lock_outline,
            margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          ),
        ],
      ),
    );
  }

  Widget _row(WidgetRef ref, Institution i) {
    return BillRow(
      leading: AvatarBox(i.initials, size: 42),
      title: i.name,
      subtitle: i.code == null ? 'App only — no USSD code' : 'Tap the code to open your dialer',
      showChevron: false,
      trailing: i.code == null
          ? const StatusPill('App', kind: PillKind.wait)
          : GestureDetector(
              onTap: () => ref.read(ussdEngineProvider).dialManually(i.code!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ZTokens.accentTint,
                  borderRadius: BorderRadius.circular(ZTokens.radiusPill),
                ),
                child: Text(
                  i.code!,
                  style: const TextStyle(
                    fontFamily: ZTokens.fontFamilyMono,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ZTokens.accent,
                  ),
                ),
              ),
            ),
    );
  }
}
