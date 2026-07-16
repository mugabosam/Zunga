import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 12 — eKash bank ↔ wallet transfer.
///
/// Since 14 July 2026 every domestic interoperable retail payment routes
/// through eKash (BNR Directive No. 45/2026): any bank to any wallet,
/// fee capped at 20 RWF, settlement in under 15 seconds.
class BankTransferScreen extends StatefulWidget {
  const BankTransferScreen({super.key});

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  final String _digits = '30000';

  int get _amount => int.tryParse(_digits) ?? 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: zAppBar(context, title: l.bankTransfer),
      body: Column(
        children: [
          Stack(
            children: [
              ZCard(
                child: Column(
                  children: [
                    _leg(l.from, 'BK', 'Bank of Kigali ··8901',
                        'Balance 40,000 RWF'),
                    const Divider(),
                    _leg(l.to, 'A', 'Alexis KAYIRANGA',
                        '+250 733 208 517 · Airtel Money'),
                  ],
                ),
              ),
              Positioned(
                right: 26,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ZTokens.surface,
                      border: Border.all(color: ZTokens.line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.swap_vert, size: 17, color: ZTokens.ink2),
                  ),
                ),
              ),
            ],
          ),
          RailNote(l.ekashRailNote),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(rwf(_amount), style: ZText.amount(56)),
                  const SizedBox(height: 10),
                  const Text(
                    'RWF',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: ZTokens.ink3),
                  ),
                ],
              ),
            ),
          ),
          ZCard(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 6),
            child: Column(
              children: [
                _drow(l.ekashFee, '20 RWF'),
                const Divider(),
                _drow(l.arrives, l.instantly),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
            child: FilledButton(
              onPressed: () {},
              child: Text(l.continueLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leg(String label, String initials, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      child: Row(
        children: [
          AvatarBox(initials, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: ZText.groupLabel.copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Text(sub, style: const TextStyle(fontSize: 12, color: ZTokens.ink3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: ZTokens.ink2)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFeatures: ZTokens.numFeatures)),
        ],
      ),
    );
  }
}
