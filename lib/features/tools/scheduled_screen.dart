import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 17 — Scheduled payments & reminders. Execution ALWAYS requires
/// the user's PIN — reminders and prepared payments only, no silent sends.
class ScheduledScreen extends StatelessWidget {
  const ScheduledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: zAppBar(
        context,
        title: l.scheduled,
        trailing: const ZBackButton(icon: Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          RailNote(
            l.scheduleNote,
            icon: Icons.schedule_outlined,
            margin: const EdgeInsets.fromLTRB(24, 4, 24, 0),
          ),
          GroupLabel(l.comingUp, topPadding: 18),
          RowGroup(children: [
            _row('Ikimina · Abadahigwa', '20,000 RWF · 25th monthly · MoMo',
                trailing: const Text('in 11 days',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: ZTokens.accent))),
            _row('Rent · Kimironko', '150,000 RWF · 1st monthly · Bank of Kigali',
                trailing: _when('1 Aug')),
            _row('Canal+ Évasion', '15,000 RWF · monthly renewal',
                trailing: _when('16 Jul')),
          ]),
          GroupLabel(l.reminders),
          RowGroup(children: [
            _row('School fees · Term 1', 'Reference GS-2214 · via BK',
                trailing: _when('5 Sep')),
            _row('Mutuelle de Santé 2027', 'Household of 4 · 12,000 RWF total',
                trailing: _when('Dec')),
          ]),
        ],
      ),
    );
  }

  static Widget _when(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ZTokens.ink2,
          fontFeatures: ZTokens.numFeatures,
        ),
      );

  Widget _row(String title, String sub, {required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ZText.rowTitle),
                Text(sub,
                    style: ZText.rowSub.copyWith(
                        fontFeatures: ZTokens.numFeatures)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
