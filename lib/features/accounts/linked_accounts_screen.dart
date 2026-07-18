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
      appBar: zAppBar(context, title: 'Banks & wallets'),
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
        ],
      ),
    );
  }

  Widget _row(WidgetRef ref, Institution i) {
    return BillRow(
      leading: AvatarBox(i.initials, size: 42),
      title: i.name,
      showChevron: false,
      onTap: i.code == null
          ? null
          : () => ref.read(ussdEngineProvider).launchUssd(i.code!),
      trailing: i.code == null
          ? const StatusPill('App', kind: PillKind.wait)
          : const Icon(Icons.phone_outlined, size: 18, color: ZTokens.accent),
    );
  }
}
