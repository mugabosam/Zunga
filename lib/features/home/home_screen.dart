import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Home — dark keypad-first surface: menu, amount card with the active
/// carrier, keypad, then a docked white bar with Balance and Pay.
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ZTokens.bg,
        drawer: const ZungaDrawer(),
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Menu button — opens the side drawer.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Builder(
                          builder: (context) => GestureDetector(
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: ZTokens.surface,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: ZTokens.navy, width: 1.5),
                              ),
                              child: const Icon(Icons.menu,
                                  size: 20, color: ZTokens.navy),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Amount card with the active carrier chip.
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      height: 240,
                      decoration: BoxDecoration(
                        gradient: ZTokens.navyGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: ZTokens.shadow,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 16,
                            right: 18,
                            child: GestureDetector(
                              onTap: () => _switchWallet(context, wallet),
                              child: Row(
                                children: [
                                  const Text('🇷🇼',
                                      style: TextStyle(fontSize: 15)),
                                  const SizedBox(width: 7),
                                  Text(
                                    wallet == 'MTN' ? 'MTN' : 'Airtel',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text.rich(
                                  TextSpan(
                                    text: _digits.isEmpty ? '0' : rwf(_amount),
                                    style: const TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: ZTokens.numFeatures,
                                      color: Colors.white,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' RWF',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Keypad — navy digits on the light surface.
                    Expanded(
                      child: ZKeypad(
                        onDigit: (d) {
                          if (_digits.length < 8) {
                            setState(() => _digits += d);
                          }
                        },
                        onBackspace: () {
                          if (_digits.isNotEmpty) {
                            setState(() => _digits =
                                _digits.substring(0, _digits.length - 1));
                          }
                        },
                        onClear: () => setState(() => _digits = ''),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Docked white action bar: Balance + Pay.
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x29232C63),
                    blurRadius: 24,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ref
                              .read(ussdEngineProvider)
                              .launchUssd(wallet == 'MTN'
                                  ? mtnBalanceCode
                                  : airtelBalanceCode),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            side: const BorderSide(
                                color: ZTokens.navy, width: 1.5),
                            foregroundColor: ZTokens.navy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.credit_card_outlined,
                              size: 19),
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
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_upward, size: 19),
                          label: Text(l.pay),
                        ),
                      ),
                    ],
                  ),
                ),
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
