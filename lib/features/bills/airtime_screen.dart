import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 14 — Airtime & bundles with auto top-up schedules.
class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  int _tab = 0;
  int _amountIndex = 1;
  bool _weekly = true;
  bool _lowBalance = false;

  static const _amounts = [500, 1000, 2000, 5000];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: zAppBar(context, title: l.airtimeBundles),
      body: Column(
        children: [
          SegControl(
            options: [l.airtime, l.bundles],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                GroupLabel('For'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                  child: Row(
                    children: [
                      const AvatarBox('SM', size: 44),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('My number',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          Text('+250 788 412 903 · MTN',
                              style:
                                  TextStyle(fontSize: 12.5, color: ZTokens.ink3)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      for (var i = 0; i < _amounts.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _amountIndex = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: i == _amountIndex
                                    ? ZTokens.ink
                                    : ZTokens.surface,
                                border: Border.all(
                                    color: i == _amountIndex
                                        ? ZTokens.ink
                                        : ZTokens.line),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                rwf(_amounts[i]),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: ZTokens.numFeatures,
                                  color: i == _amountIndex
                                      ? Colors.white
                                      : ZTokens.ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GroupLabel(l.autoTopUp, topPadding: 26),
                RowGroup(children: [
                  _toggleRow(
                    'Weekly airtime',
                    'Every Monday · 2,000 RWF · from MoMo',
                    _weekly,
                    (v) => setState(() => _weekly = v),
                  ),
                  _toggleRow(
                    'Low-balance top-up',
                    'When airtime drops below 100 RWF',
                    _lowBalance,
                    (v) => setState(() => _lowBalance = v),
                  ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
            child: FilledButton(
              onPressed: () {},
              child: Text('Buy ${rwf(_amounts[_amountIndex])} RWF airtime'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(
      String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ZText.rowTitle),
                Text(sub, style: ZText.rowSub),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
