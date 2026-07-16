import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 07 — Activity & insights: weekly bar chart + grouped feed.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final bars = ref.watch(weeklySpendProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            PageTitleBar(l.activity),
            ZCard(
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
                          Text(l.spentThisWeek.toUpperCase(),
                              style: ZText.groupLabel.copyWith(letterSpacing: 0.72)),
                          const SizedBox(height: 6),
                          Text.rich(
                            TextSpan(
                              text: rwf(68400),
                              style: ZText.amount(28),
                              children: const [
                                TextSpan(
                                  text: ' RWF',
                                  style: TextStyle(
                                      fontSize: 14,
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
                          borderRadius: BorderRadius.circular(ZTokens.radiusPill),
                        ),
                        child: const Text(
                          '−12% vs last week',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ZTokens.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 110,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < bars.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(child: _bar(bars[i].$1, bars[i].$2, i == bars.length - 1)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GroupLabel('${l.today} · ${_todayLabel()}', topPadding: 22),
            RowGroup(children: const [
              TxRow(
                initials: 'KC',
                title: 'Kigali Coffee Roasters',
                subtitle: 'Food & drink · MoMo Pay',
                amountRwf: '3,500',
              ),
              TxRow(
                initials: 'EU',
                title: 'EUCL electricity token',
                subtitle: 'Utilities · Meter ··4123',
                amountRwf: '10,000',
              ),
            ]),
            GroupLabel(l.yesterday),
            RowGroup(children: const [
              TxRow(
                initials: 'AK',
                title: 'Alexis K.',
                subtitle: 'Transfer received',
                amountRwf: '25,000',
                incoming: true,
              ),
              TxRow(
                initials: 'C+',
                title: 'Canal+ renewal',
                subtitle: 'Subscriptions',
                amountRwf: '15,000',
              ),
              TxRow(
                initials: 'SP',
                title: 'Simba Supermarket',
                subtitle: 'Groceries · MoMo Pay',
                amountRwf: '22,700',
              ),
            ]),
          ],
        ),
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
                fontSize: 10.5, fontWeight: FontWeight.w500, color: ZTokens.ink3)),
      ],
    );
  }

  String _todayLabel() {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]}';
  }
}
