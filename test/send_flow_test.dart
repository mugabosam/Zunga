import 'package:flutter_test/flutter_test.dart';
import 'package:zunga/features/send/send_flow_state.dart';

void main() {
  group('Smart destination detection — one input, never a silent guess', () {
    test('10 digits starting 078/079 → MTN number', () {
      expect(detectRoute('0788412903'), PayRoute.mtnNumber);
      expect(detectRoute('0791337264'), PayRoute.mtnNumber);
      expect(detectRoute('+250 788 412 903'), PayRoute.mtnNumber);
    });

    test('10 digits starting 072/073 → Airtel number', () {
      expect(detectRoute('0733208517'), PayRoute.airtelNumber);
      expect(detectRoute('0728990431'), PayRoute.airtelNumber);
      expect(detectRoute('+250733208517'), PayRoute.airtelNumber);
    });

    test('5–6 digits → MoMo Pay merchant code', () {
      expect(detectRoute('48812'), PayRoute.momoPay);
      expect(detectRoute('048812'), PayRoute.momoPay);
    });

    test('10–11 digits not starting 07 → EUCL meter', () {
      expect(detectRoute('0123456789'), PayRoute.meter);
      expect(detectRoute('12845901773'), PayRoute.meter);
    });

    test('12+ digits → bank account', () {
      expect(detectRoute('000401234567'), PayRoute.bank);
      expect(detectRoute('4001234567890123'), PayRoute.bank);
    });

    test('partial input stays incomplete — no premature guess', () {
      expect(detectRoute(''), PayRoute.incomplete);
      expect(detectRoute('078'), PayRoute.incomplete);
      expect(detectRoute('0788412'), PayRoute.incomplete);
    });
  });

  group('Dial code per route — SIM networks detected, never asked', () {
    test('MTN SIM → MTN number pre-fills number and amount', () {
      const s = SendFlowState(
        simNetworks: {SimNetwork.mtn},
        input: '0788412903',
        amount: 5000,
      );
      expect(s.isCrossNetwork, isFalse);
      expect(s.readyToPay, isTrue);
      expect(s.dialCode, '*182*1*1*0788412903*5000#');
    });

    test('MTN SIM → Airtel number routes through eKash *182*1*2#', () {
      const s = SendFlowState(
        simNetworks: {SimNetwork.mtn},
        input: '0733208517',
        amount: 5000,
      );
      expect(s.isCrossNetwork, isTrue);
      expect(s.dialCode, '*182*1*2#');
    });

    test('Airtel SIM → MTN number also routes through eKash', () {
      const s = SendFlowState(
        simNetworks: {SimNetwork.airtel},
        input: '0788412903',
        amount: 5000,
      );
      expect(s.isCrossNetwork, isTrue);
      expect(s.dialCode, '*182*1*2#');
    });

    test('Airtel SIM → Airtel number opens the Airtel Money menu', () {
      const s = SendFlowState(
        simNetworks: {SimNetwork.airtel},
        input: '0733208517',
        amount: 5000,
      );
      expect(s.dialCode, '*500#');
    });

    test('MoMo Pay code pre-fills *182*8*1*code#', () {
      const s = SendFlowState(input: '048812', amount: 3000);
      expect(s.route, PayRoute.momoPay);
      expect(s.dialCode, '*182*8*1*048812#');
    });

    test('bank route requires a picked bank and uses its access code', () {
      const unpicked = SendFlowState(input: '000401234567', amount: 10000);
      expect(unpicked.readyToPay, isFalse);
      const picked = SendFlowState(
        input: '000401234567',
        amount: 10000,
        bankCode: '*334*2*4#',
      );
      expect(picked.readyToPay, isTrue);
      expect(picked.dialCode, '*334*2*4#');
    });

    test('user override beats detection', () {
      const s = SendFlowState(
        input: '048812',
        routeOverride: PayRoute.meter,
      );
      expect(s.route, PayRoute.meter);
    });
  });

  group('detectNetwork helper', () {
    test('resolves complete numbers only', () {
      expect(detectNetwork('0788412903'), 'MTN');
      expect(detectNetwork('0733208517'), 'Airtel');
      expect(detectNetwork('0700000000'), isNull);
      expect(detectNetwork(''), isNull);
    });
  });
}
