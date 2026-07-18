import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/bank_transfer_screen.dart';
import '../../features/accounts/linked_accounts_screen.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/bills/bills_hub_screen.dart';
import '../../features/government/government_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/legal/legal_screen.dart';
import '../../features/merchant_mode/merchant_dashboard_screen.dart';
import '../../features/merchant_pay/merchant_pay_screen.dart';
import '../../features/onboarding/register_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/pay/pay_hub_screen.dart';
import '../../features/send/send_target_screen.dart';
import '../../features/settings/profile_screen.dart';
import '../../features/tools/ikimina_screen.dart';
import '../../features/tools/split_screen.dart';
import '../data/profile.dart';

/// Flat navigation: home owns the full screen (keypad-first, side
/// drawer); every other surface is pushed on top of it.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    // One-time setup gate: until the user registers the number they pay
    // from, every route (after the splash intro) lands on /register.
    redirect: (context, state) {
      if (state.matchedLocation == '/splash') return null;
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
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/pay', builder: (_, _) => const PayHubScreen()),
      GoRoute(path: '/activity', builder: (_, _) => const ActivityScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/send', builder: (_, _) => const SendTargetScreen()),
      GoRoute(path: '/bills', builder: (_, _) => const BillsHubScreen()),
      GoRoute(path: '/merchant-pay', builder: (_, _) => const MerchantPayScreen()),
      GoRoute(path: '/bank-transfer', builder: (_, _) => const BankTransferScreen()),
      GoRoute(path: '/accounts', builder: (_, _) => const LinkedAccountsScreen()),
      GoRoute(path: '/government', builder: (_, _) => const GovernmentScreen()),
      GoRoute(path: '/split', builder: (_, _) => const SplitScreen()),
      GoRoute(path: '/ikimina', builder: (_, _) => const IkiminaScreen()),
      GoRoute(path: '/merchant', builder: (_, _) => const MerchantDashboardScreen()),
      GoRoute(path: '/legal/privacy', builder: (_, _) => const PrivacyPolicyScreen()),
      GoRoute(path: '/legal/terms', builder: (_, _) => const TermsScreen()),
    ],
  );
});
