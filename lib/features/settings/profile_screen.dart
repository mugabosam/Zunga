import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/locale_provider.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Profile — language and app info. No app PIN: Zunga never holds money
/// or secrets, so there is nothing here worth locking. Your carrier PIN
/// lives with your carrier.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            PageTitleBar(l.profile),
            GroupLabel(l.language, topPadding: 8),
            ZCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _lang(ref, 'Kinyarwanda', 'rw', locale.languageCode),
                  const SizedBox(width: 8),
                  _lang(ref, 'English', 'en', locale.languageCode),
                  const SizedBox(width: 8),
                  _lang(ref, 'Français', 'fr', locale.languageCode),
                ],
              ),
            ),
            GroupLabel('Codes'),
            RowGroup(children: [
              BillRow(
                icon: Icons.dialpad,
                title: 'eKash access codes',
                subtitle: 'Every bank and wallet on the national rail',
                onTap: () => context.push('/accounts'),
              ),
            ]),
            GroupLabel('How Zunga works'),
            const RailNote(
              'Zunga prepares USSD codes so you never type the * strings yourself. '
              'It never holds money, never sees your PIN, and never charges on a transfer — '
              'the fees you see in a session are your carrier\'s or eKash\'s own.',
              icon: Icons.lock_outline,
              margin: EdgeInsets.fromLTRB(24, 4, 24, 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lang(WidgetRef ref, String label, String code, String current) {
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
}
