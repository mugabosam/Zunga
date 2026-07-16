import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 18 — Government & social hub: Mutuelle, Irembo, RRA, school fees.
class GovernmentScreen extends StatefulWidget {
  const GovernmentScreen({super.key});

  @override
  State<GovernmentScreen> createState() => _GovernmentScreenState();
}

class _GovernmentScreenState extends State<GovernmentScreen> {
  bool _renewalReminder = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: zAppBar(context, title: l.governmentSocial),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          GroupLabel(l.healthInsurance, topPadding: 8),
          RowGroup(children: [
            BillRow(
              icon: Icons.favorite_outline,
              title: '${l.mutuelle} · 2026',
              subtitle: '3 of 4 family members paid · ',
              dueText: '1 unpaid',
              onTap: () => context.push('/government/mutuelle'),
            ),
            BillRow(
              icon: Icons.notifications_none,
              title: 'Renewal reminder',
              subtitle: 'Alert me 30 days before it lapses',
              trailing: Switch(
                value: _renewalReminder,
                onChanged: (v) => setState(() => _renewalReminder = v),
              ),
            ),
          ]),
          GroupLabel('Irembo'),
          RowGroup(children: [
            BillRow(
              icon: Icons.badge_outlined,
              title: 'Traffic fine',
              subtitle: 'Pay with plate or reference number',
              onTap: () {},
            ),
            BillRow(
              icon: Icons.account_balance_outlined,
              title: 'Certificates & permits',
              subtitle: 'Birth, marriage, land, driving test',
              onTap: () {},
            ),
          ]),
          GroupLabel('Taxes & education'),
          RowGroup(children: [
            BillRow(
              icon: Icons.description_outlined,
              title: 'RRA taxes',
              subtitle: 'Pay a declaration by reference',
              onTap: () {},
            ),
            BillRow(
              icon: Icons.school_outlined,
              title: 'School fees',
              subtitle: 'G.S. Kimironko · student ··2214 saved',
              onTap: () {},
            ),
          ]),
          const AccentBanner(
            title: 'Umwaka mushya, nta gihombo',
            subtitle:
                'Mutuelle reminders alone save families from lapsed coverage. We track every member, every year.',
          ),
        ],
      ),
    );
  }
}
