import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Screen 22 — Profile: language, security toggles, merchant mode.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometrics = true;
  bool _scamProtection = true;
  bool _nameCheck = true;
  bool _merchantMode = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final name = ref.watch(userNameProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            PageTitleBar(l.profile),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 18),
              child: Row(
                children: [
                  const AvatarBox('SM', size: 54, dark: true),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.17)),
                      const SizedBox(height: 2),
                      const Text('+250 788 412 903 · Kigali',
                          style:
                              TextStyle(fontSize: 12.5, color: ZTokens.ink3)),
                    ],
                  ),
                ],
              ),
            ),
            GroupLabel(l.language, topPadding: 0),
            ZCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _lang('Kinyarwanda', 'rw', locale.languageCode),
                  const SizedBox(width: 8),
                  _lang('English', 'en', locale.languageCode),
                  const SizedBox(width: 8),
                  _lang('Français', 'fr', locale.languageCode),
                ],
              ),
            ),
            GroupLabel(l.security),
            RowGroup(children: [
              BillRow(
                showChevron: false,
                leading: const SizedBox.shrink(),
                title: l.appPin,
                subtitle: l.requiredForEveryPayment,
                trailing: Text(l.change,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZTokens.ink2)),
                onTap: () => context.push('/onboarding/pin'),
              ),
              _toggle(l.unlockWithFingerprint, l.openWithBiometrics,
                  _biometrics, (v) => setState(() => _biometrics = v)),
              _toggle(l.scamProtection, l.warnReportedNumbers,
                  _scamProtection, (v) => setState(() => _scamProtection = v)),
              _toggle(l.nameCheckBeforeSending, l.alwaysShowRegisteredName,
                  _nameCheck, (v) => setState(() => _nameCheck = v)),
            ]),
            GroupLabel(l.business),
            RowGroup(children: [
              _toggle(l.merchantMode, 'Kiosk ya Sam · MoMo Pay 048812',
                  _merchantMode, (v) => setState(() => _merchantMode = v)),
            ]),
            GroupLabel(l.linkedAccounts),
            RowGroup(children: [
              BillRow(
                icon: Icons.account_balance_wallet_outlined,
                title: l.linkedAccounts,
                subtitle: 'MTN MoMo, Airtel Money, Bank of Kigali',
                onTap: () => context.push('/accounts'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _lang(String label, String code, String current) {
    final on = code == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(localeProvider.notifier).set(Locale(code)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? ZTokens.accentTint : ZTokens.surface,
            border: Border.all(color: on ? ZTokens.accent : ZTokens.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: on ? ZTokens.accent : ZTokens.ink2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle(
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
