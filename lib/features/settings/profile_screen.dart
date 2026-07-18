import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/data/profile.dart';
import '../../core/data/settings.dart';
import '../../core/data/transactions.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../send/send_flow_state.dart' show detectNetwork;

/// Screen 22 — Profile & settings, Faranga-grade completeness:
/// registered number, lifetime stats (confirmed-only), language,
/// privacy toggles, support, legal, delete-my-data. No app PIN by
/// design: Zunga holds no money and no secrets.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// App scheme first — opens the WhatsApp app directly; wa.me is the
  /// fallback when WhatsApp is not installed (shows its install page).
  static const _supportWhatsAppApp = 'whatsapp://send?phone=250728670972';
  static const _supportWhatsApp = 'https://wa.me/250728670972';
  // Real, resolvable pages — swap for zunga.rw once the domain is live.
  static const _privacyUrl =
      'https://github.com/mugabosam/Zunga/blob/main/PRIVACY.md';
  static const _termsUrl =
      'https://github.com/mugabosam/Zunga/blob/main/TERMS.md';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final myNumber = ref.watch(myNumberProvider);
    final settings = ref.watch(settingsProvider);
    final stats = ref.watch(lifetimeStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            PageTitleBar(l.profile),
            // Identity + lifetime stats (confirmed transactions only).
            ZCard(
              radius: ZTokens.radiusCard,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    myNumber == null ? 'Not registered' : _formatNumber(myNumber),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFeatures: ZTokens.numFeatures),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    myNumber == null
                        ? 'Register the number you pay from'
                        : detectNetwork(myNumber) ?? 'Unknown network',
                    style: ZText.rowSub,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.only(top: 14),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: ZTokens.lineSoft)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: _stat('Amount sent', rwf(stats.sent))),
                        Expanded(
                            child:
                                _stat('Transactions sent', '${stats.count}×')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GroupLabel('My number'),
            RowGroup(children: [
              BillRow(
                icon: Icons.sim_card_outlined,
                title: myNumber == null ? 'Register' : _formatNumber(myNumber),
                subtitle: 'Change the number you pay from',
                trailing: Text(l.change,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZTokens.accent)),
                onTap: () => context.push('/register'),
                showChevron: false,
              ),
            ]),
            GroupLabel(l.language),
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
            GroupLabel('Recipients'),
            RowGroup(children: [
              _toggle(
                ref,
                'Enable contacts',
                'Recipient suggestions from my contact list',
                settings.enableContacts,
                (v) => settings.copyWith(enableContacts: v),
              ),
              _toggle(
                ref,
                'Save most recent recipients',
                'One-tap repeat payments',
                settings.saveRecents,
                (v) => settings.copyWith(saveRecents: v),
              ),
            ]),
            GroupLabel('Transactions'),
            RowGroup(children: [
              _toggle(
                ref,
                'Save transactions',
                'Keep records of payments made via Zunga',
                settings.saveTransactions,
                (v) => settings.copyWith(saveTransactions: v),
              ),
            ]),
            GroupLabel('Notifications'),
            RowGroup(children: [
              _toggle(
                ref,
                'Enable notifications',
                'Reminders and payment updates',
                settings.notifications,
                (v) => settings.copyWith(notifications: v),
              ),
            ]),
            GroupLabel('Banks'),
            RowGroup(children: [
              BillRow(
                icon: Icons.account_balance_outlined,
                title: 'Banks & wallets',
                onTap: () => context.push('/accounts'),
              ),
            ]),
            GroupLabel('Help & support'),
            RowGroup(children: [
              BillRow(
                icon: Icons.chat_outlined,
                title: 'WhatsApp support',
                subtitle: 'Chat with us on WhatsApp',
                onTap: () => _openWhatsApp(context),
              ),
              BillRow(
                icon: Icons.share_outlined,
                title: 'Share the app',
                subtitle: 'Invite friends and family to Zunga',
                onTap: () => _open(context,
                    'https://wa.me/?text=${Uri.encodeComponent('Zunga — pay anyone in Rwanda without typing USSD codes. https://github.com/mugabosam/Zunga')}'),
              ),
            ]),
            GroupLabel('Legal'),
            RowGroup(children: [
              BillRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _open(context, _privacyUrl),
              ),
              BillRow(
                icon: Icons.description_outlined,
                title: 'Terms of service',
                onTap: () => _open(context, _termsUrl),
              ),
            ]),
            GroupLabel('Account'),
            RowGroup(children: [
              BillRow(
                icon: Icons.delete_outline,
                title: 'Delete my data',
                subtitle: 'Wipe recipients, transactions and my number from this phone',
                onTap: () => _confirmWipe(context, ref),
              ),
            ]),
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(
                child: Text('Zunga v0.1.0',
                    style: TextStyle(fontSize: 12, color: ZTokens.ink3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    try {
      // whatsapp:// can only be handled by the app itself.
      final ok = await launchUrl(Uri.parse(_supportWhatsAppApp),
          mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {
      // Not installed — fall through to the wa.me web fallback.
    }
    if (context.mounted) await _open(context, _supportWhatsApp);
  }

  Future<void> _open(BuildContext context, String url) async {
    // No canLaunchUrl gate: on Android 11+ it reports false negatives
    // unless every target app is declared; launching and catching is the
    // documented pattern.
    try {
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _couldNotOpen(context);
    } catch (_) {
      if (context.mounted) _couldNotOpen(context);
    }
  }

  void _couldNotOpen(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No app found to open this link')),
    );
  }

  Future<void> _confirmWipe(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: ZTokens.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete my data?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        content: const Text(
          'This wipes your registered number, saved recipients and the '
          'transaction ledger from this phone. Your money and carrier '
          'accounts are untouched — Zunga never held them.',
          style: TextStyle(fontSize: 13.5, color: ZTokens.ink2, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFB3261E))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(transactionsProvider.notifier).wipe();
    await Hive.deleteBoxFromDisk('recents');
    const storage = FlutterSecureStorageWrapper();
    await storage.wipeAll();
    if (context.mounted) context.go('/register');
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: ZTokens.ink3)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFeatures: ZTokens.numFeatures)),
      ],
    );
  }

  Widget _toggle(WidgetRef ref, String title, String sub, bool value,
      AppSettings Function(bool) apply) {
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
          Switch(
            value: value,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).update(apply(v)),
          ),
        ],
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

  String _formatNumber(String raw) {
    final b = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i == 4 || i == 7) b.write(' ');
      b.write(raw[i]);
    }
    return b.toString();
  }
}

/// Thin wrapper so the wipe path clears every secure-storage key
/// (number, active wallet, settings) in one call.
class FlutterSecureStorageWrapper {
  const FlutterSecureStorageWrapper();

  Future<void> wipeAll() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    await storage.deleteAll();
  }
}
