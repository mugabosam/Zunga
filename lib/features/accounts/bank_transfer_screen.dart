import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';

/// Bank ↔ wallet via eKash: pick where your money sits, and Zunga opens
/// that institution's own eKash USSD entry point in your dialer. The
/// bank's session handles recipient, amount and PIN.
class BankTransferScreen extends ConsumerWidget {
  const BankTransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final banks = ref
        .watch(institutionsProvider)
        .where((i) => !i.isWallet && i.code != null)
        .toList();

    return Scaffold(
      appBar: zAppBar(context, title: l.bankTransfer),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          GroupLabel('From your wallet', topPadding: 8),
          RowGroup(children: [
            BillRow(
              leading: const AvatarBox('eK', size: 42),
              title: 'Wallet → any bank or wallet',
              onTap: () => ref.read(ussdEngineProvider).launchUssd('*182*1*2#'),
              trailing: const Icon(Icons.phone_outlined,
                  size: 18, color: ZTokens.accent),
            ),
          ]),
          GroupLabel('From your bank'),
          RowGroup(children: [
            for (final bank in banks)
              BillRow(
                leading: AvatarBox(bank.initials, size: 42),
                title: bank.name,
                onTap: () => ref.read(ussdEngineProvider).launchUssd(bank.code!),
                trailing: const Icon(Icons.phone_outlined,
                    size: 18, color: ZTokens.accent),
              ),
          ]),
        ],
      ),
    );
  }
}
