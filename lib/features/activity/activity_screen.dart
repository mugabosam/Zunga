import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Activity — honest empty state until on-device SMS tracking ships.
/// No fabricated charts, no fake transactions.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleBar(l.activity),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.bar_chart_outlined, size: 40, color: ZTokens.ink3),
                      SizedBox(height: 16),
                      Text(
                        'No tracked activity yet',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'When SMS tracking ships, your MoMo and Airtel Money '
                        'confirmations will be read on this phone only and '
                        'turned into a spending feed. Nothing leaves the device.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13.5, color: ZTokens.ink2, height: 1.55),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const RailNote(
              'Until then, your carrier SMS inbox is the authoritative record of every payment.',
              icon: Icons.info_outline,
              margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
            ),
          ],
        ),
      ),
    );
  }
}
