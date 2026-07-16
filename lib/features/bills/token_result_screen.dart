import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../l10n/app_localizations.dart';

/// Screen 06 — Electricity token result. Token is copyable and rendered
/// in IBM Plex Mono, as every token/reference in the system.
class TokenResultScreen extends StatelessWidget {
  const TokenResultScreen({super.key});

  static const _token = '1284 5901 7736 4482 0159';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 10),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: ZTokens.accentTint,
                      border: Border.all(color: ZTokens.accentBorder),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 26, color: ZTokens.accent),
                  ),
                  Text(l.tokenPurchased,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  const Text(
                    'Meter ··4123 · Kimironko, KG 11 Ave',
                    style: TextStyle(fontSize: 13.5, color: ZTokens.ink2),
                  ),
                ],
              ),
            ),
            ZCard(
              margin: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(l.enterTokenOnMeter.toUpperCase(),
                      style: ZText.groupLabel.copyWith(fontSize: 11.5)),
                  const SizedBox(height: 14),
                  const Text(
                    '1284 5901\n7736 4482 0159',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: ZTokens.fontFamilyMono,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      height: 1.65,
                      letterSpacing: 0.48,
                    ),
                  ),
                ],
              ),
            ),
            ZCard(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  _meta(l.energy, '42.3 kWh'),
                  _divider(),
                  _meta(l.amount, '10,000 RWF'),
                  _divider(),
                  _meta(l.vatIncl, '1,525 RWF'),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () async {
                      await Clipboard.setData(
                          const ClipboardData(text: _token));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Token copied')),
                        );
                      }
                    },
                    child: Text(l.copyToken),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: Text(l.shareReceipt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11.5, color: ZTokens.ink3, fontWeight: FontWeight.w500)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFeatures: ZTokens.numFeatures)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 46, color: ZTokens.lineSoft);
}
