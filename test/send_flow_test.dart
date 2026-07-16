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

  group('Dial code selection — the codes the user actually dials', () {
    test('MTN → MTN pre-fills number and amount, leaving only the PIN', () {
      const s = SendFlowState(
        source: SourceNetwork.mtn,
        recipientMsisdn: '0788412903',
        amount: 5000,
      );
      expect(s.dialCode, '*182*1*1*0788412903*5000#');
    });

    test('MTN → Airtel routes through eKash *182*1*2#', () {
      const s = SendFlowState(
        source: SourceNetwork.mtn,
        recipientMsisdn: '0733208517',
        amount: 5000,
      );
      expect(s.isCrossNetwork, isTrue);
      expect(s.dialCode, '*182*1*2#');
    });

    test('Airtel → MTN also routes through eKash *182*1*2#', () {
      const s = SendFlowState(
        source: SourceNetwork.airtel,
        recipientMsisdn: '0788412903',
        amount: 5000,
      );
      expect(s.isCrossNetwork, isTrue);
      expect(s.dialCode, '*182*1*2#');
    });

    test('Airtel → Airtel opens the Airtel Money menu *500#', () {
      const s = SendFlowState(
        source: SourceNetwork.airtel,
        recipientMsisdn: '0733208517',
        amount: 5000,
      );
      expect(s.dialCode, '*500#');
    });

    test('MoMo Pay merchant code pre-fills *182*8*1*code#', () {
      const s = SendFlowState(
        target: PayTarget.merchantCode,
        merchantCode: '048812',
        amount: 3000,
      );
      expect(s.dialCode, '*182*8*1*048812#');
    });

    test('MoMo Pay without a code falls back to the bare menu', () {
      const s = SendFlowState(target: PayTarget.merchantCode);
      expect(s.dialCode, '*182*8*1#');
    });
  });
}
