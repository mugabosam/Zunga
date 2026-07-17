import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/profile.dart';
import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';
import '../send/send_flow_state.dart';

/// Screen 01 — keypad-first home. Calm, instant, thumb-reachable:
/// wallet badge on top, giant amount, keypad, Balance + Send. No
/// balance number, no feed — depth lives one tab away.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _digits = '';

  int get _amount => int.tryParse(_digits) ?? 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wallet = ref.watch(activeWalletProvider);
    final myNumber = ref.watch(myNumberProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: active wallet badge (tap to switch) + avatar.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _switchWallet(context, wallet),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 7, 14, 7),
                      decoration: BoxDecoration(
                        color: ZTokens.surface,
                        border: Border.all(color: ZTokens.line),
                        borderRadius: BorderRadius.circular(ZTokens.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AvatarBox(wallet == 'MTN' ? 'M' : 'A', size: 26),
                          const SizedBox(width: 8),
                          Text(
                            '${wallet == 'MTN' ? 'MTN MoMo' : 'Airtel Money'}'
                            '${myNumber == null ? '' : ' ··${myNumber.substring(myNumber.length - 3)}'}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFeatures: ZTokens.numFeatures),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.unfold_more,
                              size: 15, color: ZTokens.ink3),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: const AvatarBox('Z', size: 38, dark: true),
                  ),
                ],
              ),
            ),
            // Giant amount — 72px, tabular numerals, nothing else.
            Expanded(
              child: Center(
                child: Text.rich(
                  TextSpan(
                    text: _digits.isEmpty ? '0' : rwf(_amount),
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -2.88,
                      fontFeatures: ZTokens.numFeatures,
                      color: _digits.isEmpty ? ZTokens.ink3 : ZTokens.ink,
                    ),
                    children: const [
                      TextSpan(
                        text: ' RWF',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          color: ZTokens.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ZKeypad(
              onDigit: (d) {
                if (_digits.length < 8) setState(() => _digits += d);
              },
              onBackspace: () {
                if (_digits.isNotEmpty) {
                  setState(
                      () => _digits = _digits.substring(0, _digits.length - 1));
                }
              },
              onClear: () => setState(() => _digits = ''),
            ),
            // Balance (ghost, on-demand USSD — never auto-polled) + Send.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(ussdEngineProvider).launchUssd(
                          wallet == 'MTN' ? mtnBalanceCode : airtelBalanceCode),
                      icon: const Icon(Icons.credit_card_outlined, size: 18),
                      label: const Text('Balance'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _amount > 0
                          ? () {
                              ref
                                  .read(sendFlowProvider.notifier)
                                  .setAmount(_amount);
                              setState(() => _digits = '');
                              context.push('/send');
                            }
                          : null,
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      label: Text(l.send),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchWallet(BuildContext context, String current) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ZTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: ZTokens.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Pay from',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final w in const ['MTN', 'Airtel'])
              ListTile(
                leading: AvatarBox(w == 'MTN' ? 'M' : 'A', size: 40),
                title: Text(w == 'MTN' ? 'MTN MoMo' : 'Airtel Money',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                trailing: w == current
                    ? const Icon(Icons.check_circle,
                        color: ZTokens.accent, size: 20)
                    : null,
                onTap: () => Navigator.pop(sheet, w),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (choice != null && choice != current) {
      await ref.read(activeWalletProvider.notifier).switchTo(choice);
    }
  }
}
