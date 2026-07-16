import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 05 — Bills hub.
class BillsHubScreen extends StatelessWidget {
  const BillsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: zAppBar(context, title: l.payABill),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          GroupLabel(l.utilities, topPadding: 8),
          RowGroup(children: [
            BillRow(
              icon: Icons.bolt_outlined,
              title: '${l.electricity} · EUCL',
              subtitle: 'Meter ··4123 · usual 10,000 RWF',
              onTap: () => context.push('/bills/token'),
            ),
            BillRow(
              icon: Icons.water_drop_outlined,
              title: 'Water · WASAC',
              subtitle: '8,240 RWF outstanding · ',
              dueText: 'due in 5 days',
              onTap: () {},
            ),
          ]),
          GroupLabel(l.television),
          RowGroup(children: [
            BillRow(
              icon: Icons.tv_outlined,
              title: 'Canal+',
              subtitle: 'Évasion bouquet · ',
              dueText: 'expires in 2 days',
              onTap: () {},
            ),
            BillRow(
              icon: Icons.tv_outlined,
              title: 'DStv / GOtv',
              subtitle: 'Add a smartcard number',
              onTap: () {},
            ),
            BillRow(
              icon: Icons.tv_outlined,
              title: 'StarTimes',
              subtitle: 'Add a smartcard number',
              onTap: () {},
            ),
          ]),
          GroupLabel(l.government),
          RowGroup(children: [
            BillRow(
              icon: Icons.account_balance_outlined,
              title: 'Irembo services',
              subtitle: 'Fines, permits, certificates',
              onTap: () => context.push('/government'),
            ),
            BillRow(
              icon: Icons.description_outlined,
              title: 'RRA taxes',
              subtitle: 'Declare and pay with reference',
              onTap: () => context.push('/government'),
            ),
            BillRow(
              icon: Icons.favorite_outline,
              title: l.mutuelle,
              subtitle: 'Household 2026 · ',
              dueText: '1 member pending',
              onTap: () => context.push('/government/mutuelle'),
            ),
            BillRow(
              icon: Icons.school_outlined,
              title: 'School fees',
              subtitle: 'Pay via bank or MoMo reference',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }
}
