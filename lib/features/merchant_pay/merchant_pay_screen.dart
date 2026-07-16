import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 11 — Pay merchant: MoMo Pay code entry + nearby + frequent.
class MerchantPayScreen extends StatelessWidget {
  const MerchantPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: zAppBar(context, title: l.payMerchant),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: ZTokens.surface,
              border: Border.all(color: ZTokens.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code, size: 18, color: ZTokens.ink3),
                SizedBox(width: 10),
                Text('Enter MoMo Pay code',
                    style: TextStyle(fontSize: 15, color: ZTokens.ink3)),
              ],
            ),
          ),
          GroupLabel('Nearby · Kimironko'),
          RowGroup(children: [
            BillRow(
              leading: const AvatarBox('KC', size: 42),
              title: 'Kigali Coffee Roasters',
              subtitle: 'Code 018 765 · 40 m away · paid before',
              onTap: () {},
            ),
            BillRow(
              leading: const AvatarBox('SP', size: 42),
              title: 'Simba Supermarket',
              subtitle: 'Code 022 401 · 120 m away',
              onTap: () {},
            ),
            BillRow(
              leading: const AvatarBox('PH', size: 42),
              title: 'Kimironko Pharmacy',
              subtitle: 'Code 031 118 · 200 m away',
              onTap: () {},
            ),
          ]),
          GroupLabel('Frequent'),
          RowGroup(children: [
            BillRow(
              leading: const AvatarBox('MT', size: 42),
              title: "Moto · Jean d'Amour",
              subtitle: 'Code 077 902 · paid 14 times',
              onTap: () {},
            ),
            BillRow(
              leading: const AvatarBox('RS', size: 42),
              title: 'Repub Lounge',
              subtitle: 'Code 045 330 · paid 6 times',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }
}
