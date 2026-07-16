import 'package:flutter_test/flutter_test.dart';
import 'package:zunga/features/send/send_flow_state.dart';

void main() {
  group('detectNetwork', () {
    test('078/079 are MTN', () {
      expect(detectNetwork('0788412903'), 'MTN');
      expect(detectNetwork('0791337264'), 'MTN');
      expect(detectNetwork('+250 788 412 903'), 'MTN');
    });

    test('072/073 are Airtel', () {
      expect(detectNetwork('0733208517'), 'Airtel');
      expect(detectNetwork('0728990431'), 'Airtel');
      expect(detectNetwork('+250733208517'), 'Airtel');
    });

    test('unknown prefixes return null', () {
      expect(detectNetwork('0700000000'), isNull);
      expect(detectNetwork(''), isNull);
    });
  });

  group('Transfer routing', () {
    test('MTN → MTN stays on-network', () {
      const s = SendFlowState(
        sourceProvider: 'MTN MoMo',
        recipientNetwork: 'MTN',
        amount: 12500,
      );
      expect(s.route, TransferRoute.momoToMomo);
    });

    test('MTN → Airtel rides eKash with the capped 20 RWF fee', () {
      const s = SendFlowState(
        sourceProvider: 'MTN MoMo',
        recipientNetwork: 'Airtel',
        amount: 30000,
      );
      expect(s.route, TransferRoute.ekashCrossNetwork);
      expect(s.fee, 20, reason: 'BNR Directive 45/2026 caps eKash fees at 20 RWF');
    });
  });
}
