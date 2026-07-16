import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 09 — Pay hub: every service, grouped.
class PayHubScreen extends StatelessWidget {
  const PayHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                subtitle: 'MTN MoMo · Airtel Money',
                onTap: () => context.push('/send'),
              ),
              BillRow(
                icon: Icons.account_balance_outlined,
                title: l.bankTransferEkash,
                subtitle: 'Any bank ↔ any wallet, instant',
                onTap: () => context.push('/bank-transfer'),
              ),
              BillRow(
                icon: Icons.storefront_outlined,
                title: l.payMerchant,
                subtitle: 'MoMo Pay code · nearby suggestions',
                onTap: () => context.push('/merchant-pay'),
              ),
              BillRow(
                icon: Icons.south_outlined,
                title: l.withdrawCash,
                subtitle: 'Agent code, both carriers',
                onTap: () {},
              ),
            ]),
            GroupLabel(l.billsUtilities),
            RowGroup(children: [
              BillRow(
                icon: Icons.bolt_outlined,
                title: '${l.electricity} · Water · TV',
                subtitle: 'EUCL, WASAC, Canal+, DStv, StarTimes',
                onTap: () => context.push('/bills'),
              ),
              BillRow(
                icon: Icons.smartphone_outlined,
                title: l.airtimeBundles,
                subtitle: 'Auto top-up available',
                onTap: () => context.push('/airtime'),
              ),
            ]),
            GroupLabel(l.government),
            RowGroup(children: [
              BillRow(
                icon: Icons.account_balance_outlined,
                title: 'Irembo · RRA · Mutuelle · School fees',
                subtitle: 'Fines, taxes, health insurance, fees',
                onTap: () => context.push('/government'),
              ),
            ]),
            GroupLabel(l.tools),
            RowGroup(children: [
              BillRow(
                icon: Icons.call_split_outlined,
                title: l.splitABill,
                subtitle: 'Share costs, request from friends',
                onTap: () => context.push('/split'),
              ),
              BillRow(
                icon: Icons.schedule_outlined,
                title: l.ikimina,
                subtitle: 'Group savings, rounds & reminders',
                onTap: () => context.push('/ikimina'),
              ),
              BillRow(
                icon: Icons.event_outlined,
                title: l.scheduledPayments,
                subtitle: 'Rent, fees, subscriptions',
                onTap: () => context.push('/scheduled'),
              ),
              BillRow(
                icon: Icons.bar_chart_outlined,
                title: l.merchantMode,
                subtitle: 'Income tracking, RRA-ready records',
                onTap: () => context.push('/merchant'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
