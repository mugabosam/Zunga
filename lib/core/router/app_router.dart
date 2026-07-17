import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/profile.dart';
import '../../features/accounts/bank_transfer_screen.dart';
import '../../features/accounts/linked_accounts_screen.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/bills/bills_hub_screen.dart';
import '../../features/government/government_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/merchant_pay/merchant_pay_screen.dart';
import '../../features/onboarding/register_screen.dart';
import '../../features/pay/pay_hub_screen.dart';
import '../../features/send/send_amount_screen.dart';
import '../../features/send/send_target_screen.dart';
import '../../features/settings/profile_screen.dart';
import '../theme/tokens.dart';
import '../../l10n/app_localizations.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    // One-time setup gate: until the user registers the number they pay
    // from, every route lands on /register.
    redirect: (context, state) {
      final registered = ref.read(myNumberProvider) != null;
      if (!registered && state.matchedLocation != '/register') {
        return '/register';
      }
      if (registered && state.matchedLocation == '/register') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _NavShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/pay', builder: (_, _) => const PayHubScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/activity', builder: (_, _) => const ActivityScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ]),
        ],
      ),
      GoRoute(path: '/send', builder: (_, _) => const SendAmountScreen()),
      GoRoute(path: '/send/target', builder: (_, _) => const SendTargetScreen()),
      GoRoute(path: '/bills', builder: (_, _) => const BillsHubScreen()),
      GoRoute(path: '/merchant-pay', builder: (_, _) => const MerchantPayScreen()),
      GoRoute(path: '/bank-transfer', builder: (_, _) => const BankTransferScreen()),
      GoRoute(path: '/accounts', builder: (_, _) => const LinkedAccountsScreen()),
      GoRoute(path: '/government', builder: (_, _) => const GovernmentScreen()),
    ],
  );
});

/// Bottom navigation shell: Home · Pay · Activity · Profile.
class _NavShell extends StatelessWidget {
  const _NavShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      (Icons.home_outlined, l.navHome),
      (Icons.arrow_forward, l.navPay),
      (Icons.bar_chart_outlined, l.navActivity),
      (Icons.person_outline, l.navProfile),
    ];
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: ZTokens.surface,
          border: Border(top: BorderSide(color: ZTokens.line)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i].$1,
                            size: 22,
                            color: i == shell.currentIndex
                                ? ZTokens.accent
                                : ZTokens.ink3,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            items[i].$2,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: i == shell.currentIndex
                                  ? ZTokens.accent
                                  : ZTokens.ink3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
