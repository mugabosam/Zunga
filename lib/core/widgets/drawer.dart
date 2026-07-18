import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/profile.dart';
import '../theme/tokens.dart';

/// Navy side menu — replaces the bottom navigation so the keypad owns
/// the full height of the home screen.
class ZungaDrawer extends ConsumerWidget {
  const ZungaDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myNumber = ref.watch(myNumberProvider);

    void go(String route) {
      Navigator.pop(context);
      context.push(route);
    }

    return Drawer(
      backgroundColor: ZTokens.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Z',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    myNumber == null ? 'Zunga' : _formatNumber(myNumber),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFeatures: ZTokens.numFeatures,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              height: 1,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            _item(Icons.bar_chart_outlined, 'Activity', () => go('/activity')),
            _item(Icons.grid_view_outlined, 'Services', () => go('/pay')),
            _item(Icons.receipt_long_outlined, 'Bills', () => go('/bills')),
            _item(Icons.account_balance_outlined, 'Banks & wallets',
                () => go('/accounts')),
            _item(Icons.call_split, 'Split a bill', () => go('/split')),
            _item(Icons.groups_outlined, 'Ikimina', () => go('/ikimina')),
            _item(Icons.storefront_outlined, 'Merchant mode',
                () => go('/merchant')),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 1,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            _item(Icons.settings_outlined, 'Settings', () => go('/profile')),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                'Zunga v0.1.0',
                style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.8)),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(String raw) {
    final b = StringBuffer();
    b.write('+250 ');
    for (var i = 0; i < raw.length; i++) {
      if (i == 3 || i == 6) b.write(' ');
      if (!(i == 0 && raw[i] == '0')) b.write(raw[i]);
    }
    return b.toString();
  }
}
