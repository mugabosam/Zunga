import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';

/// In-app legal pages. Self-contained — no external redirects.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zAppBar(context, title: 'Privacy Policy'),
      body: const _LegalBody(sections: _privacySections),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zAppBar(context, title: 'Terms of Service'),
      body: const _LegalBody(sections: _termsSections),
    );
  }
}

class _LegalBody extends StatelessWidget {
  const _LegalBody({required this.sections});

  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        for (final (title, body) in sections) ...[
          if (title.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: ZTokens.ink),
              ),
            ),
          ],
          ZCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(18),
            child: Text(
              body,
              style: const TextStyle(
                  fontSize: 13, color: ZTokens.ink2, height: 1.65),
            ),
          ),
        ],
      ],
    );
  }
}

const _privacySections = <(String, String)>[
  (
    '',
    'Effective 18 July 2026. Governed by Rwanda Law No. 058/2021 relating '
        'to the protection of personal data and privacy.'
  ),
  (
    'What Zunga is',
    'Zunga initiates USSD sessions on your SIM. Transactions are executed '
        'by your mobile network or bank inside their own session. Zunga is '
        'not a payment service provider and does not hold funds.'
  ),
  (
    'Data stored on this device',
    'Your registered number, saved recipients, groups, business profile '
        'and transaction records are stored in encrypted storage on this '
        'phone only. Contact lookups run on the device against your own '
        'contact list. None of this data is transmitted to any server.'
  ),
  (
    'Your PIN',
    'Your mobile money or bank PIN is entered exclusively in your '
        'network\'s own dialog. Zunga cannot read, store or transmit it.'
  ),
  (
    'Network use',
    'The app operates offline. No analytics, no tracking, no advertising '
        'identifiers. If an online name-verification service is introduced, '
        'it will transmit only the recipient number over an encrypted '
        'connection, and this policy will be updated before activation.'
  ),
  (
    'Permissions',
    'Phone — to run the USSD codes you approve. Contacts (optional) — to '
        'display recipient names before you pay. Phone state — to detect '
        'the SIMs in this phone. Each permission can be declined; related '
        'features degrade without affecting payments.'
  ),
  (
    'Your rights',
    'All preferences can be disabled in Settings. "Delete my data" '
        'permanently removes every record from this phone. Your carrier '
        'and bank accounts are unaffected. For access or correction '
        'requests, contact support from the Settings screen.'
  ),
];

const _termsSections = <(String, String)>[
  (
    '',
    'Effective 18 July 2026. By using Zunga you accept these terms.'
  ),
  (
    'Service',
    'Zunga prepares and initiates USSD codes on your SIM. Every '
        'transaction is executed and settled by your mobile network or '
        'bank, authorized solely by your PIN entered in their own dialog.'
  ),
  (
    'Fees',
    'Zunga charges nothing on transactions. All fees displayed or applied '
        'in a session belong to your network, your bank, or eKash.'
  ),
  (
    'Your responsibilities',
    'Verify the recipient in your network\'s confirmation step before '
        'entering your PIN. Keep your PIN confidential — Zunga will never '
        'request it. Use only SIM cards registered in your name.'
  ),
  (
    'Codes',
    'USSD codes are published by networks and banks and may change '
        'without notice. Zunga updates them remotely, but your network\'s '
        'session is authoritative. A transaction is only complete when '
        'your network confirms it.'
  ),
  (
    'Liability',
    'Zunga is provided as is. It is not liable for network failures, '
        'downtime, or transfers you confirmed with your PIN. Nothing in '
        'these terms limits rights under Rwandan consumer protection law.'
  ),
  (
    'Data',
    'Your data remains on your phone as described in the Privacy Policy. '
        'Deleting your data ends the relationship; no account exists on '
        'any server.'
  ),
  (
    'Changes',
    'Material changes to these terms are announced in the app before '
        'taking effect.'
  ),
];
