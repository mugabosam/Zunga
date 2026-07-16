import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 15 — Split a bill; friends without Zunga get an SMS fallback.
class SplitScreen extends ConsumerStatefulWidget {
  const SplitScreen({super.key});

  @override
  ConsumerState<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends ConsumerState<SplitScreen> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final people = ref.watch(splitParticipantsProvider);

    return Scaffold(
      appBar: zAppBar(context, title: l.splitABill),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                const Text('Total to split · Repub Lounge dinner',
                    style: TextStyle(
                        fontSize: 13,
                        color: ZTokens.ink2,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: rwf(24000),
                    style: ZText.amount(40),
                    children: const [
                      TextSpan(
                        text: ' RWF',
                        style: TextStyle(
                            fontSize: 15,
                            color: ZTokens.ink3,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SegControl(
            options: const ['Split equally', 'Custom amounts'],
            selected: _mode,
            onChanged: (i) => setState(() => _mode = i),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                GroupLabel('4 people · 6,000 RWF each', topPadding: 22),
                RowGroup(children: [
                  for (final p in people)
                    BillRow(
                      leading: AvatarBox(
                        p.name == 'You'
                            ? 'SM'
                            : p.name
                                .split(RegExp(r'\s+'))
                                .take(2)
                                .map((w) => w[0].toUpperCase())
                                .join(),
                        size: 40,
                      ),
                      title: p.name,
                      subtitle: p.sub,
                      trailing: p.covered
                          ? StatusPill(l.covered)
                          : Text(rwf(p.share), style: ZText.num14),
                    ),
                ]),
                RailNote(
                  "Friends without Zunga get an SMS with a prefilled MoMo request. You'll see who has paid you back.",
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
            child: FilledButton(
              onPressed: () {},
              child: const Text('Send 3 requests'),
            ),
          ),
        ],
      ),
    );
  }
}
