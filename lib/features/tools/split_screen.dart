import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/data/tools.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Split a bill — create a split, equal shares computed exactly, track
/// who has paid you back, request by SMS. Starts empty; every split on
/// screen is one the user created.
class SplitScreen extends ConsumerWidget {
  const SplitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final splits = ref.watch(splitsProvider);

    return Scaffold(
      appBar: zAppBar(context, title: l.splitABill),
      body: splits.isEmpty
          ? _empty(context)
          : ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                for (final s in splits) _splitCard(context, ref, s),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        backgroundColor: ZTokens.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ZTokens.radiusButton),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New split',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.call_split, size: 40, color: ZTokens.ink3),
          SizedBox(height: 14),
          Text('No splits yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _splitCard(BuildContext context, WidgetRef ref, SplitRequest s) {
    return ZCard(
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(
                        '${rwf(s.collected)} / ${rwf(s.total)} RWF collected',
                        style: ZText.rowSub
                            .copyWith(fontFeatures: ZTokens.numFeatures),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: ZTokens.ink3),
                  onPressed: () =>
                      ref.read(splitsProvider.notifier).remove(s.id),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ZProgress(s.total == 0 ? 0 : s.collected / s.total),
          ),
          const SizedBox(height: 6),
          for (final p in s.participants)
            BillRow(
              leading: AvatarBox(p.initials, size: 38),
              title: p.name ?? p.msisdn,
              subtitle: '${rwf(p.share)} RWF',
              showChevron: false,
              onTap: () =>
                  ref.read(splitsProvider.notifier).togglePaid(s.id, p.msisdn),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!p.paid)
                    IconButton(
                      icon: const Icon(Icons.sms_outlined,
                          size: 18, color: ZTokens.accent),
                      onPressed: () => _requestBySms(p, s),
                    ),
                  StatusPill(
                    p.paid ? 'Paid' : 'Pending',
                    kind: p.paid ? PillKind.ok : PillKind.wait,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _requestBySms(SplitParticipant p, SplitRequest s) async {
    final body = Uri.encodeComponent(
        'Muraho! Please send ${rwf(p.share)} RWF for "${s.title}" — dial *182*1*1# (Zunga)');
    final uri = Uri.parse('sms:${p.msisdn}?body=$body');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final numberCtrls = [TextEditingController()];
    final nameCtrls = [TextEditingController()];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ZTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 12, 24, MediaQuery.of(sheet).viewInsets.bottom + 24),
          child: SingleChildScrollView(
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
                const Text('New split',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _field(titleCtrl, 'What was it for?'),
                const SizedBox(height: 10),
                _field(totalCtrl, 'Total amount (RWF)',
                    keyboard: TextInputType.number),
                const SizedBox(height: 16),
                for (var i = 0; i < numberCtrls.length; i++) ...[
                  Row(
                    children: [
                      Expanded(
                          child: _field(nameCtrls[i], 'Name (optional)')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _field(numberCtrls[i], '07…',
                            keyboard: TextInputType.phone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                TextButton.icon(
                  onPressed: () => setSheet(() {
                    numberCtrls.add(TextEditingController());
                    nameCtrls.add(TextEditingController());
                  }),
                  icon: const Icon(Icons.add, size: 18, color: ZTokens.accent),
                  label: const Text('Add person',
                      style: TextStyle(color: ZTokens.accent)),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () async {
                    final total = int.tryParse(
                            totalCtrl.text.replaceAll(RegExp(r'\D'), '')) ??
                        0;
                    final numbers = [
                      for (var i = 0; i < numberCtrls.length; i++)
                        (
                          numberCtrls[i].text.replaceAll(RegExp(r'\D'), ''),
                          nameCtrls[i].text.trim(),
                        )
                    ].where((e) => e.$1.length >= 9).toList();
                    if (total <= 0 || numbers.isEmpty) return;
                    final shares = equalShares(total, numbers.length);
                    await ref.read(splitsProvider.notifier).create(SplitRequest(
                          id: DateTime.now()
                              .microsecondsSinceEpoch
                              .toString(),
                          title: titleCtrl.text.trim().isEmpty
                              ? 'Split'
                              : titleCtrl.text.trim(),
                          total: total,
                          participants: [
                            for (var i = 0; i < numbers.length; i++)
                              SplitParticipant(
                                msisdn: numbers[i].$1,
                                name: numbers[i].$2.isEmpty
                                    ? null
                                    : numbers[i].$2,
                                share: shares[i],
                              ),
                          ],
                          createdAt: DateTime.now(),
                        ));
                    if (sheet.mounted) Navigator.pop(sheet);
                  },
                  child: const Text('Create split'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      {TextInputType? keyboard}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: ZTokens.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 13.5,
              color: ZTokens.ink3,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
