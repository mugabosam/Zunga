import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 16 — Ikimina group savings: round pot, whose turn, paid/pending.
class IkiminaScreen extends ConsumerWidget {
  const IkiminaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final members = ref.watch(ikiminaMembersProvider);

    return Scaffold(
      appBar: zAppBar(
        context,
        title: 'Abadahigwa',
        trailing: const ZBackButton(icon: Icons.more_vert),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ZCard(
                  radius: ZTokens.radiusCard,
                  margin: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THIS ROUND · PAYS OUT 28 JULY',
                          style: ZText.groupLabel.copyWith(letterSpacing: 0.72)),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: rwf(240000),
                          style: ZText.amount(34),
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: ZProgress(0.75)),
                          const SizedBox(width: 10),
                          Text('9 of 12 paid',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ZTokens.ink2,
                                fontFeatures: ZTokens.numFeatures,
                              )),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.only(top: 14),
                        decoration: const BoxDecoration(
                          border:
                              Border(top: BorderSide(color: ZTokens.lineSoft)),
                        ),
                        child: Row(
                          children: [
                            const AvatarBox('DN', size: 34, dark: true),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Diane N. receives this round',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                  Text('Your turn: round 7 · November',
                                      style: TextStyle(
                                          fontSize: 12, color: ZTokens.ink3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GroupLabel('${l.members} · 20,000 RWF monthly', topPadding: 22),
                RowGroup(children: [
                  for (final m in members)
                    BillRow(
                      leading: AvatarBox(
                        m.name == 'You'
                            ? 'SM'
                            : m.name
                                .split(RegExp(r'\s+'))
                                .take(2)
                                .map((w) => w[0].toUpperCase())
                                .join(),
                        size: 38,
                      ),
                      title: m.name,
                      subtitle: m.statusLabel,
                      trailing: StatusPill(
                        m.paid ? l.paid : l.pending,
                        kind: m.paid ? PillKind.ok : PillKind.wait,
                      ),
                    ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
            child: FilledButton(
              onPressed: () {},
              child: Text(l.remindPendingMembers),
            ),
          ),
        ],
      ),
    );
  }
}
