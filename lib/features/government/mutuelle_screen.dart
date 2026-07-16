import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 19 — Mutuelle de Santé household tracker with per-member
/// status and December renewal reminders.
class MutuelleScreen extends ConsumerWidget {
  const MutuelleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final members = ref.watch(householdProvider);

    return Scaffold(
      appBar: zAppBar(context, title: l.mutuelle),
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
                      Text('HOUSEHOLD · 2026 COVERAGE',
                          style: ZText.groupLabel.copyWith(letterSpacing: 0.72)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('3 of 4', style: ZText.amount(34)),
                          const SizedBox(width: 10),
                          const Text('members covered',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ZTokens.ink2)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: ZProgress(0.75)),
                          const SizedBox(width: 10),
                          Text('9,000 / 12,000 RWF',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ZTokens.ink2,
                                fontFeatures: ZTokens.numFeatures,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                GroupLabel('${l.members} · 3,000 RWF each per year',
                    topPadding: 22),
                RowGroup(children: [
                  for (final m in members)
                    BillRow(
                      leading: AvatarBox(
                        m.name
                            .split(RegExp(r'\s+'))
                            .take(2)
                            .map((w) => w[0].toUpperCase())
                            .join(),
                        size: 38,
                      ),
                      title: m.name,
                      subtitle: m.statusLabel,
                      trailing: StatusPill(
                        m.covered ? l.covered : l.pending,
                        kind: m.covered ? PillKind.ok : PillKind.wait,
                      ),
                    ),
                ]),
                const RailNote(
                  "We'll remind you each December before the new coverage year, so no one in the household is left out.",
                  icon: Icons.schedule_outlined,
                  margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
            child: FilledButton(
              onPressed: () {},
              child: const Text('Pay 3,000 RWF for Aline'),
            ),
          ),
        ],
      ),
    );
  }
}
