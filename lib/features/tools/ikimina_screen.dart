import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/tools.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Ikimina — rotating savings groups. Pot fills as members pay, one
/// member receives each round, next round rotates the receiver. Starts
/// empty; every group is created by the user.
class IkiminaScreen extends ConsumerWidget {
  const IkiminaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final groups = ref.watch(ikiminaProvider);

    return Scaffold(
      appBar: zAppBar(context, title: l.ikimina),
      body: groups.isEmpty
          ? _empty()
          : ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                for (final g in groups) _groupCard(context, ref, g),
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
        label: const Text('New group',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.groups_outlined, size: 40, color: ZTokens.ink3),
          SizedBox(height: 14),
          Text('No ikimina yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _groupCard(BuildContext context, WidgetRef ref, IkiminaGroup g) {
    final receiver = g.receiver;
    return ZCard(
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          // Pot header — navy gradient, like the home pay card.
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: ZTokens.navyGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        g.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(ZTokens.radiusPill),
                      ),
                      child: Text(
                        'Round ${g.round}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(Icons.delete_outline,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.6)),
                      onPressed: () =>
                          ref.read(ikiminaProvider.notifier).remove(g.id),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: rwf(g.pot),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFeatures: ZTokens.numFeatures,
                    ),
                    children: [
                      TextSpan(
                        text: ' RWF',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: g.members.isEmpty
                              ? 0
                              : g.paidCount / g.members.length,
                          minHeight: 6,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                          valueColor:
                              const AlwaysStoppedAnimation(ZTokens.accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${g.paidCount} of ${g.members.length} paid',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontFeatures: ZTokens.numFeatures,
                      ),
                    ),
                  ],
                ),
                if (receiver != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${receiver.name} receives this round',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ZTokens.accentTint),
                  ),
                ],
              ],
            ),
          ),
          for (final m in g.members)
            BillRow(
              leading: AvatarBox(m.initials, size: 38),
              title: m.name,
              subtitle: '${rwf(g.contribution)} RWF',
              showChevron: false,
              onTap: () {
                final updated = g.copyWith(members: [
                  for (final x in g.members)
                    x == m ? x.copyWith(paid: !x.paid) : x,
                ]);
                ref.read(ikiminaProvider.notifier).update(updated);
              },
              trailing: StatusPill(
                m.paid ? 'Paid' : 'Pending',
                kind: m.paid ? PillKind.ok : PillKind.wait,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: OutlinedButton(
              onPressed: g.paidCount == g.members.length && g.members.isNotEmpty
                  ? () => ref
                      .read(ikiminaProvider.notifier)
                      .update(g.nextRound())
                  : null,
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46)),
              child: const Text('Close round'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final memberCtrls = [TextEditingController(), TextEditingController()];

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
                const Text('New ikimina',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _field(nameCtrl, 'Group name'),
                const SizedBox(height: 10),
                _field(amountCtrl, 'Contribution per member (RWF)',
                    keyboard: TextInputType.number),
                const SizedBox(height: 16),
                for (final c in memberCtrls) ...[
                  _field(c, 'Member name'),
                  const SizedBox(height: 10),
                ],
                TextButton.icon(
                  onPressed: () => setSheet(
                      () => memberCtrls.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 18, color: ZTokens.accent),
                  label: const Text('Add member',
                      style: TextStyle(color: ZTokens.accent)),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () async {
                    final contribution = int.tryParse(amountCtrl.text
                            .replaceAll(RegExp(r'\D'), '')) ??
                        0;
                    final members = memberCtrls
                        .map((c) => c.text.trim())
                        .where((n) => n.isNotEmpty)
                        .map((n) => IkiminaMember(name: n))
                        .toList();
                    if (nameCtrl.text.trim().isEmpty ||
                        contribution <= 0 ||
                        members.length < 2) {
                      return;
                    }
                    await ref.read(ikiminaProvider.notifier).create(
                          IkiminaGroup(
                            id: DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                            name: nameCtrl.text.trim(),
                            contribution: contribution,
                            members: members,
                          ),
                        );
                    if (sheet.mounted) Navigator.pop(sheet);
                  },
                  child: const Text('Create group'),
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
