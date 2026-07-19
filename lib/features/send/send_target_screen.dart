import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/contacts.dart';
import '../../core/data/name_lookup.dart';
import '../../core/data/recents.dart';
import '../../core/data/sample_data.dart';
import '../../core/data/settings.dart';
import '../../core/data/transactions.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../ussd/providers.dart';
import 'send_flow_state.dart';

/// Screen 01b — route picker. One universal input: phone number, MoMo
/// Pay code, EUCL meter or bank account. The route is detected as the
/// user types, shown as a tappable chip, always overridable. Names
/// resolve from the lookup service, previous payments, then contacts.
class SendTargetScreen extends ConsumerStatefulWidget {
  const SendTargetScreen({super.key});

  @override
  ConsumerState<SendTargetScreen> createState() => _SendTargetScreenState();
}

enum _NameSource { registered, recent, contacts }

class _SendTargetScreenState extends ConsumerState<SendTargetScreen> {
  final _controller = TextEditingController();
  String? _name;
  _NameSource? _nameSource;
  bool _lookingUp = false;
  Timer? _lookupDebounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      ref.read(sendFlowProvider.notifier).setInput(_controller.text);
      _onInputChanged();
    });
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    _lookupDebounce?.cancel();
    final flow = ref.read(sendFlowProvider);
    final isPhone =
        flow.route == PayRoute.mtnNumber || flow.route == PayRoute.airtelNumber;
    if (!isPhone || flow.digits.length != 10) {
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
    final number = ref.read(sendFlowProvider).digits;

    final registered = await ref
        .read(nameLookupProvider)
        .registeredName(number);
    if (!mounted || number != ref.read(sendFlowProvider).digits) return;
    if (registered != null) {
      setState(() {
        _name = registered;
        _nameSource = _NameSource.registered;
        _lookingUp = false;
      });
      return;
    }

    final recent = ref
        .read(recentsProvider)
        .where((r) => r.msisdn == number && r.name != null)
        .toList();
    if (recent.isNotEmpty) {
      setState(() {
        _name = recent.first.name;
        _nameSource = _NameSource.recent;
        _lookingUp = false;
      });
      return;
    }

    if (!ref.read(settingsProvider).enableContacts) {
      setState(() {
        _name = null;
        _nameSource = null;
        _lookingUp = false;
      });
      return;
    }
    final contact = await ref
        .read(ussdEngineProvider)
        .lookupContactName(number);
    if (!mounted || number != ref.read(sendFlowProvider).digits) return;
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: zAppBar(
        context,
        title: flow.amount > 0
            ? '${l.pay} ${rwf(flow.amount)} RWF'
            : l.sendMoney,
      ),
      body: Column(
        children: [
          // Universal destination input.
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 52,
            decoration: BoxDecoration(
              color: ZTokens.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ZTokens.shadowSoft,
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: ZTokens.ink3),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFeatures: ZTokens.numFeatures,
                      color: ZTokens.ink,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Name, number, code, meter or account',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ZTokens.ink3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Detection chip — visible, tappable, never a silent guess.
                if (flow.route != PayRoute.incomplete)
                  GestureDetector(
                    onTap: () => _chooseRoute(context, flow),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: ZTokens.accentTint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: ZTokens.accent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Detected  ',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ZTokens.ink2,
                                ),
                                children: [
                                  TextSpan(
                                    text: routeLabelOf(flow.route),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: ZTokens.ink,
                                    ),
                                  ),
                                  if (flow.isCrossNetwork)
                                    const TextSpan(text: '  ·  eKash'),
                                ],
                              ),
                            ),
                          ),
                          const Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: ZTokens.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Bank picker (bank route).
                if (flow.route == PayRoute.bank) ...[
                  GroupLabel('Choose the bank'),
                  RowGroup(
                    children: [
                      for (final bank
                          in ref
                              .watch(institutionsProvider)
                              .where((i) => !i.isWallet && i.code != null))
                        BillRow(
                          leading: AvatarBox(bank.initials, size: 40),
                          title: bank.name,
                          showChevron: false,
                          trailing: flow.bankCode == bank.code
                              ? const Icon(
                                  Icons.check_circle,
                                  color: ZTokens.accent,
                                  size: 20,
                                )
                              : null,
                          onTap: () => ref
                              .read(sendFlowProvider.notifier)
                              .setBankCode(bank.code!),
                        ),
                    ],
                  ),
                ],
                if (_lookingUp)
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
                if (!_lookingUp && _name != null)
                  AccentBanner(
                    hint: switch (_nameSource) {
                      _NameSource.registered => 'Registered name',
                      _NameSource.recent => 'Paid before',
                      _ => 'In your contacts',
                    },
                    title: _name!,
                    subtitle: _formatNumber(flow.digits),
                  ),
                if (!_lookingUp &&
                    _name == null &&
                    flow.readyToPay &&
                    (flow.route == PayRoute.mtnNumber ||
                        flow.route == PayRoute.airtelNumber))
                  const RailNote(
                    'Unrecognized number — double-check before paying.',
                    icon: Icons.info_outline,
                    iconColor: ZTokens.ink3,
                    margin: EdgeInsets.fromLTRB(24, 18, 24, 0),
                  ),
                // Recents — one tap fills the input.
                if (flow.input.isEmpty && recents.isNotEmpty) ...[
                  GroupLabel('Recent'),
                  RowGroup(
                    children: [
                      for (final r in recents.take(5))
                        BillRow(
                          leading: AvatarBox(r.initials, size: 42),
                          title: r.name ?? _formatNumber(r.msisdn),
                          subtitle: r.network,
                          showChevron: false,
                          onTap: () => _controller.text = r.msisdn,
                        ),
                    ],
                  ),
                ],
                // Every contact on the phone, searchable by name or
                // number — read on-device only.
                ..._contactsSection(flow),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ZTokens.radiusButton),
                boxShadow: flow.readyToPay ? ZTokens.shadowAccent : null,
              ),
              child: FilledButton(
                onPressed: flow.readyToPay ? () => _pay(context) : null,
                child: Text(
                  flow.amount > 0 ? '${l.pay} ${rwf(flow.amount)} RWF' : l.pay,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// All device contacts under the recents; typing letters searches
  /// names, typing digits filters numbers. Hidden once a full
  /// destination is detected.
  List<Widget> _contactsSection(SendFlowState flow) {
    final contacts =
        ref.watch(contactsProvider).value ?? const <PhoneContact>[];
    if (contacts.isEmpty) return const [];

    final raw = flow.input.trim();
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final hasLetters = raw.contains(RegExp(r'[A-Za-z]'));

    List<PhoneContact> shown;
    if (raw.isEmpty) {
      shown = contacts;
    } else if (hasLetters) {
      final q = raw.toLowerCase();
      shown = contacts.where((c) => c.name.toLowerCase().contains(q)).toList();
    } else if (flow.route == PayRoute.incomplete && digits.isNotEmpty) {
      shown = contacts.where((c) => c.msisdn.contains(digits)).toList();
    } else {
      return const [];
    }
    if (shown.isEmpty) return const [];

    return [
      GroupLabel(raw.isEmpty ? 'All contacts' : 'Contacts'),
      RowGroup(
        children: [
          for (final c in shown.take(60))
            BillRow(
              leading: AvatarBox(c.initials, size: 42),
              title: c.name,
              subtitle: _formatNumber(c.msisdn),
              showChevron: false,
              onTap: () {
                _controller.text = c.msisdn;
                FocusScope.of(context).unfocus();
              },
            ),
        ],
      ),
    ];
  }

  Future<void> _chooseRoute(BuildContext context, SendFlowState flow) async {
    final choice = await showModalBottomSheet<PayRoute>(
      context: context,
      backgroundColor: ZTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheet).viewInsets.bottom,
          ),
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
              const Text(
                'Send as',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              for (final route in const [
                PayRoute.mtnNumber,
                PayRoute.airtelNumber,
                PayRoute.momoPay,
                PayRoute.meter,
                PayRoute.bank,
              ])
                ListTile(
                  title: Text(
                    routeLabelOf(route),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: route == flow.route
                      ? const Icon(
                          Icons.check_circle,
                          color: ZTokens.accent,
                          size: 20,
                        )
                      : null,
                  onTap: () => Navigator.pop(sheet, route),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
    if (choice != null) {
      ref.read(sendFlowProvider.notifier).overrideRoute(choice);
    }
  }

  Future<void> _pay(BuildContext context) async {
    final flow = ref.read(sendFlowProvider);
    final notifier = ref.read(sendFlowProvider.notifier);
    final settings = ref.read(settingsProvider);
    final isPhone =
        flow.route == PayRoute.mtnNumber || flow.route == PayRoute.airtelNumber;

    if (settings.saveRecents && isPhone) {
      await ref
          .read(recentsProvider.notifier)
          .remember(
            RecentRecipient(
              msisdn: flow.digits,
              name: _name,
              network: detectNetwork(flow.digits),
              lastPaidAt: DateTime.now(),
            ),
          );
    }

    // Lifecycle §2.1: awaiting_pin → pending_confirmation; `confirmed`
    // only when the success string or carrier SMS proves it.
    TxRecord? tx;
    if (settings.saveTransactions) {
      tx = await ref
          .read(transactionsProvider.notifier)
          .record(
            TxRecord(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              msisdn: flow.digits,
              counterpartyName: _name,
              amount: flow.amount,
              network: detectNetwork(flow.digits) ?? routeLabelOf(flow.route),
              status: TxStatus.awaitingPin,
              createdAt: DateTime.now(),
            ),
          );
    }

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

  String _formatNumber(String raw) {
    final b = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i == 4 || i == 7) b.write(' ');
      b.write(raw[i]);
    }
    return b.toString();
  }
}
