import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/name_lookup.dart';
import '../../core/data/recents.dart';
import '../../core/data/settings.dart';
import '../../core/data/transactions.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';
import 'send_flow_state.dart';

/// Send · step 2: phone number or MoMo Pay code.
///
/// Name check order, best first:
///  1. registered (ID) name over the internet — the name on the SIM,
///     via the KYC endpoint once it is live in the signed config;
///  2. saved from a previous Zunga payment (recents);
///  3. the phone's contacts;
///  4. none of those → a double-check note. The carrier repeats the
///     registered name inside its own session before the PIN, always.
class SendTargetScreen extends ConsumerStatefulWidget {
  const SendTargetScreen({super.key});

  @override
  ConsumerState<SendTargetScreen> createState() => _SendTargetScreenState();
}

enum _NameSource { registered, recent, contacts }

class _SendTargetScreenState extends ConsumerState<SendTargetScreen> {
  String _number = '';
  String _code = '';
  String? _name;
  _NameSource? _nameSource;
  bool _lookingUp = false;
  Timer? _lookupDebounce;

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    super.dispose();
  }

  void _onNumberChanged() {
    _lookupDebounce?.cancel();
    if (_number.length < 10) {
      setState(() {
        _name = null;
        _nameSource = null;
        _lookingUp = false;
      });
      return;
    }
    setState(() => _lookingUp = true);
    _lookupDebounce = Timer(const Duration(milliseconds: 250), _lookupName);
  }

  Future<void> _lookupName() async {
    final number = _number;

    // 1. Registered (ID) name — needs internet and the KYC endpoint.
    final registered =
        await ref.read(nameLookupProvider).registeredName(number);
    if (!mounted || number != _number) return;
    if (registered != null) {
      setState(() {
        _name = registered;
        _nameSource = _NameSource.registered;
        _lookingUp = false;
      });
      return;
    }

    // 2. Someone this user already paid through Zunga.
    final recents = ref.read(recentsProvider);
    final recent = recents.where((r) => r.msisdn == number).toList();
    if (recent.isNotEmpty && recent.first.name != null) {
      setState(() {
        _name = recent.first.name;
        _nameSource = _NameSource.recent;
        _lookingUp = false;
      });
      return;
    }

    // 3. The phone's own contacts — only with the user's consent toggle.
    if (!ref.read(settingsProvider).enableContacts) {
      setState(() {
        _name = null;
        _nameSource = null;
        _lookingUp = false;
      });
      return;
    }
    final contact = await ref.read(ussdEngineProvider).lookupContactName(number);
    if (!mounted || number != _number) return;
    setState(() {
      _name = contact;
      _nameSource = contact != null ? _NameSource.contacts : null;
      _lookingUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final flow = ref.watch(sendFlowProvider);
    final recents = ref.watch(recentsProvider);
    final isCode = flow.target == PayTarget.merchantCode;
    final detected = detectNetwork(_number);
    final canPay =
        isCode ? _code.length >= 4 : (_number.length == 10 && detected != null);
    final preview = flow.copyWith(recipientMsisdn: _number, merchantCode: _code);

    return Scaffold(
      appBar: zAppBar(
        context,
        title: flow.amount > 0 ? '${l.pay} · ${rwf(flow.amount)} RWF' : l.sendMoney,
      ),
      body: Column(
        children: [
          SegControl(
            options: [l.phoneNumber, 'MoMo Pay code'],
            selected: isCode ? 1 : 0,
            onChanged: (i) => ref
                .read(sendFlowProvider.notifier)
                .setTarget(i == 0 ? PayTarget.phoneNumber : PayTarget.merchantCode),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 8),
                  child: Column(
                    children: [
                      Text(
                        (isCode ? 'MoMo Pay code' : l.recipientNumber).toUpperCase(),
                        style: ZText.groupLabel,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isCode
                            ? (_code.isEmpty ? '· · · · · ·' : _code)
                            : (_number.isEmpty ? '07•• ••• •••' : _formatNumber(_number)),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          fontFeatures: ZTokens.numFeatures,
                          color: (isCode ? _code : _number).isEmpty
                              ? ZTokens.ink3
                              : ZTokens.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                // People paid before — one tap fills the number.
                if (!isCode && _number.isEmpty && recents.isNotEmpty) ...[
                  GroupLabel('Paid before', topPadding: 14),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: recents.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (_, i) {
                        final r = recents[i];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _number = r.msisdn);
                            _onNumberChanged();
                          },
                          child: Column(
                            children: [
                              AvatarBox(r.initials, size: 52),
                              const SizedBox(height: 7),
                              Text(
                                r.name?.split(' ').first ?? r.msisdn,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: ZTokens.ink2),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (!isCode && detected != null)
                  Center(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ZTokens.surface,
                        border: Border.all(color: ZTokens.line),
                        borderRadius: BorderRadius.circular(ZTokens.radiusPill),
                      ),
                      child: Text(
                        preview.isCrossNetwork
                            ? '$detected number · sent via eKash'
                            : '$detected number',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ZTokens.ink2),
                      ),
                    ),
                  ),
                if (!isCode && _lookingUp)
                  const Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                // Who you are about to pay — change the number if this
                // isn't the person you meant.
                if (!isCode && !_lookingUp && _name != null)
                  AccentBanner(
                    hint: switch (_nameSource) {
                      _NameSource.registered => 'Registered name',
                      _NameSource.recent => 'Paid before with Zunga',
                      _ => 'In your contacts',
                    },
                    title: _name!,
                    subtitle: _formatNumber(_number),
                    margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  ),
                if (!isCode && !_lookingUp && canPay && _name == null)
                  const RailNote(
                    'No name found for this number yet. Double-check it — the '
                    'network will show the registered name before you confirm '
                    'with your PIN.',
                    icon: Icons.info_outline,
                    margin: EdgeInsets.fromLTRB(24, 18, 24, 0),
                  ),
              ],
            ),
          ),
          ZKeypad(
            onDigit: (d) => setState(() {
              if (isCode) {
                if (_code.length < 8) _code += d;
              } else if (_number.length < 10) {
                _number += d;
                _onNumberChanged();
              }
            }),
            onBackspace: () => setState(() {
              if (isCode) {
                if (_code.isNotEmpty) _code = _code.substring(0, _code.length - 1);
              } else if (_number.isNotEmpty) {
                _number = _number.substring(0, _number.length - 1);
                _onNumberChanged();
              }
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
            child: FilledButton(
              onPressed: canPay ? () => _pay(context) : null,
              child: Text(flow.amount > 0
                  ? '${l.pay} ${rwf(flow.amount)} RWF'
                  : l.pay),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pay(BuildContext context) async {
    final notifier = ref.read(sendFlowProvider.notifier);
    notifier.setNumber(_number);
    notifier.setMerchantCode(_code);
    final flow = ref.read(sendFlowProvider);

    // Coach mark (execution prompt §3): the next popup belongs to the
    // carrier, not Zunga. Shown before every session; backing out here
    // means nothing was sent and nothing is recorded.
    final proceed = await _showCoachMark(context, flow);
    if (proceed != true || !context.mounted) return;

    final settings = ref.read(settingsProvider);

    // Remember who was paid so the next send is one tap; the best-known
    // name is stored alongside (on-device only).
    if (settings.saveRecents && flow.target == PayTarget.phoneNumber) {
      await ref.read(recentsProvider.notifier).remember(RecentRecipient(
            msisdn: _number,
            name: _name,
            network: detectNetwork(_number),
            lastPaidAt: DateTime.now(),
          ));
    }

    // Lifecycle §2.1: recorded as awaiting_pin, promoted to
    // pending_confirmation once the session is handed to the carrier.
    // It becomes `confirmed` — and only then visible in totals — when
    // the success string or the carrier SMS proves it.
    TxRecord? tx;
    if (settings.saveTransactions) {
      tx = await ref.read(transactionsProvider.notifier).record(TxRecord(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            msisdn: flow.target == PayTarget.phoneNumber ? _number : _code,
            counterpartyName: _name,
            amount: flow.amount,
            network: detectNetwork(_number) ?? flow.routeLabel,
            status: TxStatus.awaitingPin,
            createdAt: DateTime.now(),
          ));
    }

    // Runs the session in place — the carrier popup takes over and asks
    // for the PIN. Falls back to the prefilled dialer only if the call
    // permission was just requested.
    await ref.read(ussdEngineProvider).launchUssd(flow.dialCode);
    if (tx != null) {
      await ref
          .read(transactionsProvider.notifier)
          .setStatus(tx.id, TxStatus.pendingConfirmation);
    }

    if (!context.mounted) return;
    notifier.reset();
    context.go('/home');
  }

  Future<bool?> _showCoachMark(BuildContext context, SendFlowState flow) {
    final carrier = flow.simNetworks.contains(SimNetwork.airtel) &&
            !flow.isCrossNetwork &&
            detectNetwork(_number) == 'Airtel'
        ? 'Airtel'
        : 'MTN';
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: ZTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: ZTokens.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 52,
                height: 52,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: ZTokens.accentTint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lock_outline,
                    color: ZTokens.accent, size: 24),
              ),
              Text(
                '$carrier will now ask for your PIN',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'The popup that appears next belongs to your network, not '
                'Zunga. Your PIN goes to them — Zunga never sees it. '
                'Cancel there and nothing is sent.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.5, color: ZTokens.ink2, height: 1.55),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(sheet, true),
                child: const Text('Continue'),
              ),
            ],
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
