import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real data only — no mocks. This is the official eKash access-code
/// table (July 2026): each institution's own USSD entry point into the
/// national rail. Chipper Cash is app-only. The same list ships in the
/// signed config (assets/configs/menu_configs.json); this constant is
/// the offline-first copy for the directory screens.
class Institution {
  const Institution(this.name, this.code, {this.isWallet = false});

  final String name;

  /// USSD access code; null = app-only, no USSD.
  final String? code;
  final bool isWallet;

  String get initials {
    final words = name.split(RegExp(r'[\s&]+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }
}

const ekashInstitutions = [
  Institution('MTN MoMo', '*182*1*2#', isWallet: true),
  Institution('Airtel Money', '*182*1*2#', isWallet: true),
  Institution('Bank of Kigali', '*334*2*4#'),
  Institution('Equity Bank', '*555*2#'),
  Institution('GT Bank', '*600*7*2#'),
  Institution('Bank of Africa', '*512*2*2#'),
  Institution('Copedu', '*866*3#'),
  Institution('I&M Bank', '*227*4*3#'),
  Institution('Ecobank', '*883*8*1#'),
  Institution('Zigama CSS', '*139*5*3#'),
  Institution('AB Bank', '*540*2*3#'),
  Institution('Umwalimu Sacco', '*175*3#'),
  Institution('BPR Bank', '*150*3*4#'),
  Institution('LOLC Unguka', '*951*4#'),
  Institution('Access Bank', '*903*3*5#'),
  Institution('Letshego', '*598*1*3#'),
  Institution('Mvend', '*737*1*2#'),
  Institution('NCBA Bank', '*650*1*2#'),
  Institution('Jali', '*655*8*3#'),
  Institution('Chipper Cash', null),
];

final institutionsProvider = Provider<List<Institution>>((ref) => ekashInstitutions);

/// Wallet menu roots — the two carriers' own USSD entry points.
const mtnMenuRoot = '*182#';
const airtelMenuRoot = '*500#';
