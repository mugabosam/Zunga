import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunga/ussd/config_verifier.dart';
import 'package:zunga/ussd/models.dart';

void main() {
  group('Menu config bundle', () {
    late Map<String, dynamic> json;

    setUpAll(() {
      json = jsonDecode(
        File('assets/configs/menu_configs.json').readAsStringSync(),
      ) as Map<String, dynamic>;
    });

    test('parses all providers', () {
      final bundle = MenuConfigBundle.fromJson(json);
      expect(bundle.providers.keys, containsAll(['mtn_momo', 'airtel_money']));
      expect(bundle.providers.length, 6);
    });

    test('eKash cross-network send uses the verified *182*1*2# code from both carriers', () {
      final bundle = MenuConfigBundle.fromJson(json);
      for (final provider in ['mtn_momo', 'airtel_money']) {
        final flow = bundle.providers[provider]!.flows['send_cross_network_ekash']!;
        expect(flow.root, '*182*1*2#');
        expect(flow.nameCheckStep, isNotNull,
            reason: 'name verification is mandatory before PIN');
      }
    });

    test('deprecated eKash wallet activation code is not shipped', () {
      final raw = jsonEncode(json['providers']);
      expect(raw.contains('*182*11#'), isFalse,
          reason: 'the standalone eKash wallet is phased out since 14 Jul 2026');
    });

    test('unverified flows are flagged so the engine fails closed', () {
      final bundle = MenuConfigBundle.fromJson(json);
      for (final p in bundle.providers.values) {
        for (final f in p.flows.values) {
          // Until Kigali field testing signs off a tree, it must carry the
          // requires_field_verification flag.
          expect(f.requiresFieldVerification, isTrue,
              reason: '${p.provider}/${f.id} must be field-verified first');
        }
      }
    });

    test('steps match carrier strings in all three languages', () {
      final bundle = MenuConfigBundle.fromJson(json);
      final flow = bundle.providers['mtn_momo']!.flows['send_p2p']!;
      expect(flow.steps.first.matches('Enter phone number'), isTrue);
      expect(flow.steps.first.matches('Andika nimero ya telefoni'), isTrue);
      expect(flow.steps.first.matches('Entrez le numéro'), isTrue);
      expect(flow.steps.first.matches('Something unrelated'), isFalse);
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
      expect(ConfigVerifier.acceptsVersion(incoming: 40, current: 41), isFalse);
      expect(ConfigVerifier.acceptsVersion(incoming: 41, current: 41), isTrue);
      expect(ConfigVerifier.acceptsVersion(incoming: 42, current: 41), isTrue);
    });
  });
}
