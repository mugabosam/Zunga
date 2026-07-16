import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 21 — Merchant mode: income dashboard, RRA-ready records.
/// The monetization wedge; consumer app stays free forever.
class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});

  static const _bars = [
    ('Mon', .52),
    ('Tue', .64),
    ('Wed', .40),
    ('Thu', .74),
    ('Fri', .58),
    ('Sat', .92),
    ('Sun', .66),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kiosk ya Sam', style: ZText.pageTitle),
            const Text('Merchant mode · MoMo Pay 048812',
                style: TextStyle(fontSize: 12, color: ZTokens.ink3)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 24),
            child: ZBackButton(icon: Icons.download_outlined),
          ),
        ],
        toolbarHeight: 64,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    children: [
                      Expanded(child: _stat(l.salesToday, rwf(184500))),
                      const SizedBox(width: 12),
                      Expanded(child: _stat(l.payments, '27')),
                    ],
                  ),
                ),
                ZCard(
                  margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.thisWeek.toUpperCase(),
                                  style: ZText.groupLabel
                                      .copyWith(letterSpacing: 0.72)),
                              const SizedBox(height: 6),
                              Text.rich(
                                TextSpan(
                                  text: rwf(1092300),
                                  style: ZText.amount(24),
                                  children: const [
                                    TextSpan(
                                      text: ' RWF',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: ZTokens.ink3,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: ZTokens.accentTint,
                              borderRadius:
                                  BorderRadius.circular(ZTokens.radiusPill),
                            ),
                            child: const Text(
                              '+8% vs last week',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ZTokens.accent),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 80,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var i = 0; i < _bars.length; i++) ...[
                              if (i > 0) const SizedBox(width: 12),
                              Expanded(
                                child: _bar(_bars[i].$1, _bars[i].$2,
                                    i == _bars.length - 1),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.paymentsReceived,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(l.seeAll,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ZTokens.accent)),
                    ],
                  ),
                ),
                RowGroup(children: const [
                  TxRow(
                      initials: '··',
                      title: '+250 788 ··· 441',
                      subtitle: 'MoMo Pay · 13:02',
                      amountRwf: '4,500',
                      incoming: true),
                  TxRow(
                      initials: '··',
                      title: '+250 733 ··· 118',
                      subtitle: 'MoMo Pay · 12:47',
                      amountRwf: '12,000',
                      incoming: true),
                  TxRow(
                      initials: '··',
                      title: '+250 786 ··· 902',
                      subtitle: 'MoMo Pay · 12:31',
                      amountRwf: '7,800',
                      incoming: true),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
            child: OutlinedButton(
              onPressed: () {},
              child: Text(l.exportStatement),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return ZCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: ZTokens.ink3)),
          const SizedBox(height: 6),
          Text(value, style: ZText.amount(22)),
        ],
      ),
    );
  }

  Widget _bar(String label, double height, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: height,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: active ? ZTokens.accent : ZTokens.line,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: ZTokens.ink3)),
      ],
    );
  }
}
