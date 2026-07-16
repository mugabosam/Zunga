import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunga/ussd/config_verifier.dart';
import 'package:zunga/ussd/models.dart';

void main() {
  group('Menu config bundle', () {
    late Map<String, dynamic> json;
    late MenuConfigBundle bundle;

    setUpAll(() {
      json = jsonDecode(
        File('assets/configs/menu_configs.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      bundle = MenuConfigBundle.fromJson(json);
    });

    test('carries the two wallets and the full eKash bank table', () {
      expect(bundle.providers.keys, containsAll(['mtn_momo', 'airtel_money']));
      expect(bundle.providers.length, 20);
    });

    test('official eKash access codes match the published table', () {
      String root(String provider, [String flow = 'ekash_access']) =>
          bundle.providers[provider]!.flows[flow]!.root;

      expect(root('bank_of_kigali'), '*334*2*4#');
      expect(root('equity_bank'), '*555*2#');
      expect(root('gt_bank'), '*600*7*2#');
      expect(root('bank_of_africa'), '*512*2*2#');
      expect(root('copedu'), '*866*3#');
      expect(root('im_bank'), '*227*4*3#');
      expect(root('ecobank'), '*883*8*1#');
      expect(root('zigama_css'), '*139*5*3#');
      expect(root('ab_bank'), '*540*2*3#');
      expect(root('umwalimu_sacco'), '*175*3#');
      expect(root('bpr'), '*150*3*4#');
      expect(root('lolc_unguka'), '*951*4#');
      expect(root('access_bank'), '*903*3*5#');
      expect(root('letshego'), '*598*1*3#');
      expect(root('mvend'), '*737*1*2#');
      expect(root('ncba_bank'), '*650*1*2#');
      expect(root('jali'), '*655*8*3#');
    });

    test('Chipper Cash is app-only, no USSD flow', () {
      expect(bundle.providers['chipper_cash']!.flows, isEmpty);
    });

    test('send codes are the user-facing trio', () {
      final mtn = bundle.providers['mtn_momo']!;
      expect(mtn.flows['send_same_network']!.root, '*182*1*1#');
      expect(mtn.flows['send_cross_network_ekash']!.root, '*182*1*2#');
      expect(mtn.flows['momo_pay']!.root, '*182*8*1#');
      expect(bundle.providers['airtel_money']!
          .flows['send_cross_network_ekash']!.root, '*182*1*2#');
    });

    test('inline templates compose full dial strings, root as fallback', () {
      final send = bundle.providers['mtn_momo']!.flows['send_same_network']!;
      expect(send.dialString(msisdn: '0788412903', amount: 5000),
          '*182*1*1*0788412903*5000#');
      expect(send.dialString(), '*182*1*1#',
          reason: 'missing placeholder values must fall back to the root');

      final momoPay = bundle.providers['mtn_momo']!.flows['momo_pay']!;
      expect(momoPay.dialString(code: '048812'), '*182*8*1*048812#');
    });

    test('deprecated eKash wallet activation code is not shipped', () {
      final raw = jsonEncode(json['providers']);
      expect(raw.contains('*182*11#'), isFalse,
          reason: 'the standalone eKash wallet is phased out since 14 Jul 2026');
    });
  });

  group('Config signature', () {
    test('bundled config verifies against the pinned public key', () async {
      final config = File('assets/configs/menu_configs.json').readAsStringSync();
      final sig = File('assets/configs/menu_configs.sig').readAsStringSync().trim();
      expect(await ConfigVerifier().verify(config, sig), isTrue);
    });

    test('tampered config is rejected', () async {
      final config = File('assets/configs/menu_configs.json').readAsStringSync();
      final sig = File('assets/configs/menu_configs.sig').readAsStringSync().trim();
      final tampered = config.replaceFirst('*182*1*2#', '*182*1*9#');
      expect(await ConfigVerifier().verify(tampered, sig), isFalse);
    });

    test('signature from a foreign key is rejected', () async {
      final config = File('assets/configs/menu_configs.json').readAsStringSync();
      final foreign = await Ed25519().newKeyPair();
      final forged = await Ed25519().sign(utf8.encode(config), keyPair: foreign);
      expect(
        await ConfigVerifier().verify(config, base64Encode(forged.bytes)),
        isFalse,
      );
    });

    test('version rollback is rejected', () {
      expect(ConfigVerifier.acceptsVersion(incoming: 1, current: 2), isFalse);
      expect(ConfigVerifier.acceptsVersion(incoming: 2, current: 2), isTrue);
      expect(ConfigVerifier.acceptsVersion(incoming: 3, current: 2), isTrue);
    });
  });
}
