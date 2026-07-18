import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/profile.dart';
import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/drawer.dart';
import '../../core/widgets/kit.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';
import '../send/send_flow_state.dart';

/// Screen 01 — keypad-first home. Navy gradient pay card, keypad,
/// Balance + Pay. Calm, instant, thumb-reachable.
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
      drawer: const ZungaDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: menu (opens the side drawer) + wallet pill.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: ZTokens.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: ZTokens.shadowSoft,
                        ),
                        child: const Icon(Icons.menu,
                            size: 20, color: ZTokens.navy),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _switchWallet(context, wallet),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                      decoration: BoxDecoration(
                        color: ZTokens.surface,
                        borderRadius: BorderRadius.circular(ZTokens.radiusPill),
                        boxShadow: ZTokens.shadowSoft,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ZTokens.navy,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              wallet == 'MTN' ? 'M' : 'A',
                              style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${wallet == 'MTN' ? 'MTN MoMo' : 'Airtel Money'}'
                            '${myNumber == null ? '' : ' ··${myNumber.substring(myNumber.length - 3)}'}',
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                fontFeatures: ZTokens.numFeatures),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 15, color: ZTokens.ink3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Navy gradient pay card.
            Container(
              margin: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 30),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: ZTokens.navyGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: ZTokens.shadow,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -70,
                    top: -80,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                          width: 28,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(ZTokens.radiusPill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: ZTokens.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                wallet == 'MTN' ? 'MTN' : 'Airtel',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: _digits.isEmpty ? '0' : rwf(_amount),
                            style: TextStyle(
                              fontSize: 58,
                              fontWeight: FontWeight.w600,
                              fontFeatures: ZTokens.numFeatures,
                              color: _digits.isEmpty
                                  ? Colors.white.withValues(alpha: 0.55)
                                  : Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: ' RWF',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ZKeypad(
                onDigit: (d) {
                  if (_digits.length < 8) setState(() => _digits += d);
                },
                onBackspace: () {
                  if (_digits.isNotEmpty) {
                    setState(() =>
                        _digits = _digits.substring(0, _digits.length - 1));
                  }
                },
                onClear: () => setState(() => _digits = ''),
              ),
            ),
            // Balance (ghost, on-demand USSD) + Pay (orange).
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref.read(ussdEngineProvider).launchUssd(
                          wallet == 'MTN' ? mtnBalanceCode : airtelBalanceCode),
                      child: const Text('Balance'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(ZTokens.radiusButton),
                        boxShadow: _amount > 0 ? ZTokens.shadowAccent : null,
                      ),
                      child: FilledButton(
                        onPressed: _amount > 0
                            ? () {
                                ref
                                    .read(sendFlowProvider.notifier)
                                    .setAmount(_amount);
                                setState(() => _digits = '');
                                context.push('/send');
                              }
                            : null,
                        child: Text(l.pay),
                      ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
