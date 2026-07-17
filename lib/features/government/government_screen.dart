import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_data.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';

/// Government & social — a real service directory. Every payment ends in
/// the carrier's own menu with the user's reference number.
class GovernmentScreen extends ConsumerWidget {
  const GovernmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    void dial(String code) => ref.read(ussdEngineProvider).launchUssd(code);

    return Scaffold(
      appBar: zAppBar(context, title: l.governmentSocial),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          GroupLabel(l.healthInsurance, topPadding: 8),
          RowGroup(children: [
            BillRow(
              icon: Icons.favorite_outline,
              title: l.mutuelle,
              subtitle: 'Pay per household member via the MoMo menu',
              onTap: () => dial(mtnMenuRoot),
            ),
          ]),
          GroupLabel('Irembo'),
          RowGroup(children: [
            BillRow(
              icon: Icons.badge_outlined,
              title: 'Traffic fines · certificates · permits',
              subtitle: 'Pay your Irembo reference via the MoMo menu',
              onTap: () => dial(mtnMenuRoot),
            ),
          ]),
          GroupLabel('Taxes & education'),
          RowGroup(children: [
            BillRow(
              icon: Icons.description_outlined,
              title: 'RRA taxes',
              subtitle: 'Pay a declaration by reference',
              onTap: () => dial(mtnMenuRoot),
            ),
            BillRow(
              icon: Icons.school_outlined,
              title: 'School fees',
              subtitle: 'Pay via bank or MoMo reference',
              onTap: () => dial(mtnMenuRoot),
            ),
          ]),
          const RailNote(
            'Have your reference number ready — the carrier menu asks for it. '
            'One-tap deep codes ship remotely once verified on real SIMs.',
            icon: Icons.info_outline,
            margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
          ),
        ],
      ),
    );
  }
}
