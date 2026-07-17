import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_data.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';

/// Bills — a directory of real services. Each row opens the carrier
/// menu in the dialer; deep one-tap codes per biller are added to the
/// signed config as they are verified on a live SIM.
class BillsHubScreen extends ConsumerWidget {
  const BillsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    void dial(String code) => ref.read(ussdEngineProvider).launchUssd(code);

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
              subtitle: 'Cash power token via the MoMo menu',
              onTap: () => dial(mtnMenuRoot),
            ),
            BillRow(
              icon: Icons.water_drop_outlined,
              title: 'Water · WASAC',
              subtitle: 'Pay via the MoMo menu',
              onTap: () => dial(mtnMenuRoot),
            ),
          ]),
          GroupLabel(l.television),
          RowGroup(children: [
            BillRow(
              icon: Icons.tv_outlined,
              title: 'Canal+ · DStv · StarTimes',
              subtitle: 'Pay via the MoMo menu',
              onTap: () => dial(mtnMenuRoot),
            ),
          ]),
          GroupLabel(l.airtimeBundles),
          RowGroup(children: [
            BillRow(
              icon: Icons.smartphone_outlined,
              title: 'MTN airtime & bundles',
              subtitle: mtnMenuRoot,
              onTap: () => dial(mtnMenuRoot),
            ),
            BillRow(
              icon: Icons.smartphone_outlined,
              title: 'Airtel airtime & bundles',
              subtitle: airtelMenuRoot,
              onTap: () => dial(airtelMenuRoot),
            ),
          ]),
          GroupLabel(l.government),
          RowGroup(children: [
            BillRow(
              icon: Icons.account_balance_outlined,
              title: 'Irembo · RRA · Mutuelle · School fees',
              subtitle: 'Pay via the MoMo menu with your reference',
              onTap: () => dial(mtnMenuRoot),
            ),
          ]),
          const RailNote(
            'Each row opens your dialer on the carrier menu. One-tap deep codes per biller ship remotely as they are confirmed on real SIMs — no app update needed.',
            icon: Icons.info_outline,
            margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
          ),
        ],
      ),
    );
  }
}
