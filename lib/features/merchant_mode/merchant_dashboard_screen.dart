import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/tools.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/kit.dart';
import '../../core/widgets/scaffold.dart';

/// Merchant mode — business profile + income dashboard. Numbers come
/// only from real recorded payments (none yet: incoming tracking ships
/// with SMS parsing), so stats start at zero, never invented.
class MerchantDashboardScreen extends ConsumerWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(merchantProvider);
    return Scaffold(
      appBar: zAppBar(
        context,
        title: profile?.businessName ?? 'Merchant mode',
      ),
      body: profile == null
          ? _setup(context, ref)
          : _dashboard(context, ref, profile),
    );
  }

  // -------------------------------------------------------- setup

  Widget _setup(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        ZCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Set up your business',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              _field(nameCtrl, 'Business name'),
              const SizedBox(height: 10),
              _field(codeCtrl, 'MoMo Pay code', keyboard: TextInputType.number),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final code = codeCtrl.text.replaceAll(RegExp(r'\D'), '');
                  if (name.isEmpty || code.length < 4) return;
                  await ref.read(merchantProvider.notifier).save(
                      MerchantProfile(businessName: name, momoPayCode: code));
                },
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------- dashboard

  Widget _dashboard(
      BuildContext context, WidgetRef ref, MerchantProfile profile) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // The customer-facing card: your MoMo Pay code, big.
        Container(
          margin: const EdgeInsets.fromLTRB(24, 4, 24, 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: ZTokens.navyGradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: ZTokens.shadow,
          ),
          child: Column(
            children: [
              Text(
                'MOMO PAY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                profile.momoPayCode,
                style: const TextStyle(
                  fontFamily: ZTokens.fontFamilyMono,
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profile.businessName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: Row(
            children: [
              Expanded(child: _stat('Sales today', rwf(0))),
              const SizedBox(width: 12),
              Expanded(child: _stat('Payments', '0')),
            ],
          ),
        ),
        GroupLabel('Payments received'),
        ZCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: const [
              Icon(Icons.storefront_outlined, size: 28, color: ZTokens.ink3),
              SizedBox(height: 10),
              Text(
                'No payments recorded yet',
                style: TextStyle(fontSize: 13, color: ZTokens.ink2),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: OutlinedButton(
            onPressed: null,
            child: const Text('Export statement'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: TextButton(
            onPressed: () => ref.read(merchantProvider.notifier).clear(),
            child: const Text('Reset business profile'),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return ZCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ZTokens.ink3)),
          const SizedBox(height: 6),
          Text(value, style: ZText.amount(21)),
        ],
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
