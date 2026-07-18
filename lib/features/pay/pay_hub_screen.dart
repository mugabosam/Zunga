import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';

/// Pay hub — every real service, each one ending in a dialer hand-off.
class PayHubScreen extends ConsumerWidget {
  const PayHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    void dial(String code) => ref.read(ussdEngineProvider).launchUssd(code);

    return Scaffold(
      appBar: zAppBar(context, title: l.pay),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            GroupLabel(l.moneyMovement, topPadding: 4),
            RowGroup(children: [
              BillRow(
                icon: Icons.arrow_forward,
                title: l.sendToMobile,
                subtitle: 'MTN MoMo · Airtel Money',
                onTap: () => context.push('/send'),
              ),
              BillRow(
                icon: Icons.storefront_outlined,
                title: l.payMerchant,
                subtitle: 'MoMo Pay',
                onTap: () => context.push('/send'),
              ),
              BillRow(
                icon: Icons.account_balance_outlined,
                title: l.bankTransferEkash,
                subtitle: 'Any bank ↔ any wallet',
                onTap: () => context.push('/bank-transfer'),
              ),
              BillRow(
                icon: Icons.south_outlined,
                title: l.withdrawCash,
                subtitle: 'Agent code',
                onTap: () => dial(mtnMenuRoot),
              ),
            ]),
            GroupLabel(l.billsUtilities),
            RowGroup(children: [
              BillRow(
                icon: Icons.receipt_long_outlined,
                title: '${l.electricity} · Water · TV · Airtime',
                onTap: () => context.push('/bills'),
              ),
            ]),
            GroupLabel(l.government),
            RowGroup(children: [
              BillRow(
                icon: Icons.account_balance_outlined,
                title: 'Irembo · RRA · Mutuelle · School fees',
                onTap: () => context.push('/government'),
              ),
            ]),
            GroupLabel(l.tools),
            RowGroup(children: [
              BillRow(
                icon: Icons.call_split,
                title: l.splitABill,
                onTap: () => context.push('/split'),
              ),
              BillRow(
                icon: Icons.groups_outlined,
                title: l.ikimina,
                onTap: () => context.push('/ikimina'),
              ),
              BillRow(
                icon: Icons.bar_chart_outlined,
                title: l.merchantMode,
                onTap: () => context.push('/merchant'),
              ),
            ]),
            GroupLabel('Banks'),
            RowGroup(children: [
              BillRow(
                icon: Icons.account_balance_outlined,
                title: 'Banks & wallets',
                onTap: () => context.push('/accounts'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
