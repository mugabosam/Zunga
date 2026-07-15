import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'send_flow_state.dart';

/// Screens 02 (contacts) and 10 (manual number + eKash route banner).
class SendRecipientScreen extends ConsumerStatefulWidget {
  const SendRecipientScreen({super.key});

  @override
  ConsumerState<SendRecipientScreen> createState() => _SendRecipientScreenState();
}

class _SendRecipientScreenState extends ConsumerState<SendRecipientScreen> {
  int _tab = 0;
  String _number = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final contacts = ref.watch(contactsProvider);
    final flow = ref.watch(sendFlowProvider);
    final detected = detectNetwork(_number);

    return Scaffold(
      appBar: zAppBar(context, title: l.sendMoney),
      body: Column(
        children: [
          SegControl(
            options: [l.contacts, l.enterNumber],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          if (_tab == 0)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: ZTokens.surface,
                      border: Border.all(color: ZTokens.line),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: ZTokens.ink3),
                        const SizedBox(width: 10),
                        Text(
                          l.searchNameOrPhone,
                          style: const TextStyle(fontSize: 15, color: ZTokens.ink3),
                        ),
                      ],
                    ),
                  ),
                  // Recents strip
                  SizedBox(
                    height: 92,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 2),
                      children: [
                        for (final c in contacts.take(5))
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                AvatarBox(c.initials, size: 52),
                                const SizedBox(height: 7),
                                Text(
                                  c.firstName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: ZTokens.ink2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  GroupLabel(l.allContacts, topPadding: 12),
                  for (final c in contacts)
                    InkWell(
                      onTap: () {
                        ref.read(sendFlowProvider.notifier).selectContact(c);
                        context.push('/send/amount');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          children: [
                            AvatarBox(c.initials, size: 44),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name,
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w600)),
                                Text('${c.msisdn} · ${c.network}',
                                    style: const TextStyle(
                                        fontSize: 12.5, color: ZTokens.ink3)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 34, 24, 8),
                    child: Column(
                      children: [
                        Text(l.recipientNumber.toUpperCase(), style: ZText.groupLabel),
                        const SizedBox(height: 12),
                        Text(
                          _number.isEmpty ? '07•• ••• •••' : _formatNumber(_number),
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            fontFeatures: ZTokens.numFeatures,
                            color: _number.isEmpty ? ZTokens.ink3 : ZTokens.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (detected != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ZTokens.surface,
                        border: Border.all(color: ZTokens.line),
                        borderRadius: BorderRadius.circular(ZTokens.radiusPill),
                      ),
                      child: Text(
                        '$detected number detected',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ZTokens.ink2),
                      ),
                    ),
                    if (detected != 'MTN' && flow.sourceProvider.contains('MTN'))
                      AccentBanner(
                        title: l.crossNetworkViaEkash,
                        subtitle: l.ekashRouteExplainer(
                            flow.sourceProvider, 'an $detected number'),
                        margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                      ),
                  ],
                  const Spacer(),
                  ZKeypad(
                    onDigit: (d) {
                      if (_number.length < 10) setState(() => _number += d);
                    },
                    onBackspace: () {
                      if (_number.isNotEmpty) {
                        setState(
                            () => _number = _number.substring(0, _number.length - 1));
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                    child: FilledButton(
                      onPressed: _number.length == 10 && detected != null
                          ? () {
                              ref.read(sendFlowProvider.notifier).setManualNumber(
                                    _formatNumber(_number),
                                    network: detected,
                                  );
                              context.push('/send/amount');
                            }
                          : null,
                      child: Text(l.continueLabel),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
