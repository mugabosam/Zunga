import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';
import '../send/send_flow_state.dart';

/// Pay hub — every real service, each one ending in a dialer hand-off.
class PayHubScreen extends ConsumerWidget {
  const PayHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    void dial(String code) => ref.read(ussdEngineProvider).launchUssd(code);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            PageTitleBar(l.pay),
            GroupLabel(l.moneyMovement, topPadding: 4),
            RowGroup(children: [
              BillRow(
                icon: Icons.arrow_forward,
                title: l.sendToMobile,
                subtitle: '*182*1*1# same network · *182*1*2# cross-network',
                onTap: () {
                  ref.read(sendFlowProvider.notifier).setTarget(PayTarget.phoneNumber);
                  context.push('/send');
                },
              ),
              BillRow(
                icon: Icons.storefront_outlined,
                title: l.payMerchant,
                subtitle: 'MoMo Pay · *182*8*1#',
                onTap: () {
                  ref.read(sendFlowProvider.notifier).setTarget(PayTarget.merchantCode);
                  context.push('/send');
                },
              ),
              BillRow(
                icon: Icons.account_balance_outlined,
                title: l.bankTransferEkash,
                subtitle: 'Any bank ↔ any wallet, fee capped at 20 RWF',
                onTap: () => context.push('/bank-transfer'),
              ),
              BillRow(
                icon: Icons.south_outlined,
                title: l.withdrawCash,
                subtitle: 'Agent withdrawal via your carrier menu',
                onTap: () => dial(mtnMenuRoot),
              ),
            ]),
            GroupLabel(l.billsUtilities),
            RowGroup(children: [
              BillRow(
                icon: Icons.receipt_long_outlined,
                title: '${l.electricity} · Water · TV · Airtime',
                subtitle: 'EUCL, WASAC, Canal+, DStv, StarTimes, bundles',
                onTap: () => context.push('/bills'),
              ),
            ]),
            GroupLabel(l.government),
            RowGroup(children: [
              BillRow(
                icon: Icons.account_balance_outlined,
                title: 'Irembo · RRA · Mutuelle · School fees',
                subtitle: 'Pay with your reference via the carrier menu',
                onTap: () => context.push('/government'),
              ),
            ]),
            GroupLabel('Codes'),
            RowGroup(children: [
              BillRow(
                icon: Icons.dialpad,
                title: 'eKash access codes',
                subtitle: 'All banks and wallets on the national rail',
                onTap: () => context.push('/accounts'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
